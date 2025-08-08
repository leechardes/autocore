#!/usr/bin/env python3
"""
Seeds de desenvolvimento para AutoCore usando SQLAlchemy ORM
Data: 07 de agosto de 2025
Objetivo: Dados realistas para desenvolvimento e testes
"""
import sys
from pathlib import Path
from datetime import datetime, timedelta
import json

# Adiciona path para importar models
sys.path.append(str(Path(__file__).parent.parent))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from src.models.models import (
    Base, Device, RelayBoard, RelayChannel, 
    TelemetryData, EventLog, Screen, ScreenItem,
    Theme, CANSignal, Macro, User
)

DATABASE_URL = f"sqlite:///{Path(__file__).parent.parent}/autocore.db"
engine = create_engine(DATABASE_URL, echo=False)
Session = sessionmaker(bind=engine)

def clear_database(session):
    """Limpa dados existentes na ordem correta"""
    print("🗑️  Limpando dados existentes...")
    
    # Ordem de deleção respeitando foreign keys
    session.query(ScreenItem).delete()
    session.query(Screen).delete()
    session.query(RelayChannel).delete()
    session.query(RelayBoard).delete()
    session.query(TelemetryData).delete()
    session.query(EventLog).delete()
    session.query(Device).delete()
    session.query(User).delete()
    session.query(Theme).delete()
    session.query(CANSignal).delete()
    session.query(Macro).delete()
    session.commit()
    print("✓ Dados anteriores removidos")

def seed_users(session):
    """Cria usuários do sistema"""
    print("\n👤 Criando usuários...")
    
    users = [
        User(
            id=1,
            username='admin',
            password_hash='$2b$12$LQi3c8zc8Jc8zc8Jc8zc8u',  # Hash fictício
            full_name='Administrador',
            email='admin@autocore.local',
            role='admin',
            pin_code='1234',
            is_active=True
        ),
        User(
            id=2,
            username='lee',
            password_hash='$2b$12$LQi3c8zc8Jc8zc8Jc8zc8u',
            full_name='Lee Chardes',
            email='lee@autocore.local',
            role='admin',
            pin_code='4321',
            is_active=True
        ),
        User(
            id=3,
            username='operador',
            password_hash='$2b$12$LQi3c8zc8Jc8zc8Jc8zc8u',
            full_name='Operador Padrão',
            email='operador@autocore.local',
            role='operator',
            pin_code='0000',
            is_active=True
        )
    ]
    
    session.add_all(users)
    session.commit()
    print(f"✓ {len(users)} usuários criados")

