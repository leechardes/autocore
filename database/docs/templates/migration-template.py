"""
Template para criação de migrations Alembic no AutoCore
Este template segue as convenções e padrões do sistema

INSTRUÇÕES DE USO:
1. Copie este template
2. Substitua [PLACEHOLDERS] pelos valores apropriados
3. Ajuste as operações conforme necessário
4. Teste upgrade E downgrade antes de aplicar

COMANDO PARA GERAR MIGRATION:
alembic revision --autogenerate -m "[DESCRIÇÃO_DA_MUDANÇA]"
"""

"""[TÍTULO_DA_MIGRATION]

Revision ID: [REVISION_ID]
Revises: [PREVIOUS_REVISION]
Create Date: [TIMESTAMP]

[DESCRIÇÃO_DETALHADA]
- Mudança 1: [descrição]
- Mudança 2: [descrição]
- Breaking changes: [se houver]
- Data migration: [se necessário]

Affects:
- Tables: [lista de tabelas afetadas]
- Records: [estimativa de records afetados]
- Indexes: [índices criados/removidos]
- Constraints: [constraints modificadas]

Rollback notes:
- [considerações para rollback]
- [possível perda de dados]
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy import text

# revision identifiers, used by Alembic.
revision = '[REVISION_ID]'
down_revision = '[PREVIOUS_REVISION]'
branch_labels = None
depends_on = None

def upgrade() -> None:
    """
    Apply the database changes
    
    SEMPRE usar batch_alter_table para SQLite compatibility:
    - SQLite não suporta ALTER TABLE completo
    - batch_alter_table cria tabela temporária e copia dados
    """
    
    # ====================================
    # TIPO 1: CRIAR NOVA TABELA
    # ====================================
    
    # Exemplo: Criar tabela completa
    # op.create_table('[TABLE_NAME]',
    #     # Primary Key
    #     sa.Column('id', sa.Integer(), nullable=False, primary_key=True),
    #     
    #     # Identification fields
    #     sa.Column('name', sa.String(length=100), nullable=False),
    #     sa.Column('title', sa.String(length=100), nullable=False),
    #     
    #     # Data fields
    #     sa.Column('description', sa.Text(), nullable=True),
    #     sa.Column('type', sa.String(length=50), nullable=False),
    #     
    #     # Status fields
    #     sa.Column('is_active', sa.Boolean(), nullable=False, default=True),
    #     
    #     # Foreign keys
    #     sa.Column('parent_id', sa.Integer(), nullable=True),
    #     
    #     # Audit fields
    #     sa.Column('created_at', sa.DateTime(), nullable=False, default=sa.func.now()),
    #     sa.Column('updated_at', sa.DateTime(), nullable=False, default=sa.func.now()),
    #     
    #     # Constraints
    #     sa.ForeignKeyConstraint(['parent_id'], ['[PARENT_TABLE].id'], ondelete='CASCADE'),
    #     sa.UniqueConstraint('name'),
    #     sa.CheckConstraint("type IN ('type_a', 'type_b')", name='check_valid_type')
    # )
    
    # ====================================
    # TIPO 2: MODIFICAR TABELA EXISTENTE
    # ====================================
    
    # Usar batch_alter_table para SQLite compatibility
    with op.batch_alter_table('[TABLE_NAME]') as batch_op:
        
        # Adicionar colunas
        # batch_op.add_column(sa.Column('new_field', sa.String(length=50), nullable=True))
        # batch_op.add_column(sa.Column('new_flag', sa.Boolean(), nullable=False, default=False))
        
        # Remover colunas (CUIDADO: perda de dados)
        # batch_op.drop_column('old_field')
        
        # Modificar colunas
        # batch_op.alter_column('existing_field',
        #                      type_=sa.String(length=200),  # Novo tipo
        #                      nullable=False,               # Nullable
        #                      new_column_name='renamed_field')  # Novo nome
        
        # Adicionar constraints
        # batch_op.create_check_constraint(
        #     'check_constraint_name',
        #     'field_name IN (\'value1\', \'value2\')'
        # )
        
        # batch_op.create_unique_constraint(
        #     'uq_field_combination',
        #     ['field1', 'field2']
        # )
        
        # batch_op.create_foreign_key(
        #     'fk_table_field',
        #     'target_table',
        #     ['local_field'],
        #     ['target_field'],
        #     ondelete='CASCADE'
        # )
        
        # Adicionar índices
        # batch_op.create_index('idx_table_field', ['field_name'])
        # batch_op.create_index('idx_table_composite', ['field1', 'field2'])
    
    # ====================================
    # TIPO 3: MIGRAÇÃO DE DADOS
    # ====================================
    
    # Para mudanças que requerem transformação de dados
    # connection = op.get_bind()
    
    # Exemplo: Atualizar valores baseado em regras
    # connection.execute(text("""
    #     UPDATE [TABLE_NAME] 
    #     SET new_field = CASE 
    #         WHEN old_field = 'old_value1' THEN 'new_value1'
    #         WHEN old_field = 'old_value2' THEN 'new_value2'
    #         ELSE 'default_value'
    #     END
    #     WHERE old_field IS NOT NULL
    # """))
    
    # Exemplo: Populacão de dados iniciais
    # connection.execute(text("""
    #     INSERT INTO [TABLE_NAME] (name, title, type, is_active, created_at)
    #     VALUES 
    #         ('default_item1', 'Item Padrão 1', 'type_a', true, datetime('now')),
    #         ('default_item2', 'Item Padrão 2', 'type_b', true, datetime('now'))
    # """))
    
    # ====================================
    # TIPO 4: CRIAR ÍNDICES SEPARADAMENTE
    # ====================================
    
    # Índices podem ser criados fora do batch_alter_table
    # op.create_index('idx_[table]_[field]', '[table_name]', ['field_name'])
    # op.create_index('idx_[table]_composite', '[table_name]', ['field1', 'field2'])
    
    # Índices únicos
    # op.create_index('idx_[table]_[field]_unique', '[table_name]', ['field_name'], unique=True)
    
    pass  # Remover quando implementar

