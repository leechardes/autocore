#!/usr/bin/env python3
"""
Seed de desenvolvimento para AutoCore
Baseado no backup real do sistema em produção
Data: 09 de agosto de 2025
"""
import sys
from pathlib import Path
from datetime import datetime
import json

# Adiciona path para importar models
sys.path.append(str(Path(__file__).parent.parent))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from src.models.models import (
    Base, User, Device, RelayBoard, RelayChannel,
    Screen, ScreenItem, Theme, CANSignal, Macro, EventLog, Icon
)

DATABASE_URL = f"sqlite:///{Path(__file__).parent.parent}/autocore.db"
engine = create_engine(DATABASE_URL, echo=False)
Session = sessionmaker(bind=engine)

def clear_database(session):
    """Limpa dados existentes na ordem correta"""
    print("🗑️  Limpando dados existentes...")
    
    # Ordem de limpeza respeitando foreign keys
    session.query(EventLog).delete()
    session.query(ScreenItem).delete()
    session.query(Screen).delete()
    session.query(RelayChannel).delete()
    session.query(RelayBoard).delete()
    session.query(Macro).delete()
    session.query(Device).delete()
    session.query(User).delete()
    session.query(Theme).delete()
    session.query(CANSignal).delete()
    session.query(Icon).delete()  # Limpar ícones também
    session.commit()
    print("✓ Dados anteriores removidos")

