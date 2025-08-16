"""
SQLAlchemy Models para AutoCore
Definição declarativa das tabelas - fonte única de verdade
"""
from datetime import datetime
from typing import Optional
from sqlalchemy import (
    create_engine, Column, Integer, String, Boolean, 
    Float, Text, DateTime, ForeignKey, UniqueConstraint, Index
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, sessionmaker
from sqlalchemy.sql import func

Base = declarative_base()

# ====================================
# CORE MODELS
# ====================================

class Device(Base):
    """Dispositivos ESP32 do sistema"""
    __tablename__ = 'devices'
    
    id = Column(Integer, primary_key=True)
    uuid = Column(String(36), unique=True, nullable=False)
    name = Column(String(100), nullable=False)
    type = Column(String(50), nullable=False)  # esp32_relay, esp32_display, etc
    mac_address = Column(String(17), unique=True, nullable=True)
    ip_address = Column(String(15), nullable=True)
    firmware_version = Column(String(20), nullable=True)
    hardware_version = Column(String(20), nullable=True)
    status = Column(String(20), default='offline')
    last_seen = Column(DateTime, nullable=True)
    configuration_json = Column(Text, nullable=True)
    capabilities_json = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Relacionamentos
    relay_boards = relationship("RelayBoard", back_populates="device", cascade="all, delete-orphan")
    telemetry_data = relationship("TelemetryData", back_populates="device", cascade="all, delete-orphan")
    
    # Índices
    __table_args__ = (
        Index('idx_devices_uuid', 'uuid'),
        Index('idx_devices_type', 'type'),
        Index('idx_devices_status', 'status'),
    )

class RelayBoard(Base):
    """Placas de relé conectadas aos dispositivos"""
    __tablename__ = 'relay_boards'
    
    id = Column(Integer, primary_key=True)
    device_id = Column(Integer, ForeignKey('devices.id', ondelete='CASCADE'), nullable=False)
    total_channels = Column(Integer, default=16, nullable=False)
    board_model = Column(String(50), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    
    # Relacionamentos
    device = relationship("Device", back_populates="relay_boards")
    channels = relationship("RelayChannel", back_populates="board", cascade="all, delete-orphan")
    
    # Índices
    __table_args__ = (
        Index('idx_relay_boards_device', 'device_id'),
    )

class RelayChannel(Base):
    """Canais individuais de relé"""
    __tablename__ = 'relay_channels'
    
    id = Column(Integer, primary_key=True)
    board_id = Column(Integer, ForeignKey('relay_boards.id', ondelete='CASCADE'), nullable=False)
    channel_number = Column(Integer, nullable=False)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    function_type = Column(String(50), nullable=True)  # toggle, momentary, pulse
    icon = Column(String(50), nullable=True)
    color = Column(String(7), nullable=True)  # Hex color
    protection_mode = Column(String(20), nullable=True)  # none, confirm, password
    max_activation_time = Column(Integer, nullable=True)  # segundos
    allow_in_macro = Column(Boolean, default=True)  # Permitir usar em macros
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Relacionamentos
    board = relationship("RelayBoard", back_populates="channels")
    
    # Constraints e Índices
    __table_args__ = (
        UniqueConstraint('board_id', 'channel_number', name='uq_board_channel'),
        Index('idx_relay_channels_board', 'board_id'),
    )

# ====================================
# UI CONFIGURATION
# ====================================

class Screen(Base):
    """Telas da interface"""
    __tablename__ = 'screens'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    title = Column(String(100), nullable=False)
    icon = Column(String(50), nullable=True)
    screen_type = Column(String(50), nullable=True)  # dashboard, control, settings
    parent_id = Column(Integer, ForeignKey('screens.id'), nullable=True)
    position = Column(Integer, default=0, nullable=False)
    
    # Layout por dispositivo
    columns_mobile = Column(Integer, default=2)
    columns_display_small = Column(Integer, default=2)
    columns_display_large = Column(Integer, default=4)
    columns_web = Column(Integer, default=4)
    
    is_visible = Column(Boolean, default=True)
    required_permission = Column(String(50), nullable=True)
    
    # Visibilidade por dispositivo
    show_on_mobile = Column(Boolean, default=True)
    show_on_display_small = Column(Boolean, default=True)
    show_on_display_large = Column(Boolean, default=True)
    show_on_web = Column(Boolean, default=True)
    show_on_controls = Column(Boolean, default=False)
    
    created_at = Column(DateTime, default=func.now())
    
    # Relacionamentos
    items = relationship("ScreenItem", back_populates="screen", cascade="all, delete-orphan")
    
    # Índices
    __table_args__ = (
        Index('idx_screens_parent', 'parent_id'),
        Index('idx_screens_position', 'position'),
    )

class ScreenItem(Base):
    """Itens das telas"""
    __tablename__ = 'screen_items'
    
    id = Column(Integer, primary_key=True)
    screen_id = Column(Integer, ForeignKey('screens.id', ondelete='CASCADE'), nullable=False)
    item_type = Column(String(50), nullable=False)  # button, switch, gauge, display
    name = Column(String(100), nullable=False)
    label = Column(String(100), nullable=False)
    icon = Column(String(50), nullable=True)
    position = Column(Integer, nullable=False)
    
    # Tamanhos por dispositivo
    size_mobile = Column(String(20), default='normal')
    size_display_small = Column(String(20), default='normal')
    size_display_large = Column(String(20), default='normal')
    size_web = Column(String(20), default='normal')
    
    # Configuração de ação
    action_type = Column(String(50), nullable=True)
    action_target = Column(String(200), nullable=True)
    action_payload = Column(Text, nullable=True)
    
    # Campos específicos para relés
    relay_board_id = Column(Integer, ForeignKey('relay_boards.id', ondelete='SET NULL'), nullable=True)
    relay_channel_id = Column(Integer, ForeignKey('relay_channels.id', ondelete='SET NULL'), nullable=True)
    
    # Configuração de dados
    data_source = Column(String(50), nullable=True)
    data_path = Column(String(200), nullable=True)
    data_format = Column(String(50), nullable=True)
    data_unit = Column(String(20), nullable=True)
    
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    
    # Relacionamentos
    screen = relationship("Screen", back_populates="items")
    
    # Índices
    __table_args__ = (
        Index('idx_screen_items_screen_pos', 'screen_id', 'position'),
    )

# ====================================
# TELEMETRY & LOGS
# ====================================

class TelemetryData(Base):
    """Dados de telemetria dos dispositivos"""
    __tablename__ = 'telemetry_data'
    
    id = Column(Integer, primary_key=True)
    timestamp = Column(DateTime, default=func.now(), nullable=False)
    device_id = Column(Integer, ForeignKey('devices.id', ondelete='CASCADE'), nullable=False)
    data_type = Column(String(50), nullable=False)
    data_key = Column(String(100), nullable=False)
    data_value = Column(Text, nullable=False)
    unit = Column(String(20), nullable=True)
    
    # Relacionamentos
    device = relationship("Device", back_populates="telemetry_data")
    
    # Índices para performance
    __table_args__ = (
        Index('idx_telemetry_timestamp', 'timestamp', 'device_id'),
        Index('idx_telemetry_type', 'data_type'),
        Index('idx_telemetry_key', 'data_key'),
    )

class EventLog(Base):
    """Logs de eventos do sistema"""
    __tablename__ = 'event_logs'
    
    id = Column(Integer, primary_key=True)
    timestamp = Column(DateTime, default=func.now(), nullable=False)
    event_type = Column(String(50), nullable=False)
    source = Column(String(100), nullable=False)
    target = Column(String(100), nullable=True)
    action = Column(String(100), nullable=True)
    payload = Column(Text, nullable=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    ip_address = Column(String(15), nullable=True)
    status = Column(String(20), nullable=True)
    error_message = Column(Text, nullable=True)
    
    # Relacionamentos
    user = relationship("User")
    
    # Índices
    __table_args__ = (
        Index('idx_events_timestamp', 'timestamp'),
        Index('idx_events_type', 'event_type'),
        Index('idx_events_source', 'source'),
    )

# ====================================
# USER MANAGEMENT
# ====================================

class User(Base):
    """Usuários do sistema"""
    __tablename__ = 'users'
    
    id = Column(Integer, primary_key=True)
    username = Column(String(50), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    full_name = Column(String(100), nullable=True)
    email = Column(String(100), unique=True, nullable=True)
    role = Column(String(50), default='operator', nullable=False)
    pin_code = Column(String(10), nullable=True)
    is_active = Column(Boolean, default=True)
    last_login = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Índices
    __table_args__ = (
        Index('idx_users_username', 'username'),
        Index('idx_users_email', 'email'),
        Index('idx_users_role', 'role'),
    )

# ====================================
# CAN CONFIGURATION
# ====================================

class CANSignal(Base):
    """Sinais CAN mapeados"""
    __tablename__ = 'can_signals'
    
    id = Column(Integer, primary_key=True)
    signal_name = Column(String(100), unique=True, nullable=False)
    can_id = Column(String(8), nullable=False)  # Hex
    start_bit = Column(Integer, nullable=False)
    length_bits = Column(Integer, nullable=False)
    byte_order = Column(String(20), nullable=True)
    data_type = Column(String(20), nullable=True)
    scale_factor = Column(Float, default=1.0)
    offset = Column(Float, default=0.0)
    unit = Column(String(20), nullable=True)
    min_value = Column(Float, nullable=True)
    max_value = Column(Float, nullable=True)
    description = Column(Text, nullable=True)
    category = Column(String(50), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    
    # Índices
    __table_args__ = (
        Index('idx_can_signals_name', 'signal_name'),
        Index('idx_can_signals_id', 'can_id'),
    )

# ====================================
# THEMES
# ====================================

class Theme(Base):
    """Temas visuais"""
    __tablename__ = 'themes'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100), unique=True, nullable=False)
    description = Column(Text, nullable=True)
    
    # Cores
    primary_color = Column(String(7), nullable=False)
    secondary_color = Column(String(7), nullable=False)
    background_color = Column(String(7), nullable=False)
    surface_color = Column(String(7), nullable=False)
    success_color = Column(String(7), nullable=False)
    warning_color = Column(String(7), nullable=False)
    error_color = Column(String(7), nullable=False)
    info_color = Column(String(7), nullable=False)
    text_primary = Column(String(7), nullable=False)
    text_secondary = Column(String(7), nullable=False)
    
    # Configurações
    border_radius = Column(Integer, default=12)
    shadow_style = Column(String(50), default='neumorphic')
    font_family = Column(String(100), nullable=True)
    
    is_active = Column(Boolean, default=True)
    is_default = Column(Boolean, default=False)
    created_at = Column(DateTime, default=func.now())

# ====================================
# MACROS & AUTOMATION
# ====================================

class Macro(Base):
    """Macros e automações"""
    __tablename__ = 'macros'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100), unique=True, nullable=False)
    description = Column(Text, nullable=True)
    trigger_type = Column(String(50), nullable=True)  # manual, scheduled, condition
    trigger_config = Column(Text, nullable=True)  # JSON
    action_sequence = Column(Text, nullable=False)  # JSON
    condition_logic = Column(Text, nullable=True)  # JSON
    is_active = Column(Boolean, default=True)
    last_executed = Column(DateTime, nullable=True)
    execution_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=func.now())

