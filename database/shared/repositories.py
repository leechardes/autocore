"""
Repository Pattern usando SQLAlchemy ORM
Camada de abstração para acesso ao banco com ORM
"""
from typing import List, Optional, Dict, Any
from datetime import datetime
import json
import sys
from pathlib import Path

# Adiciona path para importar models
sys.path.append(str(Path(__file__).parent.parent))

from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy import create_engine, func, and_, or_
from src.models.models import (
    Base, Device, RelayBoard, RelayChannel, 
    TelemetryData, EventLog, Screen, ScreenItem,
    Theme, CANSignal, Macro, User
)

# Configuração da sessão
DATABASE_URL = f"sqlite:///{Path(__file__).parent.parent}/autocore.db"
engine = create_engine(DATABASE_URL, echo=False)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

class BaseRepository:
    """Repository base com operações comuns usando ORM"""
    
    def __init__(self):
        self.session = None
    
    def __enter__(self):
        self.session = SessionLocal()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            if exc_type:
                self.session.rollback()
            self.session.close()
    
    def get_session(self) -> Session:
        """Retorna sessão ativa ou cria uma nova"""
        if not self.session:
            self.session = SessionLocal()
        return self.session
    
    def commit(self):
        """Commit das mudanças"""
        if self.session:
            self.session.commit()
    
    def rollback(self):
        """Rollback das mudanças"""
        if self.session:
            self.session.rollback()

class DeviceRepository(BaseRepository):
    """Repository para dispositivos ESP32 usando ORM"""
    
    def get_all(self, active_only: bool = True) -> List[Device]:
        """Lista todos os dispositivos"""
        with SessionLocal() as session:
            query = session.query(Device)
            if active_only:
                query = query.filter(Device.is_active == True)
            return query.order_by(Device.name).all()
    
    def get_by_id(self, device_id: int) -> Optional[Device]:
        """Busca dispositivo por ID"""
        with SessionLocal() as session:
            return session.query(Device).filter(
                Device.id == device_id,
                Device.is_active == True
            ).first()
    
    def get_by_uuid(self, uuid: str) -> Optional[Device]:
        """Busca dispositivo por UUID"""
        with SessionLocal() as session:
            return session.query(Device).filter(
                Device.uuid == uuid,
                Device.is_active == True
            ).first()
    
    def create(self, device_data: Dict) -> Device:
        """Cria novo dispositivo"""
        with SessionLocal() as session:
            device = Device(
                uuid=device_data['uuid'],
                name=device_data['name'],
                type=device_data['type'],
                mac_address=device_data.get('mac_address'),
                ip_address=device_data.get('ip_address'),
                firmware_version=device_data.get('firmware_version'),
                hardware_version=device_data.get('hardware_version'),
                status='offline',
                configuration_json=json.dumps(device_data.get('configuration', {})),
                capabilities_json=json.dumps(device_data.get('capabilities', {}))
            )
            session.add(device)
            session.commit()
            session.refresh(device)
            return device
    
    def update_status(self, device_id: int, status: str, ip_address: str = None):
        """Atualiza status do dispositivo"""
        with SessionLocal() as session:
            device = session.query(Device).filter(Device.id == device_id).first()
            if device:
                device.status = status
                device.last_seen = datetime.now()
                if ip_address:
                    device.ip_address = ip_address
                session.commit()
    
    def update_config(self, device_id: int, config: Dict):
        """Atualiza configuração do dispositivo"""
        with SessionLocal() as session:
            device = session.query(Device).filter(Device.id == device_id).first()
            if device:
                device.configuration_json = json.dumps(config)
                session.commit()
    
    def update_capabilities(self, device_id: int, capabilities: Dict):
        """Atualiza capacidades do dispositivo"""
        with SessionLocal() as session:
            device = session.query(Device).filter(Device.id == device_id).first()
            if device:
                device.capabilities_json = json.dumps(capabilities)
                session.commit()
    
    def get_online_devices(self) -> List[Device]:
        """Lista dispositivos online"""
        with SessionLocal() as session:
            return session.query(Device).filter(
                Device.status == 'online',
                Device.is_active == True
            ).order_by(Device.last_seen.desc()).all()
    
    def delete(self, device_id: int):
        """Soft delete de dispositivo"""
        with SessionLocal() as session:
            device = session.query(Device).filter(Device.id == device_id).first()
            if device:
                device.is_active = False
                session.commit()

