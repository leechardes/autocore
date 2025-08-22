# 🔄 Alembic Migrations Documentation

Documentação completa do sistema de migrations do AutoCore usando Alembic para controle de versão do schema.

## 📋 Visão Geral

O AutoCore utiliza Alembic como ferramenta oficial para database migrations, garantindo evolução controlada e reversível do schema. **Nunca fazemos mudanças diretas no database** - sempre através de migrations.

### 🎯 Princípios
- **Versionamento**: Cada mudança é uma migration numerada
- **Reversibilidade**: Toda migration tem rollback (downgrade)
- **Automação**: Auto-generate a partir dos SQLAlchemy models
- **Rastreabilidade**: Histórico completo de mudanças

## 📊 Migration Status Atual

### ✅ Aplicadas (6 migrations)
| Revision | Date | Description |
|----------|------|-------------|
| `8cb7e8483fa4` | 2025-08-17 22:14 | Add check constraints to screen_items |
| `cc3149ee98bd` | 2025-08-17 22:11 | Standardize screen_items types |
| `59042b38c022` | 2025-08-16 10:07 | Add icons table for icon management |
| `79697777cf1e` | 2025-08-08 16:00 | Add allow_in_macro field to relay |
| `1a1a631ee7ec` | 2025-08-08 06:30 | Remove default/current state |
| `6bae50cd6001` | 2025-08-08 06:11 | Remove name/location fields |

### 🎯 Status
- **Head Revision**: `8cb7e8483fa4`
- **Database**: Sincronizada ✅
- **Pending**: 0 migrations
- **Failed**: 0 migrations

## 🔧 Alembic Configuration

### 📁 Estrutura
```
database/
├── alembic.ini              # Configuração principal
├── alembic/
│   ├── env.py              # Ambiente Alembic
│   ├── script.py.mako      # Template migrations
│   └── versions/           # Migration files
│       ├── 20250808_*.py
│       └── 20250817_*.py
```

### ⚙️ Configuração (alembic.ini)
```ini
[alembic]
script_location = alembic
file_template = %%(year)d%%(month).2d%%(day).2d_%%(hour).2d%%(minute).2d_%%(rev)s_%%(slug)s
sqlalchemy.url = sqlite:///autocore.db
prepend_sys_path = .
```

## 🚀 Comandos Essenciais

### Migration Generation
```bash
# Auto-gerar migration a partir dos models
alembic revision --autogenerate -m "descrição da mudança"

# Migration manual (quando auto-generate não detecta)
alembic revision -m "manual change description"
```

### Migration Application
```bash
# Aplicar todas as migrations pendentes
alembic upgrade head

# Aplicar próxima migration
alembic upgrade +1

# Aplicar até revisão específica
alembic upgrade 8cb7e8483fa4
```

### Migration Rollback
```bash
# Rollback última migration
alembic downgrade -1

# Rollback para revisão específica
alembic downgrade 79697777cf1e

# Rollback completo (CUIDADO!)
alembic downgrade base
```

### Status & History
```bash
# Ver status atual
alembic current

# Ver histórico de migrations
alembic history

# Ver migration específica
alembic show 8cb7e8483fa4
```

## 📚 Tipos de Migrations

### 1. Schema Changes (Auto-generate)
- Adicionar/remover tabelas
- Adicionar/remover colunas  
- Modificar tipos de dados
- Adicionar/remover índices

### 2. Data Changes (Manual)
- População de dados iniciais
- Transformação de dados existentes
- Migração de formato de dados

### 3. Constraints (Mixed)
- Check constraints
- Unique constraints  
- Foreign key constraints
- Index creation

## 📋 Migration Guidelines

### ✅ Boas Práticas
- **Backup primeiro**: Sempre fazer backup antes de migrations
- **Teste local**: Testar migration e rollback em ambiente local
- **Descrições claras**: Nomes descritivos para as migrations
- **Atomic operations**: Uma migration = um conceito/mudança
- **Review rollbacks**: Sempre implementar e testar downgrade
- **SQLite batch mode**: Usar batch_alter_table para SQLite

### ❌ Evitar
- **SQL direto**: Nunca executar comandos SQL manuais
- **Migrations quebradas**: Migrations que falham no meio
- **Downgrade sem dados**: Rollbacks que perdem dados
- **Schema drift**: Diferenças entre models e database

### 🔄 SQLite Considerations
```python
# SQLite não suporta ALTER TABLE completo
# Usar batch_alter_table para mudanças
with op.batch_alter_table('table_name') as batch_op:
    batch_op.add_column(Column('new_field', String(50)))
    batch_op.create_check_constraint('constraint_name', 'condition')
```

## 📊 Migration History Analysis