def downgrade() -> None:
    """
    Rollback the database changes
    
    IMPORTANTE:
    - Sempre implementar downgrade
    - Testar rollback antes de aplicar migration
    - Documentar possível perda de dados
    - Ordem inversa das operações do upgrade
    """
    
    # ====================================
    # ROLLBACK: REMOVER ÍNDICES PRIMEIRO
    # ====================================
    
    # Remover índices criados (ordem inversa)
    # op.drop_index('idx_[table]_composite', table_name='[table_name]')
    # op.drop_index('idx_[table]_[field]', table_name='[table_name]')
    
    # ====================================
    # ROLLBACK: MODIFICAÇÕES DE TABELA
    # ====================================
    
    # Usar batch_alter_table para SQLite
    with op.batch_alter_table('[TABLE_NAME]') as batch_op:
        
        # Remover constraints (ordem inversa)
        # batch_op.drop_constraint('fk_table_field', type_='foreignkey')
        # batch_op.drop_constraint('uq_field_combination', type_='unique')
        # batch_op.drop_constraint('check_constraint_name', type_='check')
        
        # Reverter modificações de colunas
        # batch_op.alter_column('renamed_field',
        #                      type_=sa.String(length=50),  # Tipo original
        #                      nullable=True,               # Nullable original
        #                      new_column_name='existing_field')  # Nome original
        
        # Adicionar colunas removidas (PERDA DE DADOS)
        # batch_op.add_column(sa.Column('old_field', sa.String(length=100), nullable=True))
        # # NOTA: Dados originais foram perdidos!
        
        # Remover colunas adicionadas
        # batch_op.drop_column('new_flag')
        # batch_op.drop_column('new_field')
    
    # ====================================
    # ROLLBACK: DATA MIGRATION
    # ====================================
    
    # Reverter transformações de dados (se possível)
    # connection = op.get_bind()
    
    # Exemplo: Reverter transformação
    # connection.execute(text("""
    #     UPDATE [TABLE_NAME] 
    #     SET old_field = CASE 
    #         WHEN new_field = 'new_value1' THEN 'old_value1'
    #         WHEN new_field = 'new_value2' THEN 'old_value2'
    #         ELSE 'unknown'
    #     END
    #     WHERE new_field IS NOT NULL
    # """))
    
    # Remover dados inseridos
    # connection.execute(text("""
    #     DELETE FROM [TABLE_NAME] 
    #     WHERE name IN ('default_item1', 'default_item2')
    # """))
    
    # ====================================
    # ROLLBACK: REMOVER TABELA
    # ====================================
    
    # Remover tabela criada (PERDA TOTAL DE DADOS)
    # op.drop_table('[TABLE_NAME]')
    # # AVISO: Todos os dados da tabela serão perdidos!
    
    pass  # Remover quando implementar