def seed_devices(session):
    """Cria dispositivos ESP32"""
    print("\n📱 Criando dispositivos...")
    
    devices = [
        Device(
            id=1,
            uuid='esp32-relay-001',
            name='Central de Relés',
            type='esp32_relay',
            mac_address='AA:BB:CC:DD:EE:01',
            ip_address='192.168.1.101',
            firmware_version='v1.0.0',
            hardware_version='rev2',
            status='online',
            last_seen=datetime.now(),
            configuration_json=json.dumps({
                "relay_count": 16,
                "mqtt_topic": "autocore/relay/001"
            }),
            capabilities_json=json.dumps({
                "relay_control": True,
                "status_report": True,
                "ota_update": True
            }),
            is_active=True
        ),
        Device(
            id=2,
            uuid='esp32-display-001',
            name='Display Principal',
            type='esp32_display',
            mac_address='AA:BB:CC:DD:EE:02',
            ip_address='192.168.1.102',
            firmware_version='v1.0.0',
            hardware_version='rev1',
            status='online',
            last_seen=datetime.now(),
            configuration_json=json.dumps({
                "screen_size": "7inch",
                "resolution": "800x480",
                "touch": True,
                "mqtt_topic": "autocore/display/001"
            }),
            capabilities_json=json.dumps({
                "touch_input": True,
                "screen_render": True,
                "brightness_control": True
            }),
            is_active=True
        ),
        Device(
            id=3,
            uuid='esp32-controls-001',
            name='Painel de Controle',
            type='esp32_controls',
            mac_address='AA:BB:CC:DD:EE:03',
            ip_address='192.168.1.103',
            firmware_version='v1.0.0',
            hardware_version='rev1',
            status='online',
            last_seen=datetime.now(),
            configuration_json=json.dumps({
                "button_count": 12,
                "led_count": 12,
                "mqtt_topic": "autocore/controls/001"
            }),
            capabilities_json=json.dumps({
                "button_input": True,
                "led_output": True,
                "encoder_input": True
            }),
            is_active=True
        ),
        Device(
            id=4,
            uuid='esp32-can-001',
            name='Interface CAN',
            type='esp32_can',
            mac_address='AA:BB:CC:DD:EE:04',
            ip_address='192.168.1.104',
            firmware_version='v1.0.0',
            hardware_version='rev1',
            status='online',
            last_seen=datetime.now(),
            configuration_json=json.dumps({
                "can_speed": 500000,
                "mqtt_topic": "autocore/can/001"
            }),
            capabilities_json=json.dumps({
                "can_read": True,
                "can_write": True,
                "obd2": True
            }),
            is_active=True
        ),
        Device(
            id=5,
            uuid='gateway-001',
            name='Gateway Principal',
            type='gateway',
            mac_address='AA:BB:CC:DD:EE:05',
            ip_address='192.168.1.100',
            firmware_version='v1.0.0',
            hardware_version='pi-zero-2w',
            status='online',
            last_seen=datetime.now(),
            configuration_json=json.dumps({
                "mqtt_broker": "localhost",
                "mqtt_port": 1883
            }),
            capabilities_json=json.dumps({
                "mqtt_bridge": True,
                "database": True,
                "api": True
            }),
            is_active=True
        )
    ]
    
    session.add_all(devices)
    session.commit()
    print(f"✓ {len(devices)} dispositivos criados")

def seed_relay_boards_and_channels(session):
    """Cria placas e canais de relé"""
    print("\n⚡ Criando relés...")
    
    # Placa principal
    board = RelayBoard(
        id=1,
        device_id=1,
        name='Placa Principal',
        total_channels=16,
        board_model='RELAY16CH-12V',
        location='Painel Central',
        is_active=True
    )
    session.add(board)
    session.commit()
    
    # Canais
    channels = [
        # Iluminação
        RelayChannel(id=1, board_id=1, channel_number=1, name='Farol Alto', description='Farol alto principal', 
                    function_type='toggle', default_state=False, current_state=False, icon='light-high', 
                    color='#FFFF00', protection_mode='none', max_activation_time=None),
        RelayChannel(id=2, board_id=1, channel_number=2, name='Farol Baixo', description='Farol baixo principal', 
                    function_type='toggle', default_state=False, current_state=False, icon='light-low', 
                    color='#FFFFAA', protection_mode='none', max_activation_time=None),
        RelayChannel(id=3, board_id=1, channel_number=3, name='Milha', description='Farol de milha', 
                    function_type='toggle', default_state=False, current_state=False, icon='light-fog', 
                    color='#FFFF88', protection_mode='none', max_activation_time=None),
        RelayChannel(id=4, board_id=1, channel_number=4, name='Strobo', description='Luzes de emergência', 
                    function_type='toggle', default_state=False, current_state=False, icon='light-emergency', 
                    color='#FF0000', protection_mode='confirm', max_activation_time=300),
        
        # Acessórios
        RelayChannel(id=5, board_id=1, channel_number=5, name='Guincho', description='Guincho elétrico', 
                    function_type='momentary', default_state=False, current_state=False, icon='winch', 
                    color='#FFA500', protection_mode='password', max_activation_time=60),
        RelayChannel(id=6, board_id=1, channel_number=6, name='Compressor', description='Compressor de ar', 
                    function_type='toggle', default_state=False, current_state=False, icon='air-compressor', 
                    color='#00AAFF', protection_mode='confirm', max_activation_time=600),
        RelayChannel(id=7, board_id=1, channel_number=7, name='Inversor', description='Inversor 110V/220V', 
                    function_type='toggle', default_state=False, current_state=False, icon='power-inverter', 
                    color='#00FF00', protection_mode='none', max_activation_time=None),
        RelayChannel(id=8, board_id=1, channel_number=8, name='Rádio VHF', description='Rádio comunicação', 
                    function_type='toggle', default_state=False, current_state=False, icon='radio', 
                    color='#8888FF', protection_mode='none', max_activation_time=None),
        
        # Sistemas
        RelayChannel(id=9, board_id=1, channel_number=9, name='Bomba Combustível', description='Bomba de combustível auxiliar', 
                    function_type='toggle', default_state=False, current_state=False, icon='fuel-pump', 
                    color='#AA5500', protection_mode='password', max_activation_time=None),
        RelayChannel(id=10, board_id=1, channel_number=10, name='Ventoinha Extra', description='Ventoinha adicional radiador', 
                    function_type='toggle', default_state=False, current_state=False, icon='fan', 
                    color='#00FFFF', protection_mode='none', max_activation_time=None),
        RelayChannel(id=11, board_id=1, channel_number=11, name='Trava Diferencial', description='Bloqueio do diferencial', 
                    function_type='toggle', default_state=False, current_state=False, icon='diff-lock', 
                    color='#FF8800', protection_mode='confirm', max_activation_time=None),
        RelayChannel(id=12, board_id=1, channel_number=12, name='Câmera Ré', description='Sistema de câmera de ré', 
                    function_type='toggle', default_state=False, current_state=False, icon='camera', 
                    color='#AA00FF', protection_mode='none', max_activation_time=None),
        
        # Reserva
        RelayChannel(id=13, board_id=1, channel_number=13, name='Aux 1', description='Auxiliar 1', 
                    function_type='toggle', default_state=False, current_state=False, icon='aux', 
                    color='#888888', protection_mode='none', max_activation_time=None),
        RelayChannel(id=14, board_id=1, channel_number=14, name='Aux 2', description='Auxiliar 2', 
                    function_type='toggle', default_state=False, current_state=False, icon='aux', 
                    color='#888888', protection_mode='none', max_activation_time=None),
        RelayChannel(id=15, board_id=1, channel_number=15, name='Aux 3', description='Auxiliar 3', 
                    function_type='toggle', default_state=False, current_state=False, icon='aux', 
                    color='#888888', protection_mode='none', max_activation_time=None),
        RelayChannel(id=16, board_id=1, channel_number=16, name='Aux 4', description='Auxiliar 4', 
                    function_type='toggle', default_state=False, current_state=False, icon='aux', 
                    color='#888888', protection_mode='none', max_activation_time=None),
    ]
    
    session.add_all(channels)
    session.commit()
    print(f"✓ 1 placa e {len(channels)} canais criados")