class RelayRepository(BaseRepository):
    """Repository para controle de relés usando ORM"""
    
    def get_boards(self, active_only: bool = True) -> List[RelayBoard]:
        """Lista todas as placas de relé"""
        with SessionLocal() as session:
            query = session.query(RelayBoard)
            if active_only:
                query = query.filter(RelayBoard.is_active == True)
            return query.order_by(RelayBoard.id).all()
    
    def get_boards_by_device(self, device_id: int) -> List[RelayBoard]:
        """Lista placas de relé de um dispositivo"""
        with SessionLocal() as session:
            return session.query(RelayBoard).filter(
                RelayBoard.device_id == device_id,
                RelayBoard.is_active == True
            ).order_by(RelayBoard.id).all()
    
    def get_channels(self, board_id: int = None) -> List[RelayChannel]:
        """Lista canais de relé"""
        with SessionLocal() as session:
            query = session.query(RelayChannel).filter(RelayChannel.is_active == True)
            if board_id:
                query = query.filter(RelayChannel.board_id == board_id)
            return query.order_by(RelayChannel.board_id, RelayChannel.channel_number).all()
    
    def get_channel(self, channel_id: int) -> Optional[RelayChannel]:
        """Busca um canal específico"""
        with SessionLocal() as session:
            return session.query(RelayChannel).filter(
                RelayChannel.id == channel_id,
                RelayChannel.is_active == True
            ).first()
    
    # Métodos de estado removidos - não são mais necessários na configuração
    # Os estados reais serão gerenciados pelo gateway/dispositivos
    
    def update_channel_config(self, channel_id: int, config_data: Dict):
        """Atualiza configurações de um canal (nome, descrição, ícone, etc.)"""
        with SessionLocal() as session:
            channel = session.query(RelayChannel).filter(
                RelayChannel.id == channel_id
            ).first()
            if channel:
                # Atualizar apenas campos fornecidos
                if 'name' in config_data:
                    channel.name = config_data['name']
                if 'description' in config_data:
                    channel.description = config_data['description']
                if 'function_type' in config_data:
                    channel.function_type = config_data['function_type']
                if 'icon' in config_data:
                    channel.icon = config_data['icon']
                if 'color' in config_data:
                    channel.color = config_data['color']
                if 'protection_mode' in config_data:
                    channel.protection_mode = config_data['protection_mode']
                if 'allow_in_macro' in config_data:
                    channel.allow_in_macro = config_data['allow_in_macro']
                
                session.commit()
                return True
            return False
    
    def reset_channel_config(self, channel_id: int):
        """Reseta configurações de um canal para valores padrão"""
        with SessionLocal() as session:
            channel = session.query(RelayChannel).filter(
                RelayChannel.id == channel_id
            ).first()
            if channel:
                # Resetar para configurações padrão
                channel.name = f"Canal {channel.channel_number}"
                channel.description = None
                channel.function_type = "toggle"
                channel.icon = "aux"
                channel.color = "#888888"
                channel.protection_mode = "none"
                
                session.commit()
                return True
            return False
    
    def deactivate_channel(self, channel_id: int):
        """Desativa um canal (soft delete)"""
        with SessionLocal() as session:
            channel = session.query(RelayChannel).filter(
                RelayChannel.id == channel_id
            ).first()
            if channel:
                channel.is_active = False
                session.commit()
                return True
            return False
    
    def activate_channel(self, channel_id: int):
        """Reativa um canal"""
        with SessionLocal() as session:
            channel = session.query(RelayChannel).filter(
                RelayChannel.id == channel_id
            ).first()
            if channel:
                channel.is_active = True
                session.commit()
                return True
            return False
    
    def create_board(self, board_data: Dict) -> RelayBoard:
        """Cria nova placa de relé"""
        session = SessionLocal()
        try:
            # Verificar se já existe placa para o mesmo dispositivo
            existing_board = session.query(RelayBoard).filter(
                RelayBoard.device_id == board_data['device_id'],
                RelayBoard.is_active == True
            ).first()
            
            if existing_board:
                # Desanexar da sessão atual e retornar dados simples
                session.expunge(existing_board)
                return existing_board
            
            # Criar nova placa
            board = RelayBoard(
                device_id=board_data['device_id'],
                total_channels=board_data['total_channels'],
                board_model=board_data.get('board_model')
            )
            session.add(board)
            session.flush()  # Para obter o ID
            
            # Criar canais
            for channel_num in range(1, board.total_channels + 1):
                channel = RelayChannel(
                    board_id=board.id,
                    channel_number=channel_num,
                    name=f"Canal {channel_num}",
                    description=None,
                    function_type="toggle",
                    icon="aux",
                    color="#888888",
                    protection_mode="none"
                )
                session.add(channel)
            
            session.commit()
            
            # Desanexar o objeto da sessão antes de retornar
            session.expunge(board)
            return board
            
        except Exception as e:
            session.rollback()
            raise e
        finally:
            session.close()
    
    def _create_default_channels(self, board, session):
        """Cria canais padrão para uma placa de relé"""
        # Verificar quais canais já existem
        existing_channels = session.query(RelayChannel).filter(
            RelayChannel.board_id == board.id
        ).all()
        existing_numbers = {ch.channel_number for ch in existing_channels}
        
        # Criar apenas canais que não existem
        for channel_num in range(1, board.total_channels + 1):
            if channel_num not in existing_numbers:
                channel = RelayChannel(
                    board_id=board.id,
                    channel_number=channel_num,
                    name=f"Canal {channel_num}",
                    description=None,
                    function_type="toggle",
                    icon="aux",
                    color="#888888",
                    protection_mode="none"
                )
                session.add(channel)
        
        if session.new:  # Só commit se houver novos itens
            session.commit()
    
    def create_channel(self, channel_data: Dict) -> RelayChannel:
        """Cria novo canal de relé"""
        with SessionLocal() as session:
            channel = RelayChannel(
                board_id=channel_data['board_id'],
                channel_number=channel_data['channel_number'],
                name=channel_data['name'],
                description=channel_data.get('description'),
                function_type=channel_data.get('function_type', 'toggle'),
                icon=channel_data.get('icon'),
                color=channel_data.get('color'),
                protection_mode=channel_data.get('protection_mode', 'none'),
                max_activation_time=channel_data.get('max_activation_time'),
                allow_in_macro=channel_data.get('allow_in_macro', True)
            )
            session.add(channel)
            session.commit()
            session.refresh(channel)
            return channel