# ====================================
# ICONS MANAGEMENT
# ====================================

class Icon(Base):
    """Ícones do sistema para diferentes plataformas"""
    __tablename__ = 'icons'
    
    # Identificação
    id = Column(Integer, primary_key=True)
    name = Column(String(50), unique=True, nullable=False)
    display_name = Column(String(100), nullable=False)
    category = Column(String(50), nullable=True)
    
    # SVG Customizado
    svg_content = Column(Text, nullable=True)
    svg_viewbox = Column(String(50), nullable=True)
    svg_fill_color = Column(String(7), nullable=True)
    svg_stroke_color = Column(String(7), nullable=True)
    
    # Mapeamentos para Bibliotecas
    lucide_name = Column(String(50), nullable=True)
    material_name = Column(String(50), nullable=True)
    fontawesome_name = Column(String(50), nullable=True)
    lvgl_symbol = Column(String(50), nullable=True)
    
    # Fallbacks e Alternativas
    unicode_char = Column(String(10), nullable=True)
    emoji = Column(String(10), nullable=True)
    fallback_icon_id = Column(Integer, ForeignKey('icons.id', ondelete='SET NULL'), nullable=True)
    
    # Metadados
    description = Column(Text, nullable=True)
    tags = Column(Text, nullable=True)  # JSON array
    is_custom = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Relacionamentos
    fallback_icon = relationship("Icon", remote_side=[id])
    
    # Índices
    __table_args__ = (
        Index('idx_icons_name', 'name'),
        Index('idx_icons_category', 'category'),
        Index('idx_icons_active', 'is_active'),
    )

# ====================================
# ENGINE & SESSION
# ====================================

def get_engine(db_path='autocore.db'):
    """Cria engine do SQLAlchemy"""
    engine = create_engine(
        f'sqlite:///{db_path}',
        connect_args={'check_same_thread': False},
        echo=False  # True para debug
    )
    return engine

def create_all_tables(engine=None):
    """Cria todas as tabelas"""
    if not engine:
        engine = get_engine()
    Base.metadata.create_all(engine)
    return engine

def get_session(engine=None):
    """Cria sessão do SQLAlchemy"""
    if not engine:
        engine = get_engine()
    Session = sessionmaker(bind=engine)
    return Session()

if __name__ == '__main__':
    # Teste: criar todas as tabelas
    print("Criando tabelas do modelo...")
    engine = create_all_tables()
    print(f"✅ Tabelas criadas com sucesso!")
    
    # Lista tabelas criadas
    from sqlalchemy import inspect
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    print(f"\n📋 Tabelas criadas ({len(tables)}):")
    for table in tables:
        print(f"  • {table}")