def seed_users(session):
    """Cria usuários do sistema"""
    print("\n👤 Criando usuários...")
    
    users = [
        User(
            id=1,
            username='admin',
            password_hash='$2b$12$LQi3c8zc8Jc8zc8Jc8zc8u',
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
    print("\n🔌 Criando dispositivos...")
    
    devices = [
        Device(
            id=1,
            uuid='esp32-relay-001',
            name='Central de Relés',
            type='esp32_relay',
            mac_address='AA:BB:CC:DD:EE:01',
            ip_address='192.168.1.200',
            firmware_version='v1.0.0',
            hardware_version='rev2',
            status='online',
            last_seen=datetime.fromisoformat('2025-08-08 05:11:57.775189'),
            configuration_json=json.dumps({
                "relay_count": "16",
                "mqtt_topic": "autocore/relay/001",
                "location": "painel",
                "device_type": "esp32_relay",
                "mac_address": "AA:BB:CC:DD:EE:01",
                "board_model": "16ch_standard",
                "voltage": "12V",
                "max_current": "10"
            }),
            capabilities_json=json.dumps({
                "relay_control": True,
                "status_report": False,
                "ota_update": True,
                "timer_control": True,
                "interlock": False
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
            last_seen=datetime.fromisoformat('2025-08-08 05:07:28.093457'),
            configuration_json=json.dumps({
                "screen_size": "2.8inch",
                "resolution": "320x240",
                "touch": True,
                "mqtt_topic": "autocore/display/001",
                "location": "painel",
                "device_type": "esp32_display",
                "mac_address": "AA:BB:CC:DD:EE:02",
                "touch_enabled": True,
                "brightness_control": True,
                "_capabilities": {
                    "touch_input": True,
                    "screen_render": True,
                    "brightness_control": True,
                    "multi_page": True
                }
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
            type='esp32_relay',  # Mapear esp32_controls para ESP32_RELAY
            mac_address='AA:BB:CC:DD:EE:03',
            ip_address='192.168.1.103',
            firmware_version='v1.0.0',
            hardware_version='rev1',
            status='online',
            last_seen=datetime.fromisoformat('2025-08-07 14:23:32.940336'),
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
            is_active=False
        ),
        Device(
            id=4,
            uuid='esp32-can-001',
            name='Interface CAN',
            type='esp32_relay',  # Mapear esp32_can para ESP32_RELAY
            mac_address='AA:BB:CC:DD:EE:04',
            ip_address='192.168.1.104',
            firmware_version='v1.0.0',
            hardware_version='rev1',
            status='online',
            last_seen=datetime.fromisoformat('2025-08-08 05:07:36.210316'),
            configuration_json=json.dumps({
                "can_speed": "250000",
                "mqtt_topic": "autocore/can/001",
                "location": "painel",
                "device_type": "esp32_can",
                "mac_address": "AA:BB:CC:DD:EE:04",
                "ecu_type": "fueltech",
                "_capabilities": {
                    "can_read": False,
                    "can_write": False,
                    "obd2": False
                },
                "termination_resistor": False,
                "filter_ids": "0x200"
            }),
            capabilities_json=json.dumps({
                "can_read": True,
                "can_write": True,
                "obd2": True,
                "can_filter": True,
                "can_bridge": True
            }),
            is_active=True
        ),
        Device(
            id=5,
            uuid='gateway-001',
            name='Gateway Principal',
            type='esp32_relay',  # Mapear gateway para ESP32_RELAY
            mac_address='AA:BB:CC:DD:EE:05',
            ip_address='192.168.1.100',
            firmware_version='v1.0.0',
            hardware_version='pi-zero-2w',
            status='online',
            last_seen=datetime.fromisoformat('2025-08-07 14:23:32.940379'),
            configuration_json=json.dumps({
                "mqtt_broker": "localhost",
                "mqtt_port": 1883
            }),
            capabilities_json=json.dumps({
                "mqtt_bridge": True,
                "database": True,
                "api": True
            }),
            is_active=False
        ),
        Device(
            id=6,
            uuid='esp32-1754594129629',
            name='Teste',
            type='esp32_relay',
            mac_address='AA:BB:CC:DD:EE:09',
            ip_address='192.168.1.105',
            firmware_version='V1.0.0',
            hardware_version='rev2',
            status='online',
            last_seen=datetime.fromisoformat('2025-08-07 16:18:20.940414'),
            configuration_json=json.dumps({
                "relay_count": 16,
                "mqtt_topic": "autocore/relay/001"
            }),
            capabilities_json=json.dumps({
                "relay_control": True,
                "status_report": True,
                "ota_update": True
            }),
            is_active=False
        )
    ]
    
    session.add_all(devices)
    session.commit()
    print(f"✓ {len(devices)} dispositivos criados")

def seed_relay_boards(session):
    """Cria placas de relé"""
    print("\n⚡ Criando placas de relé...")
    
    boards = [
        RelayBoard(
            id=1,
            device_id=1,
            total_channels=16,
            board_model='RELAY16CH-12V',
            is_active=True
        ),
        RelayBoard(
            id=2,
            device_id=6,
            total_channels=16,
            board_model='ESP32_16CH',
            is_active=False
        )
    ]
    
    session.add_all(boards)
    session.commit()
    print(f"✓ {len(boards)} placas de relé criadas")

def seed_relay_channels(session):
    """Cria canais de relé"""
    print("\n🔌 Criando canais de relé...")
    
    channels = [
        # Placa 1 - Principal
        RelayChannel(id=1, board_id=1, channel_number=1, name='Farol Alto', description='Farol alto principal', 
                    function_type='momentary', icon='light-high', color='#FF6B35', 
                    protection_mode='none', is_active=True, allow_in_macro=False),
        RelayChannel(id=2, board_id=1, channel_number=2, name='Farol Baixo', description='Farol baixo principal',
                    function_type='pulse', icon='light-low', color='#FFFFAA', 
                    protection_mode='none', is_active=True, allow_in_macro=True),
        RelayChannel(id=3, board_id=1, channel_number=3, name='Milha', description='Farol de milha',
                    function_type='toggle', icon='light-fog', color='#FFFF88', 
                    protection_mode='none', is_active=True, allow_in_macro=True),
        RelayChannel(id=4, board_id=1, channel_number=4, name='Strobo', description='Luzes de emergência',
                    function_type='momentary', icon='light-emergency', color='#FF0000', 
                    protection_mode='interlock', max_activation_time=300, is_active=True, allow_in_macro=False),
        RelayChannel(id=5, board_id=1, channel_number=5, name='Guincho', description='Guincho elétrico',
                    function_type='pulse', icon='winch', color='#FFA500', 
                    protection_mode='exclusive', max_activation_time=60, is_active=True, allow_in_macro=False),
        RelayChannel(id=6, board_id=1, channel_number=6, name='Compressor', description='Compressor de ar',
                    function_type='toggle', icon='air-compressor', color='#00AAFF', 
                    protection_mode='interlock', max_activation_time=600, is_active=True, allow_in_macro=True),
        RelayChannel(id=7, board_id=1, channel_number=7, name='Inversor', description='Inversor 110V/220V',
                    function_type='momentary', icon='power-inverter', color='#00FF00', 
                    protection_mode='none', is_active=True, allow_in_macro=False),
        RelayChannel(id=8, board_id=1, channel_number=8, name='Rádio VHF', description='Rádio comunicação',
                    function_type='pulse', icon='radio', color='#8888FF', 
                    protection_mode='none', is_active=True, allow_in_macro=True),
        RelayChannel(id=9, board_id=1, channel_number=9, name='Bomba Combustível', description='Bomba de combustível auxiliar',
                    function_type='toggle', icon='fuel-pump', color='#AA5500', 
                    protection_mode='exclusive', is_active=True, allow_in_macro=True),
        RelayChannel(id=10, board_id=1, channel_number=10, name='Ventoinha Extra', description='Ventoinha adicional radiador',
                    function_type='momentary', icon='fan', color='#00FFFF', 
                    protection_mode='none', is_active=True, allow_in_macro=False),
        RelayChannel(id=11, board_id=1, channel_number=11, name='Trava Diferencial', description='Bloqueio do diferencial',
                    function_type='pulse', icon='diff-lock', color='#FF8800', 
                    protection_mode='interlock', is_active=True, allow_in_macro=True),
        RelayChannel(id=12, board_id=1, channel_number=12, name='Câmera Ré', description='Sistema de câmera de ré',
                    function_type='toggle', icon='camera', color='#AA00FF', 
                    protection_mode='none', is_active=True, allow_in_macro=True),
        RelayChannel(id=13, board_id=1, channel_number=13, name='Aux 1', description='Auxiliar 1',
                    function_type='momentary', icon='aux', color='#888888', 
                    protection_mode='none', is_active=True, allow_in_macro=False),
        RelayChannel(id=14, board_id=1, channel_number=14, name='Aux 2', description='Auxiliar 2',
                    function_type='pulse', icon='aux', color='#888888', 
                    protection_mode='none', is_active=True, allow_in_macro=True),
        RelayChannel(id=15, board_id=1, channel_number=15, name='Aux 3', description='Auxiliar 3',
                    function_type='toggle', icon='aux', color='#888888', 
                    protection_mode='none', is_active=True, allow_in_macro=True),
        RelayChannel(id=16, board_id=1, channel_number=16, name='Aux 4', description='Auxiliar 4',
                    function_type='toggle', icon='aux', color='#888888', 
                    protection_mode='none', is_active=True, allow_in_macro=True),
        
        # Placa 2 - Teste (inativa)
        RelayChannel(id=17, board_id=2, channel_number=1, name='Canal 1', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=18, board_id=2, channel_number=2, name='Canal 2', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=19, board_id=2, channel_number=3, name='Canal 3', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=20, board_id=2, channel_number=4, name='Canal 4', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=21, board_id=2, channel_number=5, name='Canal 5', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=22, board_id=2, channel_number=6, name='Canal 6', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=23, board_id=2, channel_number=7, name='Canal 7', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=24, board_id=2, channel_number=8, name='Canal 8', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=25, board_id=2, channel_number=9, name='Canal 9', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=26, board_id=2, channel_number=10, name='Canal 10', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=27, board_id=2, channel_number=11, name='Canal 11', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=28, board_id=2, channel_number=12, name='Canal 12', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=29, board_id=2, channel_number=13, name='Canal 13', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=30, board_id=2, channel_number=14, name='Canal 14', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=31, board_id=2, channel_number=15, name='Canal 15', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True),
        RelayChannel(id=32, board_id=2, channel_number=16, name='Canal 16', function_type='toggle',
                    icon='aux', color='#888888', protection_mode='none', is_active=False, allow_in_macro=True)
    ]
    
    session.add_all(channels)
    session.commit()
    print(f"✓ {len(channels)} canais de relé criados")

def seed_screens(session):
    """Cria telas do sistema"""
    print("\n📱 Criando telas...")
    
    screens = [
        Screen(
            id=1,
            name='home',
            title='Início',
            icon='home',
            screen_type='dashboard',
            position=1,
            columns_mobile=2,
            columns_display_small=3,
            columns_display_large=4,
            columns_web=6,
            is_visible=True,
            show_on_mobile=True,
            show_on_display_small=True,
            show_on_display_large=True,
            show_on_web=True,
            show_on_controls=False
        ),
        Screen(
            id=2,
            name='lights',
            title='Iluminação',
            icon='lightbulb',
            screen_type='control',
            position=2,
            columns_mobile=2,
            columns_display_small=3,
            columns_display_large=4,
            columns_web=4,
            is_visible=True,
            show_on_mobile=True,
            show_on_display_small=True,
            show_on_display_large=True,
            show_on_web=True,
            show_on_controls=True
        ),
        Screen(
            id=3,
            name='accessories',
            title='Acessórios',
            icon='tools',
            screen_type='control',
            position=3,
            columns_mobile=2,
            columns_display_small=3,
            columns_display_large=4,
            columns_web=4,
            is_visible=True,
            show_on_mobile=True,
            show_on_display_small=True,
            show_on_display_large=True,
            show_on_web=True,
            show_on_controls=True
        ),
        Screen(
            id=4,
            name='systems',
            title='Sistemas',
            icon='settings',
            screen_type='control',
            position=4,
            columns_mobile=2,
            columns_display_small=3,
            columns_display_large=4,
            columns_web=4,
            is_visible=True,
            required_permission='operator',
            show_on_mobile=True,
            show_on_display_small=True,
            show_on_display_large=True,
            show_on_web=True,
            show_on_controls=False
        ),
        Screen(
            id=5,
            name='diagnostics',
            title='Diagnóstico',
            icon='chart',
            screen_type='dashboard',
            position=5,
            columns_mobile=1,
            columns_display_small=2,
            columns_display_large=3,
            columns_web=4,
            is_visible=True,
            required_permission='admin',
            show_on_mobile=True,
            show_on_display_small=True,
            show_on_display_large=True,
            show_on_web=True,
            show_on_controls=False
        )
    ]
    
    session.add_all(screens)
    session.commit()
    print(f"✓ {len(screens)} telas criadas")

def seed_screen_items(session):
    """Cria itens das telas"""
    print("\n📊 Criando itens de tela...")
    
    items = [
        # Dashboard Home
        ScreenItem(
            id=1, screen_id=1, item_type='display', name='speed', label='Velocidade',
            icon='speedometer', position=1, size_mobile='large', size_display_small='large',
            size_display_large='large', size_web='normal', data_source='can',
            data_path='speed', data_format='number', data_unit='km/h', is_active=True
        ),
        ScreenItem(
            id=2, screen_id=1, item_type='display', name='rpm', label='RPM',
            icon='tachometer', position=2, size_mobile='large', size_display_small='large',
            size_display_large='large', size_web='normal', data_source='can',
            data_path='rpm', data_format='number', data_unit='rpm', is_active=True
        ),
        ScreenItem(
            id=3, screen_id=1, item_type='display', name='temp', label='Temperatura',
            icon='thermometer', position=3, size_mobile='normal', size_display_small='normal',
            size_display_large='normal', size_web='normal', data_source='can',
            data_path='coolant_temp', data_format='number', data_unit='°C', is_active=True
        ),
        ScreenItem(
            id=4, screen_id=1, item_type='display', name='fuel', label='Combustível',
            icon='fuel', position=4, size_mobile='normal', size_display_small='normal',
            size_display_large='normal', size_web='normal', data_source='can',
            data_path='fuel_level', data_format='percentage', data_unit='%', is_active=True
        ),
        
        # Tela Iluminação
        ScreenItem(
            id=5, screen_id=2, item_type='button', name='btn_farol_alto', label='Farol Alto',
            icon='light-high', position=1, size_mobile='large', size_display_small='normal',
            size_display_large='normal', size_web='normal', action_type='relay_control',
            action_payload='{}', is_active=True, relay_board_id=1, relay_channel_id=1
        ),
        ScreenItem(
            id=6, screen_id=2, item_type='button', name='btn_farol_baixo', label='Farol Baixo',
            icon='light-low', position=2, size_mobile='normal', size_display_small='normal',
            size_display_large='normal', size_web='normal', action_type='relay_control',
            action_payload='{"toggle":1}', is_active=True, relay_board_id=1, relay_channel_id=2
        ),
        ScreenItem(
            id=7, screen_id=2, item_type='button', name='btn_milha', label='Milha',
            icon='light-fog', position=3, size_mobile='normal', size_display_small='normal',
            size_display_large='normal', size_web='normal', action_type='relay_control',
            action_payload='{}', is_active=True, relay_board_id=1, relay_channel_id=3
        ),
        ScreenItem(
            id=8, screen_id=2, item_type='switch', name='btn_strobo', label='Strobo',
            icon='light-emergency', position=4, size_mobile='large', size_display_small='normal',
            size_display_large='normal', size_web='normal', action_type='relay_control',
            action_payload='{"toggle":1}', is_active=True, relay_board_id=1, relay_channel_id=4
        ),
        
        # Tela Acessórios
        ScreenItem(
            id=9, screen_id=3, item_type='button', name='btn_guincho', label='Guincho',
            icon='winch', position=1, size_mobile='large', size_display_small='large',
            size_display_large='normal', size_web='normal', action_type='relay_control',
            action_payload='{"momentary":1}', is_active=True, relay_board_id=1, relay_channel_id=5
        ),
        ScreenItem(
            id=10, screen_id=3, item_type='button', name='btn_compressor', label='Compressor',
            icon='air-compressor', position=2, size_mobile='large', size_display_small='normal',
            size_display_large='normal', size_web='normal', action_type='relay_control',
            action_payload='{"toggle":1}', is_active=True, relay_board_id=1, relay_channel_id=6
        ),
        ScreenItem(
            id=11, screen_id=3, item_type='button', name='btn_inversor', label='Inversor 110V',
            icon='power-inverter', position=3, size_mobile='large', size_display_small='normal',
            size_display_large='normal', size_web='normal', action_type='relay_control',
            action_payload='{"toggle":1}', is_active=True, relay_board_id=1, relay_channel_id=7
        ),
        ScreenItem(
            id=12, screen_id=3, item_type='button', name='btn_radio', label='Rádio VHF',
            icon='radio', position=4, size_mobile='large', size_display_small='normal',
            size_display_large='normal', size_web='normal', action_type='relay_control',
            action_payload='{"toggle":1}', is_active=True, relay_board_id=1, relay_channel_id=8
        ),
        
        # Botões extras
        ScreenItem(
            id=13, screen_id=2, item_type='button', name='test_new_relay', label='Teste Novo Relé',
            icon='power', position=15, size_mobile='normal', size_display_small='normal',
            size_display_large='normal', size_web='normal', action_type='relay_control',
            action_payload='{"toggle": true}', is_active=True, relay_board_id=1, relay_channel_id=10
        ),
        ScreenItem(
            id=14, screen_id=3, item_type='button', name='bt_aux', label='Auxiliar',
            icon='circle', position=5, size_mobile='small', size_display_small='normal',
            size_display_large='normal', size_web='normal', action_type='relay_control',
            action_payload='{"toggle":true}', is_active=True, relay_board_id=1, relay_channel_id=13
        )
    ]
    
    session.add_all(items)
    session.commit()
    print(f"✓ {len(items)} itens de tela criados")

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

def seed_can_signals(session):
    """Cria sinais CAN FuelTech"""
    print("\n🚗 Criando sinais CAN...")
    
    signals = [
        CANSignal(
            id=1, signal_name='RPM', can_id='0x100', start_bit=0, length_bits=16,
            scale_factor=1.0, offset=0.0, unit='RPM', min_value=0.0, max_value=8000.0,
            description='Rotação do motor', category='motor', is_active=True
        ),
        CANSignal(
            id=2, signal_name='TPS', can_id='0x100', start_bit=16, length_bits=8,
            scale_factor=0.392, offset=0.0, unit='%', min_value=0.0, max_value=100.0,
            description='Posição do acelerador', category='motor', is_active=True
        ),
        CANSignal(
            id=3, signal_name='MAP', can_id='0x200', start_bit=0, length_bits=16,
            scale_factor=1.0, offset=0.0, unit='kPa', min_value=0.0, max_value=250.0,
            description='Pressão do coletor', category='motor', is_active=True
        ),
        CANSignal(
            id=4, signal_name='IAT', can_id='0x200', start_bit=16, length_bits=8,
            scale_factor=1.0, offset=-40.0, unit='°C', min_value=-40.0, max_value=120.0,
            description='Temperatura do ar', category='motor', is_active=True
        ),
        CANSignal(
            id=5, signal_name='ECT', can_id='0x300', start_bit=0, length_bits=8,
            scale_factor=1.0, offset=-40.0, unit='°C', min_value=-40.0, max_value=120.0,
            description='Temperatura do motor', category='motor', is_active=True
        ),
        CANSignal(
            id=6, signal_name='FuelPressure', can_id='0x400', start_bit=0, length_bits=16,
            scale_factor=1.0, offset=0.0, unit='kPa', min_value=0.0, max_value=600.0,
            description='Pressão de combustível', category='combustivel', is_active=True
        ),
        CANSignal(
            id=7, signal_name='Ethanol', can_id='0x400', start_bit=16, length_bits=8,
            scale_factor=0.392, offset=0.0, unit='%', min_value=0.0, max_value=100.0,
            description='Percentual de etanol', category='combustivel', is_active=True
        ),
        CANSignal(
            id=8, signal_name='FuelLevel', can_id='0x400', start_bit=24, length_bits=8,
            scale_factor=0.392, offset=0.0, unit='%', min_value=0.0, max_value=100.0,
            description='Nível de combustível', category='combustivel', is_active=True
        ),
        CANSignal(
            id=9, signal_name='Battery', can_id='0x500', start_bit=0, length_bits=8,
            scale_factor=0.1, offset=0.0, unit='V', min_value=10.0, max_value=16.0,
            description='Tensão da bateria', category='eletrico', is_active=True
        ),
        CANSignal(
            id=10, signal_name='Lambda', can_id='0x300', start_bit=8, length_bits=16,
            scale_factor=0.001, offset=0.0, unit='λ', min_value=0.7, max_value=1.3,
            description='Fator lambda', category='eletrico', is_active=True
        ),
        CANSignal(
            id=11, signal_name='OilPressure', can_id='0x500', start_bit=8, length_bits=8,
            scale_factor=0.039, offset=0.0, unit='bar', min_value=0.0, max_value=10.0,
            description='Pressão do óleo', category='pressoes', is_active=True
        ),
        CANSignal(
            id=12, signal_name='BoostPressure', can_id='0x500', start_bit=16, length_bits=16,
            scale_factor=0.001, offset=-1.0, unit='bar', min_value=-1.0, max_value=3.0,
            description='Pressão do turbo', category='pressoes', is_active=True
        ),
        CANSignal(
            id=13, signal_name='Speed', can_id='0x600', start_bit=0, length_bits=16,
            scale_factor=1.0, offset=0.0, unit='km/h', min_value=0.0, max_value=300.0,
            description='Velocidade do veículo', category='velocidade', is_active=True
        ),
        CANSignal(
            id=14, signal_name='Gear', can_id='0x600', start_bit=16, length_bits=8,
            scale_factor=1.0, offset=0.0, unit='', min_value=0.0, max_value=6.0,
            description='Marcha atual', category='velocidade', is_active=True
        )
    ]
    
    session.add_all(signals)
    session.commit()
    print(f"✓ {len(signals)} sinais CAN criados")

def seed_macros(session):
    """Cria macros de automação"""
    print("\n⚙️  Criando macros...")
    
    macros = [
        Macro(
            id=1,
            name='Modo Trilha',
            description='Ativa configurações para trilha',
            trigger_type='manual',
            trigger_config=json.dumps({
                "preserve_state": True,
                "requires_heartbeat": False
            }),
            action_sequence=json.dumps([
                {"type": "save_state", "scope": "all"},
                {"type": "relay", "target": 3, "action": "on", "label": "Farol de milha"},
                {"type": "relay", "target": 10, "action": "on", "label": "Barra LED"},
                {"type": "relay", "target": 15, "action": "on", "label": "Luz traseira"},
                {"type": "mqtt", "topic": "autocore/modes/trail", "payload": {"active": True}},
                {"type": "log", "message": "Modo Trilha ativado"}
            ]),
            is_active=True,
            execution_count=1
        ),
        Macro(
            id=2,
            name='Emergência',
            description='Ativa luzes de emergência',
            trigger_type='manual',
            trigger_config=json.dumps({
                "preserve_state": True,
                "requires_heartbeat": True
            }),
            action_sequence=json.dumps([
                {"type": "save_state", "scope": "all"},
                {"type": "parallel", "actions": [
                    {"type": "relay", "target": [4, 5], "action": "on", "label": "Luzes de emergência"},
                    {"type": "mqtt", "topic": "autocore/alerts/emergency", "payload": {"active": True}}
                ]},
                {"type": "loop", "count": -1, "actions": [
                    {"type": "relay", "target": [1, 2], "action": "on", "label": "Pisca alerta"},
                    {"type": "delay", "ms": 500},
                    {"type": "relay", "target": [1, 2], "action": "off"},
                    {"type": "delay", "ms": 500}
                ]}
            ]),
            is_active=True,
            execution_count=4
        ),
        Macro(
            id=3,
            name='Desligar Tudo',
            description='Desliga todos os acessórios',
            trigger_type='manual',
            trigger_config=json.dumps({
                "preserve_state": False,
                "requires_heartbeat": False
            }),
            action_sequence=json.dumps([
                {"type": "relay", "target": "all", "action": "off"},
                {"type": "mqtt", "topic": "autocore/system/shutdown", "payload": {"timestamp": "2025-08-08T12:03:19.854361"}},
                {"type": "log", "message": "Sistema desligado - Todos os acessórios OFF"}
            ]),
            is_active=True,
            execution_count=13
        ),
        Macro(
            id=4,
            name='Show de Luz',
            description='Sequência de luzes para demonstração e entretenimento',
            trigger_type='manual',
            trigger_config=json.dumps({
                "preserve_state": True,
                "requires_heartbeat": False,
                "total_duration_ms": 25000
            }),
            action_sequence=json.dumps([
                {"type": "save_state", "targets": [1, 2, 3, 4, 5, 6, 7, 8], "label": "Salvar estado original"},
                {"type": "log", "message": "Iniciando Show de Luz 🎆"},
                {"type": "loop", "count": 3, "label": "Onda de luz", "actions": [
                    {"type": "relay", "target": [1, 2], "action": "on"},
                    {"type": "delay", "ms": 200},
                    {"type": "relay", "target": [3, 4], "action": "on"},
                    {"type": "relay", "target": [1, 2], "action": "off"},
                    {"type": "delay", "ms": 200},
                    {"type": "relay", "target": [5, 6], "action": "on"},
                    {"type": "relay", "target": [3, 4], "action": "off"},
                    {"type": "delay", "ms": 200},
                    {"type": "relay", "target": [7, 8], "action": "on"},
                    {"type": "relay", "target": [5, 6], "action": "off"},
                    {"type": "delay", "ms": 200},
                    {"type": "relay", "target": [7, 8], "action": "off"},
                    {"type": "delay", "ms": 200}
                ]},
                {"type": "loop", "count": 5, "label": "Alternado pares/ímpares", "actions": [
                    {"type": "relay", "target": [1, 3, 5, 7], "action": "on"},
                    {"type": "relay", "target": [2, 4, 6, 8], "action": "off"},
                    {"type": "delay", "ms": 300},
                    {"type": "relay", "target": [1, 3, 5, 7], "action": "off"},
                    {"type": "relay", "target": [2, 4, 6, 8], "action": "on"},
                    {"type": "delay", "ms": 300}
                ]},
                {"type": "loop", "count": 3, "label": "Flash total", "actions": [
                    {"type": "relay", "target": "all", "action": "on"},
                    {"type": "delay", "ms": 500},
                    {"type": "relay", "target": "all", "action": "off"},
                    {"type": "delay", "ms": 500}
                ]},
                {"type": "loop", "count": 2, "label": "Crescente", "actions": [
                    {"type": "relay", "target": 1, "action": "on"},
                    {"type": "delay", "ms": 100},
                    {"type": "relay", "target": 2, "action": "on"},
                    {"type": "delay", "ms": 100},
                    {"type": "relay", "target": 3, "action": "on"},
                    {"type": "delay", "ms": 100},
                    {"type": "relay", "target": 4, "action": "on"},
                    {"type": "delay", "ms": 100},
                    {"type": "relay", "target": 5, "action": "on"},
                    {"type": "delay", "ms": 100},
                    {"type": "relay", "target": 6, "action": "on"},
                    {"type": "delay", "ms": 100},
                    {"type": "relay", "target": 7, "action": "on"},
                    {"type": "delay", "ms": 100},
                    {"type": "relay", "target": 8, "action": "on"},
                    {"type": "delay", "ms": 500},
                    {"type": "relay", "target": "all", "action": "off"},
                    {"type": "delay", "ms": 300}
                ]},
                {"type": "log", "message": "Show de Luz finalizado ✨"},
                {"type": "restore_state", "targets": [1, 2, 3, 4, 5, 6, 7, 8], "label": "Restaurar estado original"}
            ]),
            is_active=True,
            execution_count=0
        ),
        Macro(
            id=5,
            name='Modo Estacionamento',
            description='Ativa luzes de posição e interna temporariamente',
            trigger_type='manual',
            trigger_config=json.dumps({
                "preserve_state": True,
                "requires_heartbeat": False
            }),
            action_sequence=json.dumps([
                {"type": "save_state", "scope": "all"},
                {"type": "relay", "target": 2, "action": "on", "label": "Luzes de posição", "board_id": 1},
                {"type": "relay", "target": 12, "action": "on", "label": "Luz interna", "board_id": 1},
                {"type": "delay", "ms": 30000},
                {"type": "relay", "target": 12, "action": "off", "label": "Desliga luz interna", "board_id": 1},
                {"type": "mqtt", "topic": "autocore/modes/parking", "payload": {"active": True}}
            ]),
            is_active=True,
            execution_count=14
        ),
        Macro(
            id=6,
            name='Sequência Teste',
            description='Testa todas as funcionalidades de macros',
            trigger_type='manual',
            trigger_config=json.dumps({
                "preserve_state": True,
                "requires_heartbeat": False
            }),
            action_sequence=json.dumps([
                {"type": "save_state", "targets": [1, 2, 3]},
                {"type": "relay", "target": 1, "action": "on", "label": "Liga Relé 1"},
                {"type": "delay", "ms": 500},
                {"type": "loop", "count": 3, "actions": [
                    {"type": "relay", "target": 2, "action": "toggle"},
                    {"type": "delay", "ms": 200}
                ]},
                {"type": "restore_state", "targets": [1, 2, 3]}
            ]),
            is_active=True,
            execution_count=0
        ),
        Macro(
            id=7,
            name='Teste Editor',
            description='Macro criada com editor visual',
            trigger_type='manual',
            trigger_config=json.dumps({
                "preserve_state": False,
                "requires_heartbeat": False
            }),
            action_sequence=json.dumps([
                {"type": "relay", "target": 1, "action": "on", "label": "Liga Relé 1"},
                {"type": "delay", "ms": 500},
                {"type": "relay", "target": 1, "action": "off", "label": "Desliga Relé 1"}
            ]),
            is_active=True,
            execution_count=1
        )
    ]
    
    session.add_all(macros)
    session.commit()
    print(f"✓ {len(macros)} macros criadas")

def seed_initial_events(session):
    """Cria eventos iniciais do sistema"""
    print("\n📝 Criando eventos iniciais...")
    
    events = [
        EventLog(
            event_type='system',
            source='database',
            target=None,
            action='seed_applied',
            user_id=1,
            status='success',
            timestamp=datetime.now(),
            metadata={'version': '1.0.0', 'seed': 'development'}
        ),
        EventLog(
            event_type='system',
            source='database',
            target=None,
            action='initialization',
            user_id=1,
            status='success',
            timestamp=datetime.now(),
            metadata={'message': 'Sistema inicializado com seed de desenvolvimento'}
        )
    ]
    
    session.add_all(events)
    session.commit()
    print(f"✓ {len(events)} eventos criados")

def seed_icons(session):
    """Cria ícones do sistema"""
    print("\n🎨 Criando ícones...")
    
    icons = [
        # Iluminação
        Icon(id=1, name='light', display_name='Luz', category='lighting',
             lucide_name='lightbulb', material_name='lightbulb', 
             lvgl_symbol='LV_SYMBOL_LIGHT', unicode_char='\uf0eb', emoji='💡',
             description='Luz geral', tags='["luz", "iluminação", "light"]'),
        Icon(id=2, name='light_high', display_name='Farol Alto', category='lighting',
             lucide_name='zap', material_name='flash_on',
             lvgl_symbol='LV_SYMBOL_LIGHT', unicode_char='\uf0e7', emoji='🔦',
             description='Farol alto do veículo', tags='["farol", "alto", "high"]'),
        Icon(id=3, name='light_low', display_name='Farol Baixo', category='lighting',
             lucide_name='lightbulb', material_name='lightbulb_outline',
             lvgl_symbol='LV_SYMBOL_LIGHT', unicode_char='\uf0eb', emoji='💡',
             description='Farol baixo do veículo', tags='["farol", "baixo", "low"]'),
        Icon(id=4, name='fog_light', display_name='Farol de Neblina', category='lighting',
             lucide_name='cloud-fog', material_name='blur_on',
             unicode_char='\uf0c2', emoji='🌫️',
             description='Farol de neblina', tags='["neblina", "fog", "milha"]'),
        
        # Controle
        Icon(id=5, name='power', display_name='Liga/Desliga', category='control',
             lucide_name='power', material_name='power_settings_new',
             lvgl_symbol='LV_SYMBOL_POWER', unicode_char='\uf011', emoji='⚡',
             description='Botão de liga/desliga', tags='["power", "on", "off"]'),
        Icon(id=6, name='play', display_name='Iniciar', category='control',
             lucide_name='play', material_name='play_arrow',
             lvgl_symbol='LV_SYMBOL_PLAY', unicode_char='\uf04b', emoji='▶️',
             description='Iniciar operação', tags='["play", "start", "iniciar"]'),
        Icon(id=7, name='stop', display_name='Parar', category='control',
             lucide_name='square', material_name='stop',
             lvgl_symbol='LV_SYMBOL_STOP', unicode_char='\uf04d', emoji='⏹️',
             description='Parar operação', tags='["stop", "parar", "halt"]'),
        Icon(id=8, name='pause', display_name='Pausar', category='control',
             lucide_name='pause', material_name='pause',
             lvgl_symbol='LV_SYMBOL_PAUSE', unicode_char='\uf04c', emoji='⏸️',
             description='Pausar operação', tags='["pause", "pausar"]'),
        
        # Navegação
        Icon(id=9, name='home', display_name='Início', category='navigation',
             lucide_name='home', material_name='home',
             lvgl_symbol='LV_SYMBOL_HOME', unicode_char='\uf015', emoji='🏠',
             description='Página inicial', tags='["home", "início", "casa"]'),
        Icon(id=10, name='back', display_name='Voltar', category='navigation',
             lucide_name='arrow-left', material_name='arrow_back',
             lvgl_symbol='LV_SYMBOL_LEFT', unicode_char='\uf060', emoji='⬅️',
             description='Voltar à tela anterior', tags='["back", "voltar", "anterior"]'),
        Icon(id=11, name='next', display_name='Próximo', category='navigation',
             lucide_name='arrow-right', material_name='arrow_forward',
             lvgl_symbol='LV_SYMBOL_RIGHT', unicode_char='\uf061', emoji='➡️',
             description='Próxima tela', tags='["next", "próximo", "avançar"]'),
        Icon(id=12, name='settings', display_name='Configurações', category='navigation',
             lucide_name='settings', material_name='settings',
             lvgl_symbol='LV_SYMBOL_SETTINGS', unicode_char='\uf013', emoji='⚙️',
             description='Configurações do sistema', tags='["settings", "config", "ajustes"]'),
        
        # Status
        Icon(id=13, name='ok', display_name='OK', category='status',
             lucide_name='check', material_name='check',
             lvgl_symbol='LV_SYMBOL_OK', unicode_char='\uf00c', emoji='✅',
             description='Status OK', tags='["ok", "check", "sucesso"]'),
        Icon(id=14, name='warning', display_name='Aviso', category='status',
             lucide_name='alert-triangle', material_name='warning',
             lvgl_symbol='LV_SYMBOL_WARNING', unicode_char='\uf071', emoji='⚠️',
             description='Aviso de atenção', tags='["warning", "aviso", "alerta"]'),
        Icon(id=15, name='error', display_name='Erro', category='status',
             lucide_name='x-circle', material_name='error',
             lvgl_symbol='LV_SYMBOL_CLOSE', unicode_char='\uf00d', emoji='❌',
             description='Erro ou falha', tags='["error", "erro", "falha"]'),
        Icon(id=16, name='info', display_name='Informação', category='status',
             lucide_name='info', material_name='info',
             lvgl_symbol='LV_SYMBOL_INFO', unicode_char='\uf129', emoji='ℹ️',
             description='Informação', tags='["info", "informação", "dados"]'),
        
        # Automotivo
        Icon(id=17, name='car', display_name='Veículo', category='control',
             lucide_name='car', material_name='directions_car',
             lvgl_symbol='LV_SYMBOL_CAR', unicode_char='\uf1b9', emoji='🚗',
             description='Veículo', tags='["car", "carro", "veículo"]'),
        Icon(id=18, name='winch', display_name='Guincho', category='control',
             lucide_name='anchor', material_name='build',
             lvgl_symbol='LV_SYMBOL_WINCH', unicode_char='\uf13d', emoji='⚓',
             description='Guincho elétrico', tags='["winch", "guincho", "anchor"]'),
        Icon(id=19, name='compressor', display_name='Compressor', category='control',
             lucide_name='wind', material_name='air',
             lvgl_symbol='LV_SYMBOL_AIR', unicode_char='\uf72e', emoji='💨',
             description='Compressor de ar', tags='["compressor", "ar", "air"]'),
        Icon(id=20, name='gps', display_name='GPS', category='navigation',
             lucide_name='map-pin', material_name='location_on',
             lvgl_symbol='LV_SYMBOL_GPS', unicode_char='\uf3c5', emoji='📍',
             description='Localização GPS', tags='["gps", "location", "mapa"]'),
        
        # Conectividade
        Icon(id=21, name='wifi', display_name='WiFi', category='status',
             lucide_name='wifi', material_name='wifi',
             lvgl_symbol='LV_SYMBOL_WIFI', unicode_char='\uf1eb', emoji='📶',
             description='Conexão WiFi', tags='["wifi", "wireless", "internet"]'),
        Icon(id=22, name='bluetooth', display_name='Bluetooth', category='status',
             lucide_name='bluetooth', material_name='bluetooth',
             lvgl_symbol='LV_SYMBOL_BLUETOOTH', unicode_char='\uf293', emoji='📘',
             description='Conexão Bluetooth', tags='["bluetooth", "bt", "wireless"]'),
        Icon(id=23, name='battery', display_name='Bateria', category='status',
             lucide_name='battery', material_name='battery_full',
             lvgl_symbol='LV_SYMBOL_BATTERY_FULL', unicode_char='\uf240', emoji='🔋',
             description='Status da bateria', tags='["battery", "bateria", "power"]'),
        Icon(id=24, name='signal', display_name='Sinal', category='status',
             lucide_name='signal', material_name='signal_cellular_4_bar',
             lvgl_symbol='LV_SYMBOL_SIGNAL', unicode_char='\uf012', emoji='📶',
             description='Força do sinal', tags='["signal", "sinal", "rssi"]'),
        
        # Extras
        Icon(id=25, name='refresh', display_name='Atualizar', category='control',
             lucide_name='refresh-cw', material_name='refresh',
             lvgl_symbol='LV_SYMBOL_REFRESH', unicode_char='\uf021', emoji='🔄',
             description='Atualizar/Recarregar', tags='["refresh", "reload", "atualizar"]'),
        Icon(id=26, name='save', display_name='Salvar', category='control',
             lucide_name='save', material_name='save',
             lvgl_symbol='LV_SYMBOL_SAVE', unicode_char='\uf0c7', emoji='💾',
             description='Salvar configuração', tags='["save", "salvar", "guardar"]'),
    ]
    
    session.bulk_save_objects(icons)
    session.commit()
    print(f"✓ {len(icons)} ícones criados")

def main():
    """Executa o seed de desenvolvimento"""
    print("\n" + "=" * 50)
    print("🌱 SEED DESENVOLVIMENTO - AUTOCORE")
    print("=" * 50)
    
    session = Session()
    
    try:
        # Limpar dados existentes
        clear_database(session)
        
        # Aplicar seeds na ordem correta
        seed_users(session)
        seed_devices(session)
        seed_relay_boards(session)
        seed_relay_channels(session)
        seed_screens(session)
        seed_screen_items(session)
        seed_themes(session)
        seed_can_signals(session)
        seed_icons(session)  # Adicionar ícones
        seed_macros(session)
        seed_initial_events(session)
        
        print("\n" + "=" * 50)
        print("✅ SEED DE DESENVOLVIMENTO APLICADO COM SUCESSO!")
        print("=" * 50)
        
        print("\n📊 Resumo dos dados carregados:")
        print("   • 3 Usuários (admin, lee, operador)")
        print("   • 6 Dispositivos ESP32")
        print("   • 2 Placas de relé (32 canais total)")
        print("   • 5 Telas configuradas")
        print("   • 14 Itens de tela")
        print("   • 2 Temas (Dark Offroad e Light)")
        print("   • 14 Sinais CAN FuelTech")
        print("   • 7 Macros de automação")
        print("   • 2 Eventos de sistema")
        
        print("\n💡 Observações:")
        print("   • Todos os dados foram importados do backup real")
        print("   • Senhas dos usuários mantidas do backup")
        print("   • Dispositivos com configurações originais")
        print("   • Macros prontas para uso")
        
    except Exception as e:
        session.rollback()
        print(f"\n❌ Erro ao aplicar seed: {e}")
        import traceback
        traceback.print_exc()
    finally:
        session.close()

if __name__ == '__main__':
    main()