def seed_themes(session):
    """Cria temas do sistema"""
    print("\n🎨 Criando temas...")
    
    themes = [
        Theme(
            id=1,
            name='Dark Offroad',
            description='Tema escuro para uso offroad',
            primary_color='#FF6B35',
            secondary_color='#F7931E',
            background_color='#1A1A1A',
            surface_color='#2D2D2D',
            success_color='#4CAF50',
            warning_color='#FFC107',
            error_color='#F44336',
            info_color='#2196F3',
            text_primary='#FFFFFF',
            text_secondary='#B0B0B0',
            border_radius=12,
            shadow_style='elevated',
            font_family='Inter, system-ui',
            is_active=True,
            is_default=True
        ),
        Theme(
            id=2,
            name='Light',
            description='Tema claro para uso diário',
            primary_color='#2196F3',
            secondary_color='#03A9F4',
            background_color='#FFFFFF',
            surface_color='#F5F5F5',
            success_color='#4CAF50',
            warning_color='#FF9800',
            error_color='#F44336',
            info_color='#00BCD4',
            text_primary='#212121',
            text_secondary='#757575',
            border_radius=8,
            shadow_style='subtle',
            font_family='Inter, system-ui',
            is_active=True,
            is_default=False
        )
    ]
    
    session.add_all(themes)
    session.commit()
    print(f"✓ {len(themes)} temas criados")