class TelemetryRepository(BaseRepository):
    """Repository para dados de telemetria usando ORM"""
    
    def save(self, device_id: int, data_type: str, key: str, value: Any, unit: str = None):
        """Salva dados de telemetria"""
        with SessionLocal() as session:
            telemetry = TelemetryData(
                device_id=device_id,
                data_type=data_type,
                data_key=key,
                data_value=str(value),
                unit=unit,
                timestamp=datetime.now()
            )
            session.add(telemetry)
            session.commit()
    
    def get_latest(self, device_id: int, limit: int = 100) -> List[TelemetryData]:
        """Busca telemetria mais recente"""
        with SessionLocal() as session:
            return session.query(TelemetryData).filter(
                TelemetryData.device_id == device_id
            ).order_by(TelemetryData.timestamp.desc()).limit(limit).all()
    
    def get_by_timerange(self, device_id: int, hours: int = 24) -> List[TelemetryData]:
        """Busca telemetria por período"""
        with SessionLocal() as session:
            from datetime import timedelta
            cutoff = datetime.now() - timedelta(hours=hours)
            return session.query(TelemetryData).filter(
                TelemetryData.device_id == device_id,
                TelemetryData.timestamp > cutoff
            ).order_by(TelemetryData.timestamp.desc()).all()
    
    def cleanup_old_data(self, days: int = 7) -> int:
        """Remove telemetria antiga (manutenção)"""
        with SessionLocal() as session:
            from datetime import timedelta
            cutoff = datetime.now() - timedelta(days=days)
            deleted = session.query(TelemetryData).filter(
                TelemetryData.timestamp < cutoff
            ).delete()
            session.commit()
            return deleted

