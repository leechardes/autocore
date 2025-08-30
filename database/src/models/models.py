"""
SQLAlchemy Models para AutoCore
Definição declarativa das tabelas - fonte única de verdade
"""
from datetime import datetime
from typing import Optional
from sqlalchemy import (
    create_engine, Column, Integer, String, Boolean, 
    Float, Text, DateTime, ForeignKey, UniqueConstraint, 
    Index, CheckConstraint, Table
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, sessionmaker
from sqlalchemy.sql import func

Base = declarative_base()

# ====================================
# VALID VALUES (formerly Enums)
# ====================================

# item_type - Tipos de itens da interface
# Valores válidos: ['display', 'button', 'switch', 'gauge']

# action_type - Tipos de ação para itens interativos  
# Valores válidos: ['relay_control', 'command', 'macro', 'navigation', 'preset', null]

# device_type - Tipos de dispositivos ESP32
# Valores válidos: ['esp32_relay', 'esp32_display', 'sensor_board', 'gateway']

# device_status - Status dos dispositivos
# Valores válidos: ['online', 'offline', 'error', 'maintenance']

# function_type - Tipos de função dos relés
# Valores válidos: ['toggle', 'momentary', 'pulse', 'timer']

# protection_mode - Modos de proteção dos relés
# Valores válidos: ['none', 'interlock', 'exclusive', 'timed']

# ====================================
# CORE MODELS
# ====================================

class Device(Base):
    """Dispositivos ESP32 do sistema"""
    __tablename__ = 'devices'
    
    id = Column(Integer, primary_key=True)
    uuid = Column(String(36), unique=True, nullable=False)
    name = Column(String(100), nullable=False)
    type = Column(String(50), nullable=False)  # device_type: esp32_relay, esp32_display, sensor_board, gateway
    mac_address = Column(String(17), unique=True, nullable=True)
    ip_address = Column(String(15), nullable=True)
    firmware_version = Column(String(20), nullable=True)
    hardware_version = Column(String(20), nullable=True)
    status = Column(String(20), default='offline', nullable=False)  # device_status: online, offline, error, maintenance
    last_seen = Column(DateTime, nullable=True)
    configuration_json = Column(Text, nullable=True)
    capabilities_json = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Relacionamentos
    relay_boards = relationship("RelayBoard", back_populates="device", cascade="all, delete-orphan")
    telemetry_data = relationship("TelemetryData", back_populates="device", cascade="all, delete-orphan")
    vehicles = relationship("Vehicle", secondary="vehicle_devices", back_populates="devices")
    
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
    function_type = Column(String(20), nullable=True)  # function_type: toggle, momentary, pulse, timer
    icon = Column(String(50), nullable=True)
    color = Column(String(7), nullable=True)  # Hex color
    protection_mode = Column(String(20), default='none', nullable=False)  # protection_mode: none, interlock, exclusive, timed
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
    item_type = Column(String(20), nullable=False)  # item_type: display, button, switch, gauge
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
    action_type = Column(String(30), nullable=True)  # action_type: relay_control, command, macro, navigation, preset
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
    
    # Constraints e Índices
    __table_args__ = (
        # Check constraint para consistência entre item_type e action_type
        CheckConstraint(
            "(item_type IN ('display', 'gauge') AND action_type IS NULL) OR "
            "(item_type IN ('button', 'switch') AND action_type IS NOT NULL)",
            name='check_item_action_consistency'
        ),
        # Check constraint para relés obrigatórios em relay_control
        CheckConstraint(
            "action_type != 'relay_control' OR "
            "(action_type = 'relay_control' AND relay_board_id IS NOT NULL AND relay_channel_id IS NOT NULL)",
            name='check_relay_control_requirements'
        ),
        # Check constraint para dados obrigatórios em displays/gauges
        CheckConstraint(
            "item_type NOT IN ('display', 'gauge') OR "
            "(item_type IN ('display', 'gauge') AND data_source IS NOT NULL AND data_path IS NOT NULL)",
            name='check_display_data_requirements'
        ),
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
    
    # Relacionamentos
    vehicles = relationship("Vehicle", back_populates="owner")
    
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
# VEHICLE MANAGEMENT
# ====================================

# Tabela associativa Vehicle-Device (N:M)
vehicle_devices = Table(
    'vehicle_devices',
    Base.metadata,
    Column('vehicle_id', Integer, ForeignKey('vehicles.id', ondelete='CASCADE'), primary_key=True),
    Column('device_id', Integer, ForeignKey('devices.id', ondelete='CASCADE'), primary_key=True),
    Column('device_role', String(30), default='secondary'),  # primary, secondary, tracker, etc
    Column('installed_at', DateTime, default=func.now()),
    Column('is_active', Boolean, default=True),
    
    # Index para queries comuns
    Index('idx_vehicle_devices_vehicle', 'vehicle_id'),
    Index('idx_vehicle_devices_device', 'device_id'),
    Index('idx_vehicle_devices_role', 'device_role'),
)

class Vehicle(Base):
    """
    Veículos cadastrados no sistema AutoCore - APENAS 1 REGISTRO PERMITIDO
    
    Sistema modificado para suportar apenas 1 veículo único no sistema:
    - ID fixo = 1 para garantir unicidade
    - Constraint check_single_vehicle_record para validar
    - Identificação oficial (placa, chassi, renavam)
    - Dados técnicos (marca, modelo, motorização)
    - Relacionamento com usuários proprietários
    - Integração com dispositivos ESP32
    - Controle de manutenção e vencimentos
    - Telemetria e localização
    """
    __tablename__ = 'vehicles'
    
    # ================================
    # PRIMARY KEY & IDENTIFICATION
    # ================================
    
    id = Column(Integer, primary_key=True, default=1)  # ID fixo para garantir apenas 1 registro
    uuid = Column(String(36), unique=True, nullable=False)
    
    # Identificação oficial brasileira
    plate = Column(String(10), unique=True, nullable=False)      # ABC1234 ou ABC1D23
    chassis = Column(String(30), unique=True, nullable=False)    # Chassi/VIN
    renavam = Column(String(20), unique=True, nullable=False)    # Código RENAVAM
    
    # ================================
    # VEHICLE INFORMATION
    # ================================
    
    # Basic info
    brand = Column(String(50), nullable=False)           # Toyota, Ford, Honda, etc
    model = Column(String(100), nullable=False)          # Corolla, Focus, Civic, etc  
    version = Column(String(100), nullable=True)         # XEI, Titanium, LX, etc
    year_manufacture = Column(Integer, nullable=False)   # Ano de fabricação
    year_model = Column(Integer, nullable=False)         # Ano modelo
    
    # Appearance
    color = Column(String(30), nullable=True)            # Branco, Preto, Prata, etc
    color_code = Column(String(10), nullable=True)       # Código da cor do fabricante
    
    # ================================
    # ENGINE & TECHNICAL
    # ================================
    
    # Fuel and propulsion
    fuel_type = Column(String(20), nullable=False)       # flex, gasoline, ethanol, diesel, electric, hybrid
    
    # Engine specs
    engine_capacity = Column(Integer, nullable=True)     # Cilindradas em cc
    engine_power = Column(Integer, nullable=True)        # Potência em cv
    engine_torque = Column(Integer, nullable=True)       # Torque em Nm
    transmission = Column(String(20), nullable=True)     # manual, automatic, cvt
    
    # Category
    category = Column(String(30), nullable=False)        # passenger, commercial, motorcycle, truck, bus
    usage_type = Column(String(30), nullable=True)       # personal, commercial, fleet, taxi
    
    # ================================
    # RELATIONSHIPS
    # ================================
    
    # Owner (obrigatório)
    user_id = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    
    # Primary device (opcional, um ESP32 principal)
    primary_device_id = Column(Integer, ForeignKey('devices.id', ondelete='SET NULL'), nullable=True)
    
    # ================================
    # STATUS & TELEMETRY
    # ================================
    
    # Operational status
    status = Column(String(20), default='inactive', nullable=False)  # active, inactive, maintenance, retired, sold
    
    # Mileage
    odometer = Column(Integer, default=0, nullable=False)            # Quilometragem atual
    odometer_unit = Column(String(5), default='km', nullable=False)  # km, mi
    
    # Location (JSON format)
    last_location = Column(Text, nullable=True)                      # {"lat": -23.55, "lng": -46.63, "timestamp": "2025-01-28T10:30:00Z", "accuracy": 5}
    
    # ================================
    # MAINTENANCE & EXPIRY
    # ================================
    
    # Next maintenance
    next_maintenance_date = Column(DateTime, nullable=True)
    next_maintenance_km = Column(Integer, nullable=True)
    
    # Important expiry dates
    insurance_expiry = Column(DateTime, nullable=True)               # Vencimento do seguro
    license_expiry = Column(DateTime, nullable=True)                 # Vencimento do licenciamento
    inspection_expiry = Column(DateTime, nullable=True)              # Vencimento da vistoria
    
    # Last maintenance
    last_maintenance_date = Column(DateTime, nullable=True)
    last_maintenance_km = Column(Integer, nullable=True)
    
    # ================================
    # CONFIGURATION & METADATA
    # ================================
    
    # Vehicle-specific configuration (JSON)
    vehicle_config = Column(Text, nullable=True)                     # JSON para configurações específicas
    
    # Notes and tags
    notes = Column(Text, nullable=True)                              # Notas livres
    tags = Column(Text, nullable=True)                               # JSON array: ["pessoal", "familia", "trabalho"]
    
    # System flags
    is_active = Column(Boolean, default=True, nullable=False)        # Ativo no sistema
    is_tracked = Column(Boolean, default=True, nullable=False)       # Deve ser rastreado/monitorado
    
    # ================================
    # AUDIT FIELDS (OBRIGATÓRIO)
    # ================================
    
    created_at = Column(DateTime, default=func.now(), nullable=False)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), nullable=False)
    deleted_at = Column(DateTime, nullable=True)                     # Soft delete
    
    # ================================
    # RELATIONSHIPS
    # ================================
    
    # Owner relationship
    owner = relationship("User", back_populates="vehicles")
    
    # Primary device relationship
    primary_device = relationship("Device", foreign_keys=[primary_device_id])
    
    # Multiple devices (many-to-many através de tabela associativa)
    devices = relationship("Device", 
                         secondary="vehicle_devices",
                         back_populates="vehicles")
    
    # ================================
    # CONSTRAINTS & INDEXES
    # ================================
    
    __table_args__ = (
        # CONSTRAINT PRIMÁRIO: Garantir apenas 1 registro com ID = 1
        CheckConstraint('id = 1', name='check_single_vehicle_record'),
        
        # Unique indexes
        Index('idx_vehicles_uuid', 'uuid'),
        Index('idx_vehicles_plate', 'plate'),
        Index('idx_vehicles_chassis', 'chassis'), 
        Index('idx_vehicles_renavam', 'renavam'),
        
        # Search indexes
        Index('idx_vehicles_brand_model', 'brand', 'model'),
        Index('idx_vehicles_user', 'user_id'),
        Index('idx_vehicles_status', 'status'),
        Index('idx_vehicles_active', 'is_active'),
        Index('idx_vehicles_tracked', 'is_tracked'),
        
        # Composite indexes for common queries
        Index('idx_vehicles_user_active', 'user_id', 'is_active'),
        Index('idx_vehicles_brand_year', 'brand', 'year_model'),
        Index('idx_vehicles_status_active', 'status', 'is_active'),
        
        # Check constraints for data validation
        CheckConstraint(
            "fuel_type IN ('flex', 'gasoline', 'ethanol', 'diesel', 'electric', 'hybrid')",
            name='check_vehicles_valid_fuel_type'
        ),
        CheckConstraint(
            "category IN ('passenger', 'commercial', 'motorcycle', 'truck', 'bus')",
            name='check_vehicles_valid_category'
        ),
        CheckConstraint(
            "status IN ('active', 'inactive', 'maintenance', 'retired', 'sold')",
            name='check_vehicles_valid_status'
        ),
        CheckConstraint(
            "year_manufacture >= 1900 AND year_manufacture <= 2030",
            name='check_vehicles_valid_manufacture_year'
        ),
        CheckConstraint(
            "year_model >= year_manufacture AND year_model <= (year_manufacture + 1)",
            name='check_vehicles_valid_model_year'
        ),
        CheckConstraint(
            "odometer >= 0",
            name='check_vehicles_valid_odometer'
        ),
        CheckConstraint(
            "length(plate) >= 7 AND length(plate) <= 8",  # ABC1234 (7) ou ABC1D23 (8)
            name='check_vehicles_valid_plate_format'
        ),
        CheckConstraint(
            "length(chassis) >= 17",  # VIN padrão tem 17 caracteres
            name='check_vehicles_valid_chassis_length'
        ),
    )
    
    # ================================
    # CLASS METHODS (REGISTRO ÚNICO)
    # ================================
    
    @classmethod
    def get_single_instance(cls, session):
        """
        Retorna o único registro de veículo, criando se não existir
        
        Args:
            session: Sessão SQLAlchemy ativa
            
        Returns:
            Instância do Vehicle (ID = 1)
        """
        vehicle = session.query(cls).filter(cls.id == 1).first()
        if not vehicle:
            # Cria registro com ID fixo = 1 (dados mínimos)
            vehicle = cls(
                id=1,
                uuid=str(__import__('uuid').uuid4()),
                plate='PENDING',
                chassis='PENDING' + 'X' * 12,  # 17 chars mínimo
                renavam='PENDING',
                brand='Pendente',
                model='Pendente',
                year_manufacture=2020,
                year_model=2020,
                fuel_type='flex',
                category='passenger',
                user_id=1,  # Assume user ID 1 existe
                status='inactive'
            )
            session.add(vehicle)
            session.flush()
        return vehicle
    
    # ================================
    # INSTANCE METHODS
    # ================================
    
    def __repr__(self):
        return f"<Vehicle {self.plate} - {self.brand} {self.model} ({self.year_model})>"
    
    def __str__(self):
        return f"{self.brand} {self.model} {self.year_model} - {self.plate}"
    
    @property
    def full_name(self):
        """Nome completo do veículo"""
        parts = [self.brand, self.model]
        if self.version:
            parts.append(self.version)
        parts.append(str(self.year_model))
        return " ".join(parts)
    
    @property
    def age_years(self):
        """Idade do veículo em anos"""
        from datetime import datetime
        return datetime.now().year - self.year_model
    
    @property
    def is_online(self):
        """Verifica se veículo está online (via device principal)"""
        if self.primary_device:
            return self.primary_device.status == 'online'
        return False
    
    @property
    def needs_maintenance(self):
        """Verifica se precisa de manutenção"""
        from datetime import datetime, timedelta
        
        # Check date
        if self.next_maintenance_date:
            if self.next_maintenance_date <= datetime.now():
                return True
        
        # Check km
        if self.next_maintenance_km:
            if self.odometer >= self.next_maintenance_km:
                return True
        
        return False
    
    @property
    def has_expired_documents(self):
        """Verifica se tem documentos vencidos"""
        from datetime import datetime
        now = datetime.now()
        
        return any([
            self.insurance_expiry and self.insurance_expiry <= now,
            self.license_expiry and self.license_expiry <= now,
            self.inspection_expiry and self.inspection_expiry <= now,
        ])
    
    def update_location(self, latitude: float, longitude: float, accuracy: int = None):
        """Atualiza localização do veículo"""
        import json
        from datetime import datetime
        
        location_data = {
            'lat': latitude,
            'lng': longitude,
            'timestamp': datetime.now().isoformat(),
        }
        
        if accuracy:
            location_data['accuracy'] = accuracy
        
        self.last_location = json.dumps(location_data)
    
    def get_location(self):
        """Retorna localização como dict"""
        if not self.last_location:
            return None
        
        import json
        try:
            return json.loads(self.last_location)
        except (json.JSONDecodeError, TypeError):
            return None
    
    def update_odometer(self, new_km: int):
        """Atualiza quilometragem com validação"""
        if new_km >= self.odometer:
            self.odometer = new_km
            return True
        return False

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