def seed_screens_and_items(session):
    """Cria telas e itens de interface"""
    print("\n📱 Criando telas e itens...")
    
    # Telas
    screens = [
        Screen(id=1, name='home', title='Início', icon='home', screen_type='dashboard', parent_id=None, 
               position=1, columns_mobile=2, columns_display_small=3, columns_display_large=4, columns_web=6, 
               is_visible=True, required_permission=None, show_on_mobile=True, show_on_display_small=True, 
               show_on_display_large=True, show_on_web=True, show_on_controls=False),
        Screen(id=2, name='lights', title='Iluminação', icon='lightbulb', screen_type='control', parent_id=None, 
               position=2, columns_mobile=2, columns_display_small=3, columns_display_large=4, columns_web=4, 
               is_visible=True, required_permission=None, show_on_mobile=True, show_on_display_small=True, 
               show_on_display_large=True, show_on_web=True, show_on_controls=True),
        Screen(id=3, name='accessories', title='Acessórios', icon='tools', screen_type='control', parent_id=None, 
               position=3, columns_mobile=2, columns_display_small=3, columns_display_large=4, columns_web=4, 
               is_visible=True, required_permission=None, show_on_mobile=True, show_on_display_small=True, 
               show_on_display_large=True, show_on_web=True, show_on_controls=True),
        Screen(id=4, name='systems', title='Sistemas', icon='settings', screen_type='control', parent_id=None, 
               position=4, columns_mobile=2, columns_display_small=3, columns_display_large=4, columns_web=4, 
               is_visible=True, required_permission='operator', show_on_mobile=True, show_on_display_small=True, 
               show_on_display_large=True, show_on_web=True, show_on_controls=False),
        Screen(id=5, name='diagnostics', title='Diagnóstico', icon='chart', screen_type='dashboard', parent_id=None, 
               position=5, columns_mobile=1, columns_display_small=2, columns_display_large=3, columns_web=4, 
               is_visible=True, required_permission='admin', show_on_mobile=True, show_on_display_small=True, 
               show_on_display_large=True, show_on_web=True, show_on_controls=False)
    ]
    
    session.add_all(screens)
    session.commit()
    
    # Itens das telas
    items = [
        # Tela Home
        ScreenItem(id=1, screen_id=1, item_type='display', name='speed', label='Velocidade', icon='speedometer', 
                  position=1, size_mobile='large', size_display_small='large', size_display_large='large', size_web='normal', 
                  action_type=None, action_target=None, action_payload=None, data_source='can', data_path='speed', 
                  data_format='number', data_unit='km/h'),
        ScreenItem(id=2, screen_id=1, item_type='display', name='rpm', label='RPM', icon='tachometer', 
                  position=2, size_mobile='large', size_display_small='large', size_display_large='large', size_web='normal', 
                  action_type=None, action_target=None, action_payload=None, data_source='can', data_path='rpm', 
                  data_format='number', data_unit='rpm'),
        ScreenItem(id=3, screen_id=1, item_type='display', name='temp', label='Temperatura', icon='thermometer', 
                  position=3, size_mobile='normal', size_display_small='normal', size_display_large='normal', size_web='normal', 
                  action_type=None, action_target=None, action_payload=None, data_source='can', data_path='coolant_temp', 
                  data_format='number', data_unit='°C'),
        ScreenItem(id=4, screen_id=1, item_type='display', name='fuel', label='Combustível', icon='fuel', 
                  position=4, size_mobile='normal', size_display_small='normal', size_display_large='normal', size_web='normal', 
                  action_type=None, action_target=None, action_payload=None, data_source='can', data_path='fuel_level', 
                  data_format='percentage', data_unit='%'),
        
        # Tela Iluminação
        ScreenItem(id=5, screen_id=2, item_type='button', name='btn_farol_alto', label='Farol Alto', icon='light-high', 
                  position=1, size_mobile='large', size_display_small='normal', size_display_large='normal', size_web='normal', 
                  action_type='relay', action_target='1', action_payload='{"toggle": true}', 
                  data_source=None, data_path=None, data_format=None, data_unit=None),
        ScreenItem(id=6, screen_id=2, item_type='button', name='btn_farol_baixo', label='Farol Baixo', icon='light-low', 
                  position=2, size_mobile='large', size_display_small='normal', size_display_large='normal', size_web='normal', 
                  action_type='relay', action_target='2', action_payload='{"toggle": true}', 
                  data_source=None, data_path=None, data_format=None, data_unit=None),
        ScreenItem(id=7, screen_id=2, item_type='button', name='btn_milha', label='Milha', icon='light-fog', 
                  position=3, size_mobile='large', size_display_small='normal', size_display_large='normal', size_web='normal', 
                  action_type='relay', action_target='3', action_payload='{"toggle": true}', 
                  data_source=None, data_path=None, data_format=None, data_unit=None),
        ScreenItem(id=8, screen_id=2, item_type='button', name='btn_strobo', label='Strobo', icon='light-emergency', 
                  position=4, size_mobile='large', size_display_small='normal', size_display_large='normal', size_web='normal', 
                  action_type='relay', action_target='4', action_payload='{"toggle": true}', 
                  data_source=None, data_path=None, data_format=None, data_unit=None),
        
        # Tela Acessórios
        ScreenItem(id=9, screen_id=3, item_type='button', name='btn_guincho', label='Guincho', icon='winch', 
                  position=1, size_mobile='large', size_display_small='large', size_display_large='normal', size_web='normal', 
                  action_type='relay', action_target='5', action_payload='{"momentary": true}', 
                  data_source=None, data_path=None, data_format=None, data_unit=None),
        ScreenItem(id=10, screen_id=3, item_type='button', name='btn_compressor', label='Compressor', icon='air-compressor', 
                  position=2, size_mobile='large', size_display_small='normal', size_display_large='normal', size_web='normal', 
                  action_type='relay', action_target='6', action_payload='{"toggle": true}', 
                  data_source=None, data_path=None, data_format=None, data_unit=None),
        ScreenItem(id=11, screen_id=3, item_type='button', name='btn_inversor', label='Inversor 110V', icon='power-inverter', 
                  position=3, size_mobile='large', size_display_small='normal', size_display_large='normal', size_web='normal', 
                  action_type='relay', action_target='7', action_payload='{"toggle": true}', 
                  data_source=None, data_path=None, data_format=None, data_unit=None),
        ScreenItem(id=12, screen_id=3, item_type='button', name='btn_radio', label='Rádio VHF', icon='radio', 
                  position=4, size_mobile='large', size_display_small='normal', size_display_large='normal', size_web='normal', 
                  action_type='relay', action_target='8', action_payload='{"toggle": true}', 
                  data_source=None, data_path=None, data_format=None, data_unit=None)
    ]
    
    session.add_all(items)
    session.commit()
    print(f"✓ {len(screens)} telas e {len(items)} itens criados")