class EventRepository(BaseRepository):
    """Repository para logs de eventos usando ORM"""
    
    def log(self, event_type: str, source: str, action: str = None, 
            target: str = None, payload: Dict = None, user_id: int = None,
            status: str = 'success', error_message: str = None):
        """Registra evento no sistema"""
        with SessionLocal() as session:
            event = EventLog(
                event_type=event_type,
                source=source,
                target=target,
                action=action,
                payload=json.dumps(payload) if payload else None,
                user_id=user_id,
                status=status,
                error_message=error_message,
                timestamp=datetime.now()
            )
            session.add(event)
            session.commit()
    
    def get_recent(self, limit: int = 100) -> List[EventLog]:
        """Busca eventos recentes"""
        with SessionLocal() as session:
            return session.query(EventLog).order_by(
                EventLog.timestamp.desc()
            ).limit(limit).all()
    
    def get_by_device(self, device_id: int, limit: int = 50) -> List[EventLog]:
        """Busca eventos de um dispositivo"""
        with SessionLocal() as session:
            device_source = f"device_{device_id}"
            return session.query(EventLog).filter(
                or_(EventLog.source == device_source, 
                    EventLog.target == device_source)
            ).order_by(EventLog.timestamp.desc()).limit(limit).all()
    
    def cleanup_old_logs(self, days: int = 30) -> int:
        """Remove logs antigos (manutenção)"""
        with SessionLocal() as session:
            from datetime import timedelta
            cutoff = datetime.now() - timedelta(days=days)
            deleted = session.query(EventLog).filter(
                EventLog.timestamp < cutoff,
                ~EventLog.event_type.in_(['error', 'security'])
            ).delete()
            session.commit()
            return deleted

