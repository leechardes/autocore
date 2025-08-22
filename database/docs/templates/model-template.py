"""
Template para criação de novos SQLAlchemy Models no AutoCore
Este template segue as convenções e padrões do sistema
"""
from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Boolean, Text, DateTime, 
    ForeignKey, UniqueConstraint, Index, CheckConstraint
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

# Import base do projeto
from src.models.models import Base

class NewModel(Base):
    """
    [DESCRIÇÃO DO MODEL]
    
    Descrição detalhada do propósito e uso do model.
    Inclua exemplos de uso e relacionamentos importantes.
    
    Exemplo:
        new_item = NewModel(
            name="Example Item",
            type="example_type",
            is_active=True
        )
        session.add(new_item)
        session.commit()
    """
    __tablename__ = 'new_models'  # Plural, snake_case
    
    # ====================================
    # PRIMARY KEY
    # ====================================
    id = Column(Integer, primary_key=True)
    
    # ====================================
    # IDENTIFICATION FIELDS
    # ====================================
    # Nome único do item (obrigatório para referência)
    name = Column(String(100), unique=True, nullable=False)
    
    # Título para exibição (pode ser diferente do name)
    title = Column(String(100), nullable=False)
    
    # Tipo/categoria do item (usar constantes validadas)
    type = Column(String(50), nullable=False)  # Ver VALID_TYPES abaixo
    
    # ====================================
    # DESCRIPTIVE FIELDS
    # ====================================
    description = Column(Text, nullable=True)
    
    # Ícone para UI (referência ao sistema de ícones)
    icon = Column(String(50), nullable=True)
    
    # Categoria para agrupamento/organização
    category = Column(String(50), nullable=True)
    
    # ====================================
    # CONFIGURATION FIELDS
    # ====================================
    # Configuração em JSON (para flexibilidade)
    configuration_json = Column(Text, nullable=True)
    
    # Campos específicos do domínio
    # priority = Column(Integer, default=0, nullable=False)
    # max_value = Column(Float, nullable=True)
    # external_id = Column(String(100), nullable=True)
    
    # ====================================
    # RELATIONSHIP FIELDS (Foreign Keys)
    # ====================================
    # Relacionamento com parent (se hierárquico)
    parent_id = Column(Integer, ForeignKey('new_models.id'), nullable=True)
    
    # Relacionamento com User (se necessário)
    # owner_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    
    # Relacionamento com Device (se relacionado a hardware)
    # device_id = Column(Integer, ForeignKey('devices.id'), nullable=True)
    
    # ====================================
    # STATUS FIELDS
    # ====================================
    is_active = Column(Boolean, default=True, nullable=False)
    is_public = Column(Boolean, default=False, nullable=False)
    
    # ====================================
    # AUDIT FIELDS (sempre incluir)
    # ====================================
    created_at = Column(DateTime, default=func.now(), nullable=False)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), nullable=False)
    
    # ====================================
    # RELATIONSHIPS (SQLAlchemy)
    # ====================================
    
    # Self-reference para hierarquia (se aplicável)
    children = relationship("NewModel", back_populates="parent")
    parent = relationship("NewModel", remote_side=[id], back_populates="children")
    
    # Relacionamento com User (se aplicável)
    # owner = relationship("User")
    
    # Relacionamento 1:N (este model é parent)
    # related_items = relationship("RelatedModel", back_populates="new_model", 
    #                             cascade="all, delete-orphan")
    
    # ====================================
    # TABLE CONSTRAINTS & INDEXES
    # ====================================
    __table_args__ = (
        # Unique constraints para combinações únicas
        # UniqueConstraint('name', 'category', name='uq_name_category'),
        
        # Check constraints para validação de dados
        CheckConstraint(
            "type IN ('type_a', 'type_b', 'type_c')",
            name='check_valid_type'
        ),
        
        # Check constraint para campos obrigatórios condicionais
        # CheckConstraint(
        #     "is_active = false OR (is_active = true AND configuration_json IS NOT NULL)",
        #     name='check_active_requires_config'
        # ),
        
        # Índices para performance
        Index('idx_new_models_name', 'name'),
        Index('idx_new_models_type', 'type'),
        Index('idx_new_models_category', 'category'),
        Index('idx_new_models_active', 'is_active'),
        Index('idx_new_models_parent', 'parent_id'),
        
        # Índice composto para queries frequentes
        Index('idx_new_models_type_active', 'type', 'is_active'),
    )

# ====================================
# VALID VALUES (substituto para Enums)
# ====================================

# Tipos válidos para o campo 'type'
VALID_TYPES = [
    'type_a',     # Descrição do tipo A
    'type_b',     # Descrição do tipo B  
    'type_c',     # Descrição do tipo C
]

