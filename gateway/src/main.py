#!/usr/bin/env python3
"""
AutoCore Gateway - MQTT Communication Hub
Responsável pela comunicação MQTT com dispositivos ESP32
Usa database compartilhado para persistência
"""
import asyncio
import logging
import sys
import signal
import json
from pathlib import Path
from typing import Dict, Any
from datetime import datetime

# Adicionar path do database compartilhado
sys.path.append(str(Path(__file__).parent.parent.parent / "database"))

from core.mqtt_client import MQTTClient
from core.message_handler import MessageHandler
from core.device_manager import DeviceManager
from services.telemetry_service import TelemetryService
from core.config import Config
from shared.repositories import devices, telemetry, events

# Configuração de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('/tmp/autocore-gateway.log')
    ]
)

logger = logging.getLogger(__name__)

class AutoCoreGateway:
    """Gateway principal do sistema AutoCore"""
    
    def __init__(self):
        self.config = Config()
        self.running = False
        self.mqtt_client = None
        self.message_handler = None
        self.device_manager = None
        self.telemetry_service = None
        
    async def initialize(self):
        """Inicializa todos os componentes do gateway"""
        try:
            logger.info("🚀 Inicializando AutoCore Gateway...")
            
            # Verificar conexão com database
            await self._check_database_connection()
            
            # Inicializar serviços
            self.device_manager = DeviceManager()
            self.telemetry_service = TelemetryService()
            
            # Inicializar handler de mensagens
            self.message_handler = MessageHandler(
                device_manager=self.device_manager,
                telemetry_service=self.telemetry_service
            )
            
            # Inicializar cliente MQTT
            self.mqtt_client = MQTTClient(
                config=self.config,
                message_handler=self.message_handler
            )
            
            logger.info("✅ Componentes inicializados com sucesso")
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização: {e}")
            raise
    
    async def _check_database_connection(self):
        """Verifica conexão com o database"""
        try:
            # Testa conexão básica
            device_count = len(devices.get_all())
            logger.info(f"📊 Database conectado - {device_count} dispositivos cadastrados")
            
            # Log evento de startup
            events.log(
                event_type='system',
                source='gateway',
                action='startup',
                payload={'timestamp': datetime.now().isoformat()}
            )
            
        except Exception as e:
            logger.error(f"❌ Erro conexão database: {e}")
            raise
    
    async def start(self):
        """Inicia o gateway"""
        try:
            logger.info("🔄 Iniciando AutoCore Gateway...")
            self.running = True
            
            # Conectar ao broker MQTT
            await self.mqtt_client.connect()
            
            # Configurar handlers de sinal
            self._setup_signal_handlers()
            
            logger.info("🚀 AutoCore Gateway rodando!")
            logger.info(f"📡 MQTT Broker: {self.config.MQTT_BROKER}:{self.config.MQTT_PORT}")
            
            # Loop principal
            await self._main_loop()
            
        except Exception as e:
            logger.error(f"❌ Erro ao iniciar gateway: {e}")
            await self.shutdown()
            raise
    
    async def _main_loop(self):
        """Loop principal do gateway"""
        try:
            while self.running:
                # Heartbeat
                await self._heartbeat()
                
                # Verificar dispositivos offline
                await self.device_manager.check_offline_devices()
                
                # Sleep
                await asyncio.sleep(30)  # 30s
                
        except asyncio.CancelledError:
            logger.info("📴 Loop principal cancelado")
        except Exception as e:
            logger.error(f"❌ Erro no loop principal: {e}")
            self.running = False
    
    async def _heartbeat(self):
        """Envia heartbeat do gateway"""
        try:
            payload = {
                'timestamp': datetime.now().isoformat(),
                'status': 'online',
                'uptime': self._get_uptime(),
                'devices_online': len(devices.get_online_devices()),
                'memory_usage': self._get_memory_usage()
            }
            
            await self.mqtt_client.publish(
                'autocore/gateway/status',
                json.dumps(payload),
                qos=0,
                retain=True
            )
            
        except Exception as e:
            logger.error(f"❌ Erro no heartbeat: {e}")
    
    def _get_uptime(self) -> int:
        """Retorna uptime em segundos"""
        if not hasattr(self, 'start_time'):
            self.start_time = datetime.now()
        return int((datetime.now() - self.start_time).total_seconds())
    
    def _get_memory_usage(self) -> Dict[str, Any]:
        """Retorna uso de memória"""
        import psutil
        process = psutil.Process()
        return {
            'ram_mb': round(process.memory_info().rss / 1024 / 1024, 1),
            'cpu_percent': process.cpu_percent()
        }
    
    def _setup_signal_handlers(self):
        """Configura handlers de sinal para shutdown graceful"""
        def signal_handler(signum, frame):
            logger.info(f"📴 Recebido sinal {signum}, iniciando shutdown...")
            asyncio.create_task(self.shutdown())
        
        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
    
    async def shutdown(self):
        """Para o gateway gracefully"""
        try:
            logger.info("📴 Parando AutoCore Gateway...")
            self.running = False
            
            # Publicar status offline
            if self.mqtt_client:
                await self.mqtt_client.publish(
                    'autocore/gateway/status',
                    json.dumps({
                        'timestamp': datetime.now().isoformat(),
                        'status': 'offline'
                    }),
                    qos=0,
                    retain=True
                )
            
            # Desconectar MQTT
            if self.mqtt_client:
                await self.mqtt_client.disconnect()
            
            # Log evento de shutdown
            events.log(
                event_type='system',
                source='gateway',
                action='shutdown',
                payload={'timestamp': datetime.now().isoformat()}
            )
            
            logger.info("✅ Gateway parado com sucesso")
            
        except Exception as e:
            logger.error(f"❌ Erro no shutdown: {e}")

async def main():
    """Função principal"""
    gateway = None
    try:
        # Criar e inicializar gateway
        gateway = AutoCoreGateway()
        await gateway.initialize()
        
        # Iniciar gateway
        await gateway.start()
        
    except KeyboardInterrupt:
        logger.info("📴 Interrompido pelo usuário")
    except Exception as e:
        logger.error(f"❌ Erro fatal: {e}")
        return 1
    finally:
        if gateway:
            await gateway.shutdown()
    
    return 0

if __name__ == "__main__":
    exit_code = asyncio.run(main())