class ConfigRepository(BaseRepository):
    """Repository para configurações do sistema usando ORM"""
    
    def get_screens(self, visible_only: bool = True) -> List[Screen]:
        """Lista todas as telas"""
        with SessionLocal() as session:
            query = session.query(Screen)
            if visible_only:
                query = query.filter(Screen.is_visible == True)
            return query.order_by(Screen.position).all()
    
    def get_screen_items(self, screen_id: int) -> List[ScreenItem]:
        """Lista itens de uma tela"""
        with SessionLocal() as session:
            return session.query(ScreenItem).filter(
                ScreenItem.screen_id == screen_id,
                ScreenItem.is_active == True
            ).order_by(ScreenItem.position).all()
    
    def get_themes(self) -> List[Theme]:
        """Lista temas disponíveis"""
        with SessionLocal() as session:
            return session.query(Theme).filter(
                Theme.is_active == True
            ).order_by(Theme.is_default.desc(), Theme.name).all()
    
    def get_default_theme(self) -> Optional[Theme]:
        """Busca o tema padrão"""
        with SessionLocal() as session:
            return session.query(Theme).filter(
                Theme.is_active == True,
                Theme.is_default == True
            ).first()
    
    def get_can_signals(self, category: Optional[str] = None) -> List[CANSignal]:
        """Lista sinais CAN configurados"""
        with SessionLocal() as session:
            query = session.query(CANSignal).filter(
                CANSignal.is_active == True
            )
            if category:
                query = query.filter(CANSignal.category == category)
            return query.order_by(CANSignal.category, CANSignal.signal_name).all()
    
    def get_can_signal_by_id(self, signal_id: int) -> Optional[CANSignal]:
        """Busca sinal CAN por ID"""
        with SessionLocal() as session:
            return session.query(CANSignal).filter(
                CANSignal.id == signal_id
            ).first()
    
    def create_can_signal(self, signal_data: Dict) -> CANSignal:
        """Cria novo sinal CAN"""
        with SessionLocal() as session:
            signal = CANSignal(
                signal_name=signal_data['signal_name'],
                can_id=signal_data['can_id'],
                start_bit=signal_data['start_bit'],
                length_bits=signal_data['length_bits'],
                byte_order=signal_data.get('byte_order', 'big_endian'),
                data_type=signal_data.get('data_type', 'unsigned'),
                scale_factor=signal_data.get('scale_factor', 1.0),
                offset=signal_data.get('offset', 0.0),
                unit=signal_data.get('unit', ''),
                min_value=signal_data.get('min_value', 0.0),
                max_value=signal_data.get('max_value', 100.0),
                description=signal_data.get('description', ''),
                category=signal_data.get('category', 'motor'),
                is_active=signal_data.get('is_active', True)
            )
            session.add(signal)
            session.commit()
            session.refresh(signal)
            return signal
    
    def update_can_signal(self, signal_id: int, signal_data: Dict) -> Optional[CANSignal]:
        """Atualiza sinal CAN"""
        with SessionLocal() as session:
            signal = session.query(CANSignal).filter(CANSignal.id == signal_id).first()
            if not signal:
                return None
            
            # Atualiza campos fornecidos
            for key, value in signal_data.items():
                if hasattr(signal, key) and key not in ['id', 'created_at']:
                    setattr(signal, key, value)
            
            session.commit()
            session.refresh(signal)
            return signal
    
    def delete_can_signal(self, signal_id: int) -> bool:
        """Remove sinal CAN"""
        with SessionLocal() as session:
            signal = session.query(CANSignal).filter(CANSignal.id == signal_id).first()
            if not signal:
                return False
            
            session.delete(signal)
            session.commit()
            return True
    
    def seed_default_can_signals(self) -> int:
        """Popula banco com sinais CAN padrão da FuelTech"""
        with SessionLocal() as session:
            # Verifica se já existem sinais
            if session.query(CANSignal).count() > 0:
                return 0
            
            default_signals = [
                # Motor
                {'signal_name': 'RPM', 'can_id': '0x100', 'start_bit': 0, 'length_bits': 16, 'category': 'motor',
                 'unit': 'RPM', 'min_value': 0, 'max_value': 8000, 'description': 'Rotação do motor'},
                {'signal_name': 'TPS', 'can_id': '0x100', 'start_bit': 16, 'length_bits': 8, 'category': 'motor',
                 'unit': '%', 'min_value': 0, 'max_value': 100, 'scale_factor': 0.392, 'description': 'Posição do acelerador'},
                {'signal_name': 'MAP', 'can_id': '0x200', 'start_bit': 0, 'length_bits': 16, 'category': 'motor',
                 'unit': 'kPa', 'min_value': 0, 'max_value': 250, 'description': 'Pressão do coletor'},
                {'signal_name': 'IAT', 'can_id': '0x200', 'start_bit': 16, 'length_bits': 8, 'category': 'motor',
                 'unit': '°C', 'min_value': -40, 'max_value': 120, 'offset': -40, 'description': 'Temperatura do ar'},
                {'signal_name': 'ECT', 'can_id': '0x300', 'start_bit': 0, 'length_bits': 8, 'category': 'motor',
                 'unit': '°C', 'min_value': -40, 'max_value': 120, 'offset': -40, 'description': 'Temperatura do motor'},
                
                # Combustível
                {'signal_name': 'FuelPressure', 'can_id': '0x400', 'start_bit': 0, 'length_bits': 16, 'category': 'combustivel',
                 'unit': 'kPa', 'min_value': 0, 'max_value': 600, 'description': 'Pressão de combustível'},
                {'signal_name': 'Ethanol', 'can_id': '0x400', 'start_bit': 16, 'length_bits': 8, 'category': 'combustivel',
                 'unit': '%', 'min_value': 0, 'max_value': 100, 'scale_factor': 0.392, 'description': 'Percentual de etanol'},
                {'signal_name': 'FuelLevel', 'can_id': '0x400', 'start_bit': 24, 'length_bits': 8, 'category': 'combustivel',
                 'unit': '%', 'min_value': 0, 'max_value': 100, 'scale_factor': 0.392, 'description': 'Nível de combustível'},
                
                # Elétrico
                {'signal_name': 'Battery', 'can_id': '0x500', 'start_bit': 0, 'length_bits': 8, 'category': 'eletrico',
                 'unit': 'V', 'min_value': 10, 'max_value': 16, 'scale_factor': 0.1, 'description': 'Tensão da bateria'},
                {'signal_name': 'Lambda', 'can_id': '0x300', 'start_bit': 8, 'length_bits': 16, 'category': 'eletrico',
                 'unit': 'λ', 'min_value': 0.7, 'max_value': 1.3, 'scale_factor': 0.001, 'description': 'Fator lambda'},
                
                # Pressões
                {'signal_name': 'OilPressure', 'can_id': '0x500', 'start_bit': 8, 'length_bits': 8, 'category': 'pressoes',
                 'unit': 'bar', 'min_value': 0, 'max_value': 10, 'scale_factor': 0.039, 'description': 'Pressão do óleo'},
                {'signal_name': 'BoostPressure', 'can_id': '0x500', 'start_bit': 16, 'length_bits': 16, 'category': 'pressoes',
                 'unit': 'bar', 'min_value': -1, 'max_value': 3, 'scale_factor': 0.001, 'offset': -1, 'description': 'Pressão do turbo'},
                
                # Velocidade
                {'signal_name': 'Speed', 'can_id': '0x600', 'start_bit': 0, 'length_bits': 16, 'category': 'velocidade',
                 'unit': 'km/h', 'min_value': 0, 'max_value': 300, 'description': 'Velocidade do veículo'},
                {'signal_name': 'Gear', 'can_id': '0x600', 'start_bit': 16, 'length_bits': 8, 'category': 'velocidade',
                 'unit': '', 'min_value': 0, 'max_value': 6, 'description': 'Marcha atual'}
            ]
            
            count = 0
            for signal_data in default_signals:
                signal = CANSignal(**signal_data)
                session.add(signal)
                count += 1
            
            session.commit()
            return count
    
    def get_macros(self) -> List[Macro]:
        """Lista macros/automações"""
        with SessionLocal() as session:
            return session.query(Macro).filter(
                Macro.is_active == True
            ).order_by(Macro.name).all()
    
    def create_screen(self, screen_data: Dict) -> Screen:
        """Cria nova tela"""
        with SessionLocal() as session:
            screen = Screen(
                name=screen_data['name'],
                title=screen_data['title'],
                icon=screen_data.get('icon'),
                screen_type=screen_data.get('screen_type', 'control'),
                parent_id=screen_data.get('parent_id'),
                position=screen_data.get('position', 999)
            )
            session.add(screen)
            session.commit()
            session.refresh(screen)
            return screen
    
    def create_screen_item(self, item_data: Dict) -> ScreenItem:
        """Cria novo item de tela"""
        with SessionLocal() as session:
            item = ScreenItem(
                screen_id=item_data['screen_id'],
                item_type=item_data['item_type'],
                name=item_data['name'],
                label=item_data['label'],
                icon=item_data.get('icon'),
                position=item_data.get('position', 999),
                size_mobile=item_data.get('size_mobile', 'normal'),
                size_display_small=item_data.get('size_display_small', 'normal'),
                size_display_large=item_data.get('size_display_large', 'normal'),
                size_web=item_data.get('size_web', 'normal'),
                action_type=item_data.get('action_type'),
                action_target=item_data.get('action_target'),
                action_payload=item_data.get('action_payload'),
                relay_board_id=item_data.get('relay_board_id'),
                relay_channel_id=item_data.get('relay_channel_id'),
                data_source=item_data.get('data_source'),
                data_path=item_data.get('data_path'),
                data_format=item_data.get('data_format'),
                data_unit=item_data.get('data_unit'),
                is_active=item_data.get('is_active', True)
            )
            session.add(item)
            session.commit()
            session.refresh(item)
            return item
    
    def update_screen_item(self, item_id: int, item_data: Dict) -> Optional[ScreenItem]:
        """Atualiza item de tela"""
        with SessionLocal() as session:
            item = session.query(ScreenItem).filter(ScreenItem.id == item_id).first()
            if not item:
                return None
            
            # Atualiza campos fornecidos
            for key, value in item_data.items():
                if hasattr(item, key) and key != 'id':
                    setattr(item, key, value)
            
            session.commit()
            session.refresh(item)
            return item
    
    def delete_screen_item(self, item_id: int) -> bool:
        """Remove item de tela"""
        with SessionLocal() as session:
            item = session.query(ScreenItem).filter(ScreenItem.id == item_id).first()
            if not item:
                return False
            
            session.delete(item)
            session.commit()
            return True
    
    def save_backup(self) -> Dict:
        """Cria backup das configurações (não dos dados)"""
        with SessionLocal() as session:
            backup = {
                'timestamp': datetime.now().isoformat(),
                'version': '1.0.0',
                'devices': [self._to_dict(d) for d in session.query(Device).all()],
                'screens': [self._to_dict(s) for s in session.query(Screen).all()],
                'screen_items': [self._to_dict(si) for si in session.query(ScreenItem).all()],
                'relay_boards': [self._to_dict(rb) for rb in session.query(RelayBoard).all()],
                'relay_channels': [self._to_dict(rc) for rc in session.query(RelayChannel).all()],
                'themes': [self._to_dict(t) for t in session.query(Theme).all()],
                'can_signals': [self._to_dict(cs) for cs in session.query(CANSignal).all()],
                'macros': [self._to_dict(m) for m in session.query(Macro).all()]
            }
            return backup
    
    def _to_dict(self, obj) -> Dict:
        """Converte objeto SQLAlchemy para dict"""
        return {c.name: getattr(obj, c.name) for c in obj.__table__.columns}