# Categorias válidas (se aplicável)
VALID_CATEGORIES = [
    'category_1',  # Descrição da categoria 1
    'category_2',  # Descrição da categoria 2
]

# ====================================
# HELPER FUNCTIONS
# ====================================

def get_active_items(session, type_filter=None, category_filter=None):
    """
    Helper function para buscar itens ativos
    
    Args:
        session: SQLAlchemy session
        type_filter: Filtro por tipo (opcional)
        category_filter: Filtro por categoria (opcional)
        
    Returns:
        List[NewModel]: Lista de itens ativos
    """
    query = session.query(NewModel).filter_by(is_active=True)
    
    if type_filter:
        query = query.filter_by(type=type_filter)
    
    if category_filter:
        query = query.filter_by(category=category_filter)
    
    return query.order_by(NewModel.name).all()

def create_default_item(session, name: str, title: str, type: str):
    """
    Helper function para criar item com valores padrão
    
    Args:
        session: SQLAlchemy session
        name: Nome único do item
        title: Título para exibição
        type: Tipo do item (deve estar em VALID_TYPES)
        
    Returns:
        NewModel: Item criado
    """
    if type not in VALID_TYPES:
        raise ValueError(f"Tipo inválido: {type}. Tipos válidos: {VALID_TYPES}")
    
    item = NewModel(
        name=name,
        title=title,
        type=type,
        is_active=True
    )
    
    session.add(item)
    return item

# ====================================
# MIGRATION HELPER
# ====================================

def create_table_migration():
    """
    Helper para gerar código da migration
    
    Este código deve ser usado no arquivo de migration do Alembic:
    
    def upgrade() -> None:
        op.create_table('new_models',
            sa.Column('id', sa.Integer(), nullable=False),
            sa.Column('name', sa.String(length=100), nullable=False),
            sa.Column('title', sa.String(length=100), nullable=False),
            sa.Column('type', sa.String(length=50), nullable=False),
            sa.Column('description', sa.Text(), nullable=True),
            sa.Column('icon', sa.String(length=50), nullable=True),
            sa.Column('category', sa.String(length=50), nullable=True),
            sa.Column('configuration_json', sa.Text(), nullable=True),
            sa.Column('parent_id', sa.Integer(), nullable=True),
            sa.Column('is_active', sa.Boolean(), nullable=False),
            sa.Column('is_public', sa.Boolean(), nullable=False),
            sa.Column('created_at', sa.DateTime(), nullable=False),
            sa.Column('updated_at', sa.DateTime(), nullable=False),
            sa.CheckConstraint("type IN ('type_a', 'type_b', 'type_c')", name='check_valid_type'),
            sa.ForeignKeyConstraint(['parent_id'], ['new_models.id'], ),
            sa.PrimaryKeyConstraint('id'),
            sa.UniqueConstraint('name')
        )
        
        # Índices
        op.create_index('idx_new_models_name', 'new_models', ['name'], unique=False)
        op.create_index('idx_new_models_type', 'new_models', ['type'], unique=False)
        op.create_index('idx_new_models_category', 'new_models', ['category'], unique=False)
        op.create_index('idx_new_models_active', 'new_models', ['is_active'], unique=False)
        op.create_index('idx_new_models_parent', 'new_models', ['parent_id'], unique=False)
        op.create_index('idx_new_models_type_active', 'new_models', ['type', 'is_active'], unique=False)
    
    def downgrade() -> None:
        op.drop_index('idx_new_models_type_active', table_name='new_models')
        op.drop_index('idx_new_models_parent', table_name='new_models')
        op.drop_index('idx_new_models_active', table_name='new_models')
        op.drop_index('idx_new_models_category', table_name='new_models')
        op.drop_index('idx_new_models_type', table_name='new_models')
        op.drop_index('idx_new_models_name', table_name='new_models')
        op.drop_table('new_models')
    """
    pass

# ====================================
# USAGE EXAMPLES
# ====================================

if __name__ == '__main__':
    """
    Exemplos de uso do model
    """
    from src.models.models import get_session
    
    session = get_session()
    
    # Criar novo item
    item = NewModel(
        name="example_item",
        title="Item de Exemplo",
        type="type_a",
        description="Descrição do item de exemplo",
        category="category_1",
        is_active=True
    )
    session.add(item)
    
    # Buscar itens ativos
    active_items = get_active_items(session, type_filter="type_a")
    
    # Criar item com helper
    default_item = create_default_item(
        session, 
        "default_example", 
        "Exemplo Padrão", 
        "type_b"
    )
    
    session.commit()
    print(f"✅ Criados {len(active_items) + 2} itens de exemplo")