# ====================================
# HELPERS PARA MIGRATIONS COMUNS
# ====================================

def add_audit_fields(table_name: str):
    """Helper para adicionar campos de auditoria padrão"""
    with op.batch_alter_table(table_name) as batch_op:
        batch_op.add_column(sa.Column('created_at', sa.DateTime(), 
                                     nullable=False, default=sa.func.now()))
        batch_op.add_column(sa.Column('updated_at', sa.DateTime(), 
                                     nullable=False, default=sa.func.now()))

def add_status_fields(table_name: str):
    """Helper para adicionar campos de status padrão"""
    with op.batch_alter_table(table_name) as batch_op:
        batch_op.add_column(sa.Column('is_active', sa.Boolean(), 
                                     nullable=False, default=True))

def create_standard_indexes(table_name: str, fields: list):
    """Helper para criar índices padrão"""
    for field in fields:
        op.create_index(f'idx_{table_name}_{field}', table_name, [field])

# ====================================
# VALIDAÇÃO DE MIGRATION
# ====================================

def validate_migration():
    """
    Helper para validar migration após aplicação
    
    Uso em teste:
        alembic upgrade head
        python -c "from alembic_migration_file import validate_migration; validate_migration()"
        alembic downgrade -1
        python -c "from alembic_migration_file import validate_migration; validate_migration()"
    """
    from src.models.models import get_session
    
    session = get_session()
    
    try:
        # Validar que tabela existe e é acessível
        # result = session.execute(text("SELECT COUNT(*) FROM [TABLE_NAME]"))
        # count = result.scalar()
        # print(f"✅ Tabela [TABLE_NAME] acessível: {count} records")
        
        # Validar constraints
        # session.execute(text("INSERT INTO [TABLE_NAME] (name) VALUES ('test')"))
        # session.rollback()
        # print("✅ Constraints funcionando")
        
        # Validar índices (performance test)
        # import time
        # start = time.time()
        # session.execute(text("SELECT * FROM [TABLE_NAME] WHERE indexed_field = 'test'"))
        # duration = time.time() - start
        # print(f"✅ Índice funcionando: {duration:.4f}s")
        
        print("✅ Migration validation passed")
        
    except Exception as e:
        print(f"❌ Migration validation failed: {e}")
        raise
    finally:
        session.close()

# ====================================
# EXEMPLO DE MIGRATION COMPLETA
# ====================================

"""
Exemplo de migration real (comentado):

def upgrade() -> None:
    # Criar tabela de configurações
    op.create_table('system_configurations',
        sa.Column('id', sa.Integer(), nullable=False, primary_key=True),
        sa.Column('key', sa.String(length=100), nullable=False),
        sa.Column('value', sa.Text(), nullable=True),
        sa.Column('type', sa.String(length=20), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), nullable=False, default=sa.func.now()),
        sa.UniqueConstraint('key'),
        sa.CheckConstraint("type IN ('string', 'number', 'boolean', 'json')", name='check_config_type')
    )
    
    # Criar índices
    op.create_index('idx_system_configurations_key', 'system_configurations', ['key'])
    op.create_index('idx_system_configurations_type', 'system_configurations', ['type'])
    
    # Inserir configurações padrão
    connection = op.get_bind()
    connection.execute(text('''
        INSERT INTO system_configurations (key, value, type, description, created_at)
        VALUES 
            ('mqtt_broker_host', '192.168.1.10', 'string', 'MQTT broker hostname', datetime('now')),
            ('mqtt_broker_port', '1883', 'number', 'MQTT broker port', datetime('now')),
            ('system_name', 'AutoCore System', 'string', 'System display name', datetime('now'))
    '''))

def downgrade() -> None:
    op.drop_index('idx_system_configurations_type', table_name='system_configurations')
    op.drop_index('idx_system_configurations_key', table_name='system_configurations')
    op.drop_table('system_configurations')
"""