# Instâncias singleton para facilitar uso
devices = DeviceRepository()
relays = RelayRepository()
telemetry = TelemetryRepository()
events = EventRepository()
config = ConfigRepository()
class MacroRepository:
    """Repository para Macros e Automações"""
    
    def __init__(self):
        from src.models.models import Macro
        self.Macro = Macro
    
    def get_all(self, active_only=True):
        """Lista todas as macros"""
        with SessionLocal() as session:
            query = session.query(self.Macro)
            if active_only:
                query = query.filter_by(is_active=True)
            return query.order_by(self.Macro.name).all()
    
    def get_by_id(self, macro_id):
        """Busca macro por ID"""
        with SessionLocal() as session:
            return session.query(self.Macro).filter_by(id=macro_id).first()
    
    def create(self, macro_data):
        """Cria nova macro"""
        with SessionLocal() as session:
            macro = self.Macro(
                name=macro_data.get('name'),
                description=macro_data.get('description'),
                trigger_type=macro_data.get('trigger_type', 'manual'),
                trigger_config=macro_data.get('trigger_config'),
                action_sequence=macro_data.get('action_sequence'),
                condition_logic=macro_data.get('condition_logic'),
                is_active=macro_data.get('is_active', True)
            )
            session.add(macro)
            session.commit()
            session.refresh(macro)
            return macro
    
    def update(self, macro_id, update_data):
        """Atualiza macro existente"""
        with SessionLocal() as session:
            macro = session.query(self.Macro).filter_by(id=macro_id).first()
            if not macro:
                return None
            
            # Atualizar campos
            for key, value in update_data.items():
                if hasattr(macro, key) and value is not None:
                    setattr(macro, key, value)
            
            session.commit()
            session.refresh(macro)
            return macro
    
    def delete(self, macro_id):
        """Remove macro"""
        with SessionLocal() as session:
            macro = session.query(self.Macro).filter_by(id=macro_id).first()
            if not macro:
                return False
            
            session.delete(macro)
            session.commit()
            return True
    
    def execute(self, macro_id):
        """Registra execução de macro"""
        from datetime import datetime
        with SessionLocal() as session:
            macro = session.query(self.Macro).filter_by(id=macro_id).first()
            if macro:
                macro.last_executed = datetime.now()
                macro.execution_count = (macro.execution_count or 0) + 1
                session.commit()
                session.refresh(macro)
            return macro

macros = MacroRepository()