def seed_can_signals(session):
    """Cria sinais CAN"""
    print("\n🚗 Criando sinais CAN...")
    
    signals = [
        CANSignal(id=1, signal_name='speed', can_id='0x3E8', start_bit=0, length_bits=16, 
                 byte_order='big_endian', data_type='unsigned', scale_factor=0.1, offset=0, 
                 unit='km/h', min_value=0, max_value=300, description='Velocidade do veículo', category='motion'),
        CANSignal(id=2, signal_name='rpm', can_id='0x3E9', start_bit=0, length_bits=16, 
                 byte_order='big_endian', data_type='unsigned', scale_factor=1, offset=0, 
                 unit='rpm', min_value=0, max_value=8000, description='Rotação do motor', category='engine'),
        CANSignal(id=3, signal_name='coolant_temp', can_id='0x3EA', start_bit=0, length_bits=8, 
                 byte_order='big_endian', data_type='signed', scale_factor=1, offset=-40, 
                 unit='°C', min_value=-40, max_value=150, description='Temperatura do líquido de arrefecimento', category='engine'),
        CANSignal(id=4, signal_name='fuel_level', can_id='0x3EB', start_bit=0, length_bits=8, 
                 byte_order='big_endian', data_type='unsigned', scale_factor=0.392, offset=0, 
                 unit='%', min_value=0, max_value=100, description='Nível de combustível', category='fuel')
    ]
    
    session.add_all(signals)
    session.commit()
    print(f"✓ {len(signals)} sinais CAN criados")

