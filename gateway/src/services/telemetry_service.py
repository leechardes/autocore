"""
Telemetry Service para AutoCore Gateway
Processa e armazena dados de telemetria dos dispositivos ESP32
"""
import asyncio
import json
import logging
from typing import Dict, Any, List, Optional
from datetime import datetime, timedelta
from dataclasses import dataclass
from collections import deque
import sys
from pathlib import Path

# Adicionar path do database compartilhado
sys.path.append(str(Path(__file__).parent.parent.parent.parent / "database"))

from shared.repositories import telemetry, events

logger = logging.getLogger(__name__)

@dataclass
class TelemetryData:
    """Dados de telemetria processados"""
    device_uuid: str
    timestamp: datetime
    sensor_type: str
    value: float
    unit: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None

class TelemetryBuffer:
    """Buffer para batching de telemetria"""
    
    def __init__(self, max_size: int = 100, flush_interval: float = 5.0):
        self.buffer: deque = deque(maxlen=max_size)
        self.max_size = max_size
        self.flush_interval = flush_interval
        self.last_flush = datetime.now()
    
    def add(self, data: TelemetryData):
        """Adiciona dados ao buffer"""
        self.buffer.append(data)
    
    def should_flush(self) -> bool:
        """Verifica se deve fazer flush do buffer"""
        return (
            len(self.buffer) >= self.max_size or
            (datetime.now() - self.last_flush).total_seconds() >= self.flush_interval
        )
    
    def get_and_clear(self) -> List[TelemetryData]:
        """Retorna dados do buffer e limpa"""
        data = list(self.buffer)
        self.buffer.clear()
        self.last_flush = datetime.now()
        return data

class TelemetryService:
    """Serviço de telemetria do Gateway"""
    
    def __init__(self, batch_size: int = 10, flush_interval: float = 5.0):
        self.buffer = TelemetryBuffer(batch_size, flush_interval)
        self.stats = {
            'messages_processed': 0,
            'messages_stored': 0,
            'errors': 0,
            'last_flush': None
        }
        
        # Iniciar task de flush periódico
        asyncio.create_task(self._periodic_flush())
    
    async def process_telemetry_data(self, device_uuid: str, telemetry_data: Dict[str, Any], timestamp: datetime):
        """Processa dados de telemetria recebidos"""
        try:
            logger.debug(f"📊 Processando telemetria de {device_uuid}")
            self.stats['messages_processed'] += 1
            
            # Processar diferentes tipos de dados de telemetria
            processed_data = []
            
            # Dados CAN Bus
            if 'can_data' in telemetry_data:
                can_data = telemetry_data['can_data']
                processed_data.extend(self._process_can_data(device_uuid, can_data, timestamp))
            
            # Sensores analógicos
            if 'analog_sensors' in telemetry_data:
                analog_data = telemetry_data['analog_sensors']
                processed_data.extend(self._process_analog_sensors(device_uuid, analog_data, timestamp))
            
            # Status do sistema
            if 'system_status' in telemetry_data:
                system_data = telemetry_data['system_status']
                processed_data.extend(self._process_system_status(device_uuid, system_data, timestamp))
            
            # GPS (se disponível)
            if 'gps' in telemetry_data:
                gps_data = telemetry_data['gps']
                processed_data.extend(self._process_gps_data(device_uuid, gps_data, timestamp))
            
            # Adicionar todos os dados processados ao buffer
            for data in processed_data:
                self.buffer.add(data)
            
            # Verificar se deve fazer flush
            if self.buffer.should_flush():
                await self._flush_buffer()
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar telemetria de {device_uuid}: {e}")
            self.stats['errors'] += 1
    
    def _process_can_data(self, device_uuid: str, can_data: Dict[str, Any], timestamp: datetime) -> List[TelemetryData]:
        """Processa dados CAN Bus"""
        processed = []
        
        try:
            signals = can_data.get('signals', {})
            
            for signal_name, signal_data in signals.items():
                if isinstance(signal_data, dict) and 'value' in signal_data:
                    value = signal_data['value']
                    unit = signal_data.get('unit')
                    can_id = signal_data.get('can_id')
                    
                    telemetry_item = TelemetryData(
                        device_uuid=device_uuid,
                        timestamp=timestamp,
                        sensor_type=f"can_{signal_name.lower()}",
                        value=float(value),
                        unit=unit,
                        metadata={
                            'can_id': can_id,
                            'signal_name': signal_name,
                            'source': 'can_bus'
                        }
                    )
                    processed.append(telemetry_item)
                
        except Exception as e:
            logger.error(f"❌ Erro ao processar dados CAN: {e}")
            
        return processed
    
    def _process_analog_sensors(self, device_uuid: str, analog_data: Dict[str, Any], timestamp: datetime) -> List[TelemetryData]:
        """Processa sensores analógicos"""
        processed = []
        
        try:
            for sensor_name, value in analog_data.items():
                if isinstance(value, (int, float)):
                    telemetry_item = TelemetryData(
                        device_uuid=device_uuid,
                        timestamp=timestamp,
                        sensor_type=f"analog_{sensor_name.lower()}",
                        value=float(value),
                        metadata={
                            'sensor_name': sensor_name,
                            'source': 'analog_sensor'
                        }
                    )
                    processed.append(telemetry_item)
                
        except Exception as e:
            logger.error(f"❌ Erro ao processar sensores analógicos: {e}")
            
        return processed
    
    def _process_system_status(self, device_uuid: str, system_data: Dict[str, Any], timestamp: datetime) -> List[TelemetryData]:
        """Processa status do sistema"""
        processed = []
        
        try:
            # Mapear campos de sistema para telemetria
            system_fields = {
                'cpu_temperature': ('cpu_temp', '°C'),
                'memory_usage': ('memory_used', '%'),
                'uptime': ('uptime', 'seconds'),
                'wifi_signal': ('wifi_signal', 'dBm'),
                'battery_voltage': ('battery_voltage', 'V')
            }
            
            for field_name, (sensor_type, unit) in system_fields.items():
                if field_name in system_data:
                    value = system_data[field_name]
                    if isinstance(value, (int, float)):
                        telemetry_item = TelemetryData(
                            device_uuid=device_uuid,
                            timestamp=timestamp,
                            sensor_type=sensor_type,
                            value=float(value),
                            unit=unit,
                            metadata={
                                'source': 'system_status'
                            }
                        )
                        processed.append(telemetry_item)
                
        except Exception as e:
            logger.error(f"❌ Erro ao processar status do sistema: {e}")
            
        return processed
    
    def _process_gps_data(self, device_uuid: str, gps_data: Dict[str, Any], timestamp: datetime) -> List[TelemetryData]:
        """Processa dados GPS"""
        processed = []
        
        try:
            gps_fields = {
                'latitude': ('gps_lat', 'degrees'),
                'longitude': ('gps_lng', 'degrees'),
                'altitude': ('gps_alt', 'meters'),
                'speed': ('gps_speed', 'km/h'),
                'heading': ('gps_heading', 'degrees'),
                'satellites': ('gps_satellites', 'count')
            }
            
            for field_name, (sensor_type, unit) in gps_fields.items():
                if field_name in gps_data:
                    value = gps_data[field_name]
                    if isinstance(value, (int, float)):
                        telemetry_item = TelemetryData(
                            device_uuid=device_uuid,
                            timestamp=timestamp,
                            sensor_type=sensor_type,
                            value=float(value),
                            unit=unit,
                            metadata={
                                'source': 'gps',
                                'accuracy': gps_data.get('accuracy'),
                                'fix_type': gps_data.get('fix_type')
                            }
                        )
                        processed.append(telemetry_item)
                
        except Exception as e:
            logger.error(f"❌ Erro ao processar dados GPS: {e}")
            
        return processed
    
    async def _flush_buffer(self):
        """Salva dados do buffer no database"""
        try:
            data_to_flush = self.buffer.get_and_clear()
            if not data_to_flush:
                return
            
            logger.debug(f"💾 Salvando {len(data_to_flush)} registros de telemetria")
            
            # Preparar dados para o database
            db_records = []
            for data in data_to_flush:
                record = {
                    'device_uuid': data.device_uuid,
                    'sensor_type': data.sensor_type,
                    'value': data.value,
                    'unit': data.unit,
                    'metadata': json.dumps(data.metadata) if data.metadata else None,
                    'timestamp': data.timestamp
                }
                db_records.append(record)
            
            # Salvar em batch no database
            for record in db_records:
                telemetry.create(record)
            
            self.stats['messages_stored'] += len(db_records)
            self.stats['last_flush'] = datetime.now()
            
            logger.debug(f"✅ {len(db_records)} registros salvos com sucesso")
            
        except Exception as e:
            logger.error(f"❌ Erro ao salvar telemetria: {e}")
            self.stats['errors'] += 1
    
    async def _periodic_flush(self):
        """Task para flush periódico do buffer"""
        try:
            while True:
                await asyncio.sleep(1.0)  # Verificar a cada segundo
                
                if self.buffer.should_flush():
                    await self._flush_buffer()
                    
        except asyncio.CancelledError:
            logger.info("📴 Task de flush periódico cancelada")
            # Fazer flush final dos dados restantes
            await self._flush_buffer()
        except Exception as e:
            logger.error(f"❌ Erro no flush periódico: {e}")
    
    async def get_recent_telemetry(self, device_uuid: str, sensor_type: Optional[str] = None, 
                                 limit: int = 100) -> List[Dict[str, Any]]:
        """Retorna telemetria recente de um dispositivo"""
        try:
            # Buscar dados do database
            filters = {'device_uuid': device_uuid}
            if sensor_type:
                filters['sensor_type'] = sensor_type
            
            records = telemetry.get_recent(filters, limit)
            
            # Converter para formato de resposta
            result = []
            for record in records:
                item = {
                    'device_uuid': record.device_uuid,
                    'sensor_type': record.sensor_type,
                    'value': record.value,
                    'unit': record.unit,
                    'timestamp': record.timestamp.isoformat(),
                    'metadata': json.loads(record.metadata) if record.metadata else None
                }
                result.append(item)
            
            return result
            
        except Exception as e:
            logger.error(f"❌ Erro ao buscar telemetria recente: {e}")
            return []
    
    def get_stats(self) -> Dict[str, Any]:
        """Retorna estatísticas do serviço de telemetria"""
        return {
            **self.stats,
            'buffer_size': len(self.buffer.buffer),
            'buffer_max_size': self.buffer.max_size,
            'flush_interval': self.buffer.flush_interval
        }