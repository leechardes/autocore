"""
Configurações do AutoCore Gateway
Carrega configurações de variáveis de ambiente
"""
import os
from dataclasses import dataclass
from typing import Optional
from pathlib import Path

@dataclass
class Config:
    """Configurações do Gateway"""
    
    # MQTT Settings
    MQTT_BROKER: str = os.getenv('MQTT_BROKER', 'localhost')
    MQTT_PORT: int = int(os.getenv('MQTT_PORT', '1883'))
    MQTT_USERNAME: Optional[str] = os.getenv('MQTT_USERNAME')
    MQTT_PASSWORD: Optional[str] = os.getenv('MQTT_PASSWORD')
    MQTT_CLIENT_ID: str = os.getenv('MQTT_CLIENT_ID', 'autocore-gateway')
    MQTT_KEEPALIVE: int = int(os.getenv('MQTT_KEEPALIVE', '60'))
    
    # Database Settings
    DATABASE_PATH: str = os.getenv('DATABASE_PATH', str(Path(__file__).parent.parent.parent.parent / 'database' / 'autocore.db'))
    
    # Logging Settings
    LOG_LEVEL: str = os.getenv('LOG_LEVEL', 'INFO')
    LOG_FILE: Optional[str] = os.getenv('LOG_FILE', '/tmp/autocore-gateway.log')
    
    # Performance Settings
    MAX_CONCURRENT_MESSAGES: int = int(os.getenv('MAX_CONCURRENT_MESSAGES', '100'))
    MESSAGE_TIMEOUT: int = int(os.getenv('MESSAGE_TIMEOUT', '30'))
    DEVICE_TIMEOUT: int = int(os.getenv('DEVICE_TIMEOUT', '300'))  # 5 minutos
    
    # Telemetry Settings
    TELEMETRY_BATCH_SIZE: int = int(os.getenv('TELEMETRY_BATCH_SIZE', '10'))
    TELEMETRY_FLUSH_INTERVAL: int = int(os.getenv('TELEMETRY_FLUSH_INTERVAL', '5'))  # segundos
    
    # Security Settings
    ENABLE_AUTH: bool = os.getenv('ENABLE_AUTH', 'true').lower() == 'true'
    SECRET_KEY: str = os.getenv('SECRET_KEY', 'autocore-secret-key-change-in-production')
    
    def __post_init__(self):
        """Validações pós-inicialização"""
        # Verificar se database existe
        db_path = Path(self.DATABASE_PATH)
        if not db_path.exists():
            raise FileNotFoundError(f"Database não encontrado: {self.DATABASE_PATH}")
        
        # Criar diretório de logs se necessário
        if self.LOG_FILE:
            log_path = Path(self.LOG_FILE)
            log_path.parent.mkdir(parents=True, exist_ok=True)
    
    @property
    def mqtt_topics(self) -> dict:
        """Tópicos MQTT do sistema"""
        return {
            # Device Management
            'device_announce': 'autocore/devices/+/announce',
            'device_status': 'autocore/devices/+/status',
            'device_command': 'autocore/devices/+/command',
            'device_response': 'autocore/devices/+/response',
            
            # Telemetry
            'telemetry_data': 'autocore/devices/+/telemetry',
            
            # Relay Control  
            'relay_command': 'autocore/devices/+/relay/command',
            'relay_status': 'autocore/devices/+/relay/status',
            
            # System
            'gateway_status': 'autocore/gateway/status',
            'system_broadcast': 'autocore/system/broadcast',
            
            # Discovery
            'device_discovery': 'autocore/discovery/+',
        }
    
    @property
    def SUBSCRIPTION_TOPICS(self) -> list:
        """Lista de tópicos para subscrição"""
        return [
            'autocore/devices/+/announce',
            'autocore/devices/+/status',
            'autocore/devices/+/telemetry',
            'autocore/devices/+/response',
            'autocore/devices/+/relay/status',
            'autocore/discovery/+',
        ]
    
    def get_device_topic(self, device_uuid: str, topic_type: str) -> str:
        """Gera tópico específico para um dispositivo"""
        topic_patterns = {
            'command': f'autocore/devices/{device_uuid}/command',
            'status': f'autocore/devices/{device_uuid}/status',
            'telemetry': f'autocore/devices/{device_uuid}/telemetry',
            'relay_command': f'autocore/devices/{device_uuid}/relay/command',
            'relay_status': f'autocore/devices/{device_uuid}/relay/status',
            'response': f'autocore/devices/{device_uuid}/response',
        }
        
        if topic_type not in topic_patterns:
            raise ValueError(f"Tipo de tópico inválido: {topic_type}")
        
        return topic_patterns[topic_type]
    
    def is_valid_device_topic(self, topic: str) -> bool:
        """Verifica se o tópico é válido para dispositivo"""
        parts = topic.split('/')
        return (
            len(parts) >= 3 and
            parts[0] == 'autocore' and
            parts[1] == 'devices' and
            len(parts[2]) > 0  # UUID não vazio
        )