def seed_macros(session):
    """Cria macros/automações"""
    print("\n⚙️  Criando macros...")
    
    macros = [
        Macro(
            id=1,
            name='Modo Trilha',
            description='Ativa configurações para trilha',
            trigger_type='manual',
            trigger_config='{}',
            action_sequence=json.dumps([
                {"type": "relay", "target": "3", "action": "on"},
                {"type": "relay", "target": "10", "action": "on"}
            ]),
            condition_logic=None,
            is_active=True,
            execution_count=0
        ),
        Macro(
            id=2,
            name='Emergência',
            description='Ativa luzes de emergência',
            trigger_type='manual',
            trigger_config='{}',
            action_sequence=json.dumps([
                {"type": "relay", "target": "4", "action": "on"},
                {"type": "relay", "target": "1", "action": "flash"}
            ]),
            condition_logic=None,
            is_active=True,
            execution_count=0
        ),
        Macro(
            id=3,
            name='Desligar Tudo',
            description='Desliga todos os acessórios',
            trigger_type='manual',
            trigger_config='{}',
            action_sequence=json.dumps([
                {"type": "relay", "target": "all", "action": "off"}
            ]),
            condition_logic=None,
            is_active=True,
            execution_count=0
        )
    ]
    
    session.add_all(macros)
    session.commit()
    print(f"✓ {len(macros)} macros criadas")

def seed_sample_telemetry(session):
    """Cria dados de telemetria de exemplo"""
    print("\n📊 Criando telemetria de exemplo...")
    
    now = datetime.now()
    telemetry = [
        TelemetryData(device_id=1, data_type='status', data_key='uptime', data_value='3600', unit='seconds', timestamp=now - timedelta(hours=1)),
        TelemetryData(device_id=1, data_type='status', data_key='relay_states', data_value='0000000000000000', unit='binary', timestamp=now - timedelta(minutes=30)),
        TelemetryData(device_id=2, data_type='status', data_key='brightness', data_value='80', unit='%', timestamp=now - timedelta(minutes=15)),
        TelemetryData(device_id=4, data_type='can', data_key='speed', data_value='65.5', unit='km/h', timestamp=now - timedelta(minutes=10)),
        TelemetryData(device_id=4, data_type='can', data_key='rpm', data_value='2500', unit='rpm', timestamp=now - timedelta(minutes=5)),
        TelemetryData(device_id=4, data_type='can', data_key='coolant_temp', data_value='92', unit='°C', timestamp=now - timedelta(minutes=2)),
        TelemetryData(device_id=4, data_type='can', data_key='fuel_level', data_value='75', unit='%', timestamp=now)
    ]
    
    session.add_all(telemetry)
    session.commit()
    print(f"✓ {len(telemetry)} registros de telemetria criados")

def seed_sample_events(session):
    """Cria eventos de exemplo"""
    print("\n📝 Criando eventos de exemplo...")
    
    now = datetime.now()
    events = [
        EventLog(event_type='system', source='database', target=None, action='seed_applied', user_id=1, status='success', timestamp=now - timedelta(hours=2)),
        EventLog(event_type='device', source='gateway', target='esp32-relay-001', action='connected', user_id=None, status='success', timestamp=now - timedelta(hours=1)),
        EventLog(event_type='user', source='config-app', target=None, action='login', user_id=1, status='success', timestamp=now - timedelta(minutes=30)),
        EventLog(event_type='relay', source='esp32-relay-001', target='channel_1', action='toggle_on', user_id=2, status='success', timestamp=now - timedelta(minutes=10))
    ]
    
    session.add_all(events)
    session.commit()
    print(f"✓ {len(events)} eventos criados")

def main():
    """Executa o seed completo"""
    print("\n" + "=" * 50)
    print("🌱 SEED DE DESENVOLVIMENTO - AUTOCORE")
    print("=" * 50)
    
    session = Session()
    
    try:
        # Limpar dados existentes
        clear_database(session)
        
        # Aplicar seeds na ordem correta
        seed_users(session)
        seed_devices(session)
        seed_relay_boards_and_channels(session)
        seed_themes(session)
        seed_screens_and_items(session)
        seed_can_signals(session)
        seed_macros(session)
        seed_sample_telemetry(session)
        seed_sample_events(session)
        
        print("\n" + "=" * 50)
        print("✅ SEED APLICADO COM SUCESSO!")
        print("=" * 50)
        
    except Exception as e:
        session.rollback()
        print(f"\n❌ Erro ao aplicar seed: {e}")
        import traceback
        traceback.print_exc()
    finally:
        session.close()

if __name__ == '__main__':
    main()