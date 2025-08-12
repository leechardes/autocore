"""
Rate limiting para conformidade com MQTT v2.2.0
Implementa limite de 100 mensagens/segundo por dispositivo
"""
import asyncio
import logging
from collections import defaultdict, deque
from time import time
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

@dataclass
class RateLimitStats:
    """Estatísticas de rate limiting para um dispositivo"""
    device_uuid: str
    current_rate: int
    max_rate: int
    total_messages: int
    blocked_messages: int
    last_message_time: Optional[datetime] = None
    last_block_time: Optional[datetime] = None

class RateLimiter:
    """
    Rate limiter para mensagens MQTT
    Implementa limite configurável de mensagens por segundo por dispositivo
    """
    
    def __init__(self, max_messages_per_second: int = 100, window_seconds: int = 1):
        self.max_rate = max_messages_per_second
        self.window_seconds = window_seconds
        
        # Armazenar timestamps das mensagens por dispositivo
        # Usando deque para performance otimizada
        self.device_timestamps: Dict[str, deque] = defaultdict(lambda: deque())
        
        # Estatísticas por dispositivo
        self.device_stats: Dict[str, RateLimitStats] = {}
        
        # Lock para thread safety
        self.lock = asyncio.Lock()
        
        # Configurações
        self.cleanup_interval = 60  # Limpar dados antigos a cada 60 segundos
        self.last_cleanup = time()
        
        logger.info(f"Rate limiter inicializado: {max_messages_per_second} msgs/s por dispositivo")
    
    async def check_rate(self, device_uuid: str) -> bool:
        """
        Verifica se dispositivo pode enviar mensagem
        Retorna True se permitido, False se excedeu limite
        """
        async with self.lock:
            current_time = time()
            
            # Limpar timestamps antigos periodicamente
            if current_time - self.last_cleanup > self.cleanup_interval:
                await self._cleanup_old_data()
                self.last_cleanup = current_time
            
            # Obter timestamps do dispositivo
            device_timestamps = self.device_timestamps[device_uuid]
            
            # Remover timestamps fora da janela de tempo
            cutoff_time = current_time - self.window_seconds
            while device_timestamps and device_timestamps[0] < cutoff_time:
                device_timestamps.popleft()
            
            # Verificar se excedeu o limite
            current_count = len(device_timestamps)
            
            # Inicializar stats se necessário
            if device_uuid not in self.device_stats:
                self.device_stats[device_uuid] = RateLimitStats(
                    device_uuid=device_uuid,
                    current_rate=0,
                    max_rate=self.max_rate,
                    total_messages=0,
                    blocked_messages=0
                )
            
            stats = self.device_stats[device_uuid]
            stats.current_rate = current_count
            stats.last_message_time = datetime.fromtimestamp(current_time)
            
            if current_count >= self.max_rate:
                # Limite excedido
                stats.blocked_messages += 1
                stats.last_block_time = datetime.fromtimestamp(current_time)
                
                logger.warning(
                    f"Rate limit exceeded for device {device_uuid}: "
                    f"{current_count}/{self.max_rate} msgs/s"
                )
                return False
            
            # Permitir mensagem
            device_timestamps.append(current_time)
            stats.total_messages += 1
            
            # Log debug apenas para dispositivos com alta taxa
            if current_count > self.max_rate * 0.8:  # Avisar quando > 80% do limite
                logger.debug(
                    f"High message rate for device {device_uuid}: "
                    f"{current_count}/{self.max_rate} msgs/s"
                )
            
            return True
    
    async def _cleanup_old_data(self):
        """Remove dados antigos para liberar memória"""
        current_time = time()
        cutoff_time = current_time - (self.window_seconds * 2)  # Manter dados por 2x a janela
        
        devices_to_remove = []
        
        for device_uuid, timestamps in self.device_timestamps.items():
            # Remover timestamps antigos
            while timestamps and timestamps[0] < cutoff_time:
                timestamps.popleft()
            
            # Se não há timestamps recentes, marcar para remoção
            if not timestamps:
                devices_to_remove.append(device_uuid)
        
        # Remover dispositivos inativos
        for device_uuid in devices_to_remove:
            del self.device_timestamps[device_uuid]
            if device_uuid in self.device_stats:
                del self.device_stats[device_uuid]
        
        if devices_to_remove:
            logger.debug(f"Cleaned up rate limiter data for {len(devices_to_remove)} inactive devices")
    
    def get_device_rate(self, device_uuid: str) -> int:
        """Retorna taxa atual de mensagens do dispositivo"""
        if device_uuid not in self.device_timestamps:
            return 0
        
        current_time = time()
        cutoff_time = current_time - self.window_seconds
        
        timestamps = self.device_timestamps[device_uuid]
        
        # Contar timestamps dentro da janela
        count = 0
        for timestamp in timestamps:
            if timestamp >= cutoff_time:
                count += 1
        
        return count
    
    def get_device_stats(self, device_uuid: str) -> Optional[RateLimitStats]:
        """Retorna estatísticas detalhadas do dispositivo"""
        return self.device_stats.get(device_uuid)
    
    def get_all_stats(self) -> Dict[str, RateLimitStats]:
        """Retorna estatísticas de todos os dispositivos"""
        return self.device_stats.copy()
    
    def get_top_devices(self, limit: int = 10) -> List[Tuple[str, int]]:
        """Retorna dispositivos com maior taxa de mensagens"""
        device_rates = []
        
        for device_uuid in self.device_timestamps.keys():
            rate = self.get_device_rate(device_uuid)
            device_rates.append((device_uuid, rate))
        
        # Ordenar por taxa (descendente)
        device_rates.sort(key=lambda x: x[1], reverse=True)
        
        return device_rates[:limit]
    
    def is_device_blocked(self, device_uuid: str) -> bool:
        """Verifica se dispositivo está atualmente bloqueado"""
        return self.get_device_rate(device_uuid) >= self.max_rate
    
    def reset_device_stats(self, device_uuid: str):
        """Reseta estatísticas de um dispositivo específico"""
        if device_uuid in self.device_timestamps:
            self.device_timestamps[device_uuid].clear()
        
        if device_uuid in self.device_stats:
            stats = self.device_stats[device_uuid]
            stats.current_rate = 0
            stats.total_messages = 0
            stats.blocked_messages = 0
            stats.last_block_time = None
        
        logger.info(f"Rate limiter stats reset for device {device_uuid}")
    
    def reset_all_stats(self):
        """Reseta todas as estatísticas"""
        self.device_timestamps.clear()
        self.device_stats.clear()
        logger.info("All rate limiter stats reset")
    
    def get_global_stats(self) -> Dict[str, any]:
        """Retorna estatísticas globais do rate limiter"""
        total_devices = len(self.device_stats)
        total_messages = sum(stats.total_messages for stats in self.device_stats.values())
        total_blocked = sum(stats.blocked_messages for stats in self.device_stats.values())
        
        blocked_devices = sum(1 for device_uuid in self.device_timestamps.keys() 
                             if self.is_device_blocked(device_uuid))
        
        return {
            'max_rate_per_device': self.max_rate,
            'window_seconds': self.window_seconds,
            'total_devices': total_devices,
            'blocked_devices': blocked_devices,
            'total_messages_processed': total_messages,
            'total_messages_blocked': total_blocked,
            'block_rate': (total_blocked / total_messages * 100) if total_messages > 0 else 0,
            'last_cleanup': datetime.fromtimestamp(self.last_cleanup).isoformat()
        }
    
    def update_rate_limit(self, new_max_rate: int):
        """Atualiza limite de rate durante runtime"""
        old_rate = self.max_rate
        self.max_rate = new_max_rate
        
        # Atualizar stats de todos os dispositivos
        for stats in self.device_stats.values():
            stats.max_rate = new_max_rate
        
        logger.info(f"Rate limit updated: {old_rate} -> {new_max_rate} msgs/s")

