# Guia de Migrations - AutoCore Database

Este guia detalha como usar o sistema de migrations do AutoCore baseado em Alembic para gerenciar mudanças no schema do banco de dados.

## Visão Geral

O AutoCore utiliza **Alembic** para versionamento e aplicação de mudanças no banco de dados, garantindo:
- Evolução controlada do schema
- Rollback seguro de mudanças
- Sincronização entre ambientes
- Histórico completo de alterações

## Estrutura de Arquivos

```
database/
├── alembic.ini                 # Configuração do Alembic
├── alembic/
│   ├── env.py                 # Configuração de ambiente
│   ├── script.py.mako         # Template para migrations
│   └── versions/              # Migrations aplicadas
│       ├── 20250817_2211_*.py # Migration: Enums e constraints
│       └── 20250817_2214_*.py # Migration: Check constraints
├── src/
│   └── migrations/
│       ├── auto_migrate.py    # Sistema automático
│       └── alembic_setup.py   # Configuração inicial
└── autocore.db               # Banco SQLite
```

## Comandos Básicos

### 1. Status das Migrations

```bash
# Ver revisão atual
python3 -m alembic current

# Ver histórico completo
python3 -m alembic history

# Ver migrations pendentes
python3 -m alembic history --indicate-current
```

### 2. Gerar Migrations

#### Migration Automática (Recomendado)
```bash
# Gera migration baseada nas mudanças dos models
python3 -m alembic revision --autogenerate -m "Descrição da mudança"
```

#### Migration Manual
```bash
# Cria migration vazia para customização
python3 -m alembic revision -m "Descrição da mudança"
```

### 3. Aplicar Migrations

```bash
# Aplica todas as migrations pendentes
python3 -m alembic upgrade head

# Aplica até uma revisão específica
python3 -m alembic upgrade cc3149ee98bd

# Aplica próximas N migrations
python3 -m alembic upgrade +2
```

### 4. Rollback de Migrations

```bash
# Volta 1 migration
python3 -m alembic downgrade -1

# Volta até revisão específica
python3 -m alembic downgrade cc3149ee98bd

# Volta N migrations
python3 -m alembic downgrade -2
```

## Sistema Auto-Migration

O AutoCore inclui um sistema automatizado via `src/migrations/auto_migrate.py`:

### Usar o Auto-Migration

```bash
# Gerar migration automática
python src/migrations/auto_migrate.py generate -m "Nova funcionalidade"

# Aplicar migrations pendentes
python src/migrations/auto_migrate.py apply

# Processo completo (gerar + aplicar)
python src/migrations/auto_migrate.py auto -m "Mudança importante"

# Sincronizar banco (apenas desenvolvimento)
python src/migrations/auto_migrate.py sync
```

### Exemplo de Uso Completo

```bash
# 1. Modificar models em src/models/models.py
# 2. Gerar migration
python src/migrations/auto_migrate.py generate -m "Adicionar campo novo_campo"

# 3. Revisar migration gerada em alembic/versions/
# 4. Aplicar migration
python src/migrations/auto_migrate.py apply

# 5. Verificar se foi aplicada
python3 -m alembic current
```

## Boas Práticas

### 1. Convenções de Nomenclatura

```bash
# ✅ Bom
python3 -m alembic revision --autogenerate -m "Add user authentication fields"
python3 -m alembic revision --autogenerate -m "Remove deprecated status column"
python3 -m alembic revision --autogenerate -m "Update relay_channels with enums"

# ❌ Ruim
python3 -m alembic revision --autogenerate -m "changes"
python3 -m alembic revision --autogenerate -m "fix"
```

### 2. Estrutura de Migration

```python
"""Descrição clara da mudança

Revision ID: abc123def456
Revises: xyz789uvw012
Create Date: 2025-08-17 22:11:06.504426
"""
from alembic import op
import sqlalchemy as sa

def upgrade() -> None:
    # Primeiro: preparar dados (se necessário)
    op.execute("UPDATE tabela SET campo = 'novo_valor' WHERE campo IS NULL")
    
    # Segundo: aplicar mudanças de schema
    with op.batch_alter_table('tabela') as batch_op:
        batch_op.add_column(sa.Column('novo_campo', sa.String(50)))
    
    # Terceiro: aplicar constraints/índices
    op.create_index('idx_tabela_novo_campo', 'tabela', ['novo_campo'])

def downgrade() -> None:
    # Reverter na ordem inversa
    op.drop_index('idx_tabela_novo_campo', 'tabela')
    
    with op.batch_alter_table('tabela') as batch_op:
        batch_op.drop_column('novo_campo')
```

### 3. Mudanças Complexas

Para mudanças que envolvem transformação de dados:

```python
def upgrade() -> None:
    # 1. Adicionar coluna temporária
    op.add_column('devices', sa.Column('type_temp', sa.String(50)))
    
    # 2. Migrar dados
    op.execute("""
        UPDATE devices 
        SET type_temp = CASE 
            WHEN type = 'esp32_relay' THEN 'ESP32_RELAY'
            WHEN type = 'esp32_display' THEN 'ESP32_DISPLAY'
            ELSE 'ESP32_RELAY'
        END
    """)
    
    # 3. Remover coluna antiga e renomear
    with op.batch_alter_table('devices') as batch_op:
        batch_op.drop_column('type')
        batch_op.alter_column('type_temp', new_column_name='type')

def downgrade() -> None:
    # Processo reverso
    op.add_column('devices', sa.Column('type_old', sa.String(50)))
    
    op.execute("""
        UPDATE devices 
        SET type_old = CASE 
            WHEN type = 'ESP32_RELAY' THEN 'esp32_relay'
            WHEN type = 'ESP32_DISPLAY' THEN 'esp32_display'
            ELSE 'esp32_relay'
        END
    """)
    
    with op.batch_alter_table('devices') as batch_op:
        batch_op.drop_column('type')
        batch_op.alter_column('type_old', new_column_name='type')
```