### Version Evolution
```
v1.0 (Base) → v1.5 → v2.0 → v2.1 (Current)
     │         │      │      │
     │         │      │      ├─ Check constraints
     │         │      │      └─ Icons table
     │         │      │
     │         │      ├─ allow_in_macro field
     │         │      └─ Field removals
     │         │
     │         └─ Initial structure
     │
     └─ Empty database
```

### Change Categories
| Category | Count | Examples |
|----------|-------|----------|
| **Additions** | 3 | Icons table, allow_in_macro field, check constraints |
| **Removals** | 2 | name/location fields, default/current state |
| **Modifications** | 1 | Screen item types standardization |
| **Constraints** | 1 | Check constraints for data integrity |

### File Size Evolution
```
Migration Files: ~50KB total
Average Size: ~8KB per migration
Largest: 59042b38c022 (Icons table) ~15KB
Smallest: 79697777cf1e (Add field) ~3KB
```

## 🔍 Migration Details

### [Add Icons Table](./migration-history.md#icons-table) (59042b38c022)
```python
# Maior migration - nova tabela completa
create_table('icons',
    Column('id', Integer, primary_key=True),
    Column('name', String(50), unique=True, nullable=False),
    # ... 15+ campos para gestão unificada de ícones
)
```

### [Check Constraints](./migration-history.md#check-constraints) (8cb7e8483fa4)  
```python
# Validações de integridade de dados
batch_op.create_check_constraint(
    'check_item_action_consistency',
    "(item_type IN ('DISPLAY', 'GAUGE') AND action_type IS NULL) OR "
    "(item_type IN ('BUTTON', 'SWITCH') AND action_type IS NOT NULL)"
)
```

### [Field Removals](./migration-history.md#field-cleanup) (6bae50cd6001, 1a1a631ee7ec)
```python
# Limpeza de campos desnecessários
batch_op.drop_column('name')        # RelayChannel
batch_op.drop_column('location')    # RelayChannel  
batch_op.drop_column('default_state')  # RelayChannel
batch_op.drop_column('current_state')  # RelayChannel
```

## 🎯 Migration Patterns

### Standard Migration Structure
```python
"""Migration description

Revision ID: abc123def456
Revises: previous_revision
Create Date: 2025-08-XX XX:XX:XX.XXXXXX
"""
from alembic import op
import sqlalchemy as sa

revision = 'abc123def456'
down_revision = 'previous_revision'

def upgrade() -> None:
    """Apply changes"""
    # Forward changes here
    pass

def downgrade() -> None:
    """Rollback changes"""
    # Reverse changes here
    pass
```

### Batch Operations (SQLite)
```python
def upgrade() -> None:
    with op.batch_alter_table('table_name') as batch_op:
        batch_op.add_column(Column('new_field', String(50)))
        batch_op.create_index('idx_new_field', ['new_field'])
        batch_op.create_check_constraint('check_name', 'condition')

def downgrade() -> None:
    with op.batch_alter_table('table_name') as batch_op:
        batch_op.drop_constraint('check_name', type_='check')
        batch_op.drop_index('idx_new_field')
        batch_op.drop_column('new_field')
```

### Data Migration Pattern
```python
def upgrade() -> None:
    # Schema change first
    op.add_column('table_name', Column('new_field', String(50)))
    
    # Data transformation
    connection = op.get_bind()
    connection.execute(text("""
        UPDATE table_name 
        SET new_field = CASE 
            WHEN old_field = 'value1' THEN 'new_value1'
            ELSE 'default_value'
        END
    """))
    
    # Constraints after data
    with op.batch_alter_table('table_name') as batch_op:
        batch_op.alter_column('new_field', nullable=False)
```

## 🔧 Troubleshooting

### Common Issues
- **Migration conflicts**: Merge conflicts em branches
- **Failed upgrades**: Migration para no meio
- **Data loss**: Downgrade sem preservar dados
- **SQLite limitations**: ALTER TABLE restrictions

### Recovery Procedures
```bash
# Se migration falhar, verificar estado
alembic current
alembic history

# Marcar migration como aplicada (se necessário)
alembic stamp head

# Rollback e tentar novamente
alembic downgrade -1
alembic upgrade head
```

## 🔗 Navigation

### Migration Docs
- [Migration Guide](./migration-guide.md) - Step-by-step workflows
- [Migration History](./migration-history.md) - Detailed change log
- [Rollback Procedures](./rollback-procedures.md) - Safe rollback practices
- [SQLite to PostgreSQL](./sqlite-to-postgres.md) - Migration strategy

### Related Docs
- [Alembic Workflow](../development/alembic-workflow.md) - Development process
- [Database Testing](../development/testing-database.md) - Migration testing
- [Troubleshooting](../troubleshooting/migration-issues.md) - Problem solving

---

**Próxima migration**: v2.2.0 (PostgreSQL preparation)  
**Review**: Após cada sprint (2 semanas)  
**Backup strategy**: Automático antes de cada migration