class GlobalRateLimiter:
    """
    Rate limiter global para todo o sistema
    Útil para limitar carga total do gateway
    """
    
    def __init__(self, max_total_messages_per_second: int = 1000):
        self.max_total_rate = max_total_messages_per_second
        self.window_seconds = 1
        self.global_timestamps = deque()
        self.lock = asyncio.Lock()
        
        logger.info(f"Global rate limiter inicializado: {max_total_messages_per_second} msgs/s total")
    
    async def check_global_rate(self) -> bool:
        """Verifica limite global de mensagens"""
        async with self.lock:
            current_time = time()
            cutoff_time = current_time - self.window_seconds
            
            # Remover timestamps antigos
            while self.global_timestamps and self.global_timestamps[0] < cutoff_time:
                self.global_timestamps.popleft()
            
            current_count = len(self.global_timestamps)
            
            if current_count >= self.max_total_rate:
                logger.warning(f"Global rate limit exceeded: {current_count}/{self.max_total_rate} msgs/s")
                return False
            
            self.global_timestamps.append(current_time)
            return True
    
    def get_global_rate(self) -> int:
        """Retorna taxa global atual"""
        current_time = time()
        cutoff_time = current_time - self.window_seconds
        
        count = 0
        for timestamp in self.global_timestamps:
            if timestamp >= cutoff_time:
                count += 1
        
        return count