## Troubleshooting

### Problemas Comuns

#### 1. Migration Falhando por Dados Inconsistentes

```bash
# Erro: CHECK constraint failed: check_item_action_consistency
```

**Solução**: Corrigir dados antes de aplicar constraints:

```sql
-- Identificar dados problemáticos
SELECT id, item_type, action_type FROM screen_items 
WHERE (item_type IN ('display', 'gauge') AND action_type IS NOT NULL)
   OR (item_type IN ('button', 'switch') AND action_type IS NULL);

-- Corrigir dados
UPDATE screen_items SET action_type = NULL WHERE item_type IN ('display', 'gauge');
UPDATE screen_items SET action_type = 'relay_control' 
WHERE item_type IN ('button', 'switch') AND action_type IS NULL;
```

#### 2. SQLite e ALTER TABLE

SQLite tem limitações com ALTER TABLE. Use **batch operations**:

```python
# ❌ Não funciona no SQLite
op.alter_column('tabela', 'coluna', type_=sa.Enum(...))

# ✅ Funciona com batch mode
with op.batch_alter_table('tabela') as batch_op:
    batch_op.alter_column('coluna', type_=sa.Enum(...))
```

#### 3. Migration Incompleta

```bash
# Se migration falhar no meio, pode deixar estado inconsistente
# Fazer rollback e corrigir:
python3 -m alembic downgrade -1

# Limpar tabelas temporárias se necessário
sqlite3 autocore.db "DROP TABLE IF EXISTS _alembic_tmp_*;"
```

### 4. Múltiplos Ambientes

#### Desenvolvimento
```bash
# Sincronização rápida (apenas dev)
python src/migrations/auto_migrate.py sync
```

#### Produção
```bash
# SEMPRE usar migrations em produção
python3 -m alembic upgrade head
```

## Workflow Recomendado

### Para Desenvolvedores

1. **Modificar Models**
   ```python
   # src/models/models.py
   class NovaTabela(Base):
       # ...
   ```

2. **Gerar Migration**
   ```bash
   python src/migrations/auto_migrate.py generate -m "Adicionar nova tabela"
   ```

3. **Revisar Migration**
   - Verificar código gerado em `alembic/versions/`
   - Testar upgrade e downgrade
   - Ajustar se necessário

4. **Aplicar Localmente**
   ```bash
   python src/migrations/auto_migrate.py apply
   ```

5. **Testar Aplicação**
   - Verificar se tudo funciona
   - Testar rollback se necessário

6. **Commit e Deploy**
   ```bash
   git add alembic/versions/nova_migration.py
   git commit -m "feat: adicionar nova tabela"
   ```

### Para Deploy em Produção

1. **Backup do Banco**
   ```bash
   cp autocore.db backups/autocore_backup_$(date +%Y%m%d_%H%M%S)_pre_deploy.db
   ```

2. **Aplicar Migrations**
   ```bash
   python3 -m alembic upgrade head
   ```

3. **Verificar Aplicação**
   ```bash
   python3 -m alembic current
   python3 -m alembic history --indicate-current
   ```

## Exemplos Práticos

### Exemplo 1: Adicionar Nova Coluna

```python
def upgrade() -> None:
    with op.batch_alter_table('devices') as batch_op:
        batch_op.add_column(sa.Column('description', sa.Text, nullable=True))

def downgrade() -> None:
    with op.batch_alter_table('devices') as batch_op:
        batch_op.drop_column('description')
```

### Exemplo 2: Criar Nova Tabela

```python
def upgrade() -> None:
    op.create_table(
        'settings',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('key', sa.String(50), nullable=False, unique=True),
        sa.Column('value', sa.Text, nullable=True),
        sa.Column('created_at', sa.DateTime, default=sa.func.now())
    )

def downgrade() -> None:
    op.drop_table('settings')
```

### Exemplo 3: Mudança de Tipo com Enum

```python
def upgrade() -> None:
    # Criar enum
    device_type_enum = sa.Enum('ESP32_RELAY', 'ESP32_DISPLAY', name='devicetype')
    device_type_enum.create(op.get_bind())
    
    # Atualizar dados
    op.execute("UPDATE devices SET type = 'ESP32_RELAY' WHERE type = 'esp32_relay'")
    op.execute("UPDATE devices SET type = 'ESP32_DISPLAY' WHERE type = 'esp32_display'")
    
    # Alterar tipo da coluna
    with op.batch_alter_table('devices') as batch_op:
        batch_op.alter_column('type', type_=device_type_enum)

def downgrade() -> None:
    # Reverter para strings
    with op.batch_alter_table('devices') as batch_op:
        batch_op.alter_column('type', type_=sa.String(50))
    
    # Atualizar dados de volta
    op.execute("UPDATE devices SET type = 'esp32_relay' WHERE type = 'ESP32_RELAY'")
    op.execute("UPDATE devices SET type = 'esp32_display' WHERE type = 'ESP32_DISPLAY'")
    
    # Remover enum
    sa.Enum(name='devicetype').drop(op.get_bind())
```

## Recursos Adicionais

- [Documentação oficial do Alembic](https://alembic.sqlalchemy.org/)
- [SQLAlchemy Core Tutorial](https://docs.sqlalchemy.org/en/14/core/tutorial.html)
- [AutoCore Models Reference](../architecture/DATABASE.md)

---

**Autor**: Sistema AutoCore  
**Última atualização**: 17 de Agosto, 2025  
**Versão**: 2.0.0