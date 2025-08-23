# 📊 Migration History - Detailed Analysis

Histórico detalhado de todas as migrations do AutoCore com análise de impacto e reversibilidade.

## 📋 Visão Geral

Registro completo de todas as mudanças estruturais no banco de dados, organizadas cronologicamente com detalhes técnicos e impacto no sistema.

### 🏷️ Conventions
- **Impact Level**: Low/Medium/High
- **Reversibility**: Full/Partial/Data Loss
- **Type**: Schema/Data/Constraint
- **SQLite Compatibility**: All migrations use batch_alter_table when needed

## 🔄 Migration Timeline

```
[Base] ──→ 6bae50cd6001 ──→ 1a1a631ee7ec ──→ 79697777cf1e ──→ 59042b38c022 ──→ cc3149ee98bd ──→ 8cb7e8483fa4 [HEAD]
2025-08    2025-08-08       2025-08-08       2025-08-08       2025-08-16       2025-08-17       2025-08-17
06:11      06:30            16:00            10:07            22:11            22:14
```

## 📝 Detailed Migration Records

### 🗑️ #1: Remove name and location fields (6bae50cd6001)
**Date**: 2025-08-08 06:11  
**Impact**: Medium  
**Reversibility**: Data Loss ⚠️  
**Type**: Schema Cleanup  

#### Changes
```python
# RelayChannel table modifications
with op.batch_alter_table('relay_channels') as batch_op:
    batch_op.drop_column('name')      # VARCHAR(100) 
    batch_op.drop_column('location')  # VARCHAR(100)
```

#### Rationale
- Campos redundantes com informações já disponíveis
- `name` substituído por logic no frontend
- `location` movido para configuração externa

#### Impact Analysis
- **Affected Records**: ~50 RelayChannels
- **Data Loss**: Nomes e localizações existentes
- **Breaking Changes**: Frontend precisa ajustar referências
- **Performance**: Redução de ~200 bytes por record

#### Rollback Considerations
```python
def downgrade() -> None:
    with op.batch_alter_table('relay_channels') as batch_op:
        batch_op.add_column(Column('name', String(100)))
        batch_op.add_column(Column('location', String(100)))
    # NOTA: Dados originais são PERDIDOS no rollback
```

---

### 🗑️ #2: Remove default and current state fields (1a1a631ee7ec)
**Date**: 2025-08-08 06:30  
**Impact**: High  
**Reversibility**: Data Loss ⚠️  
**Type**: Schema Refactor  

#### Changes
```python
# RelayChannel table modifications
with op.batch_alter_table('relay_channels') as batch_op:
    batch_op.drop_column('default_state')  # BOOLEAN
    batch_op.drop_column('current_state')  # BOOLEAN
```

#### Rationale
- Estados movidos para runtime (não persistidos)
- `default_state` controlado por lógica de aplicação
- `current_state` obtido via MQTT/status real

#### Impact Analysis
- **Affected Records**: ~50 RelayChannels
- **Data Loss**: Estados padrão e atuais
- **Breaking Changes**: APIs de status precisam ajustar
- **Performance**: Runtime state management mais eficiente

#### Migration Strategy
```python
# ANTES da migration, salvar dados críticos
backup_query = """
SELECT id, default_state, current_state 
FROM relay_channels 
WHERE default_state = 1 OR current_state = 1
"""
# Aplicar migration
# Reconfigurar defaults no código da aplicação
```

---

### ✅ #3: Add allow_in_macro field (79697777cf1e)
**Date**: 2025-08-08 16:00  
**Impact**: Low  
**Reversibility**: Full ✅  
**Type**: Feature Addition  

#### Changes
```python
# RelayChannel table modification
with op.batch_alter_table('relay_channels') as batch_op:
    batch_op.add_column(Column('allow_in_macro', Boolean, default=True))
```

#### Rationale
- Controle granular de quais relés podem ser usados em macros
- Segurança: previne automação de equipamentos críticos
- Default `true` para compatibilidade com dados existentes

#### Impact Analysis
- **Affected Records**: ~50 RelayChannels (valor default aplicado)
- **Data Loss**: None
- **Breaking Changes**: None (backward compatible)
- **Performance**: Filtering adicional em macro execution

#### Business Logic
```python
# Exemplo de uso
critical_relay.allow_in_macro = False  # Equipamento crítico
general_light.allow_in_macro = True    # Iluminação geral

# Query para macros
macro_relays = session.query(RelayChannel).filter_by(
    allow_in_macro=True,
    is_active=True
).all()
```

---

### 🎨 #4: Add icons table (59042b38c022)
**Date**: 2025-08-16 10:07  
**Impact**: High  
**Reversibility**: Full ✅  
**Type**: Feature Addition  

#### Changes
```sql
-- Nova tabela completa com 17+ campos
CREATE TABLE icons (
    id INTEGER PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    
    -- SVG Customizado
    svg_content TEXT,
    svg_viewbox VARCHAR(50),
    svg_fill_color VARCHAR(7),
    svg_stroke_color VARCHAR(7),
    
    -- Mapeamentos para Bibliotecas
    lucide_name VARCHAR(50),
    material_name VARCHAR(50),
    fontawesome_name VARCHAR(50),
    lvgl_symbol VARCHAR(50),
    
    -- Fallbacks
    unicode_char VARCHAR(10),
    emoji VARCHAR(10),
    fallback_icon_id INTEGER REFERENCES icons(id) ON DELETE SET NULL,
    
    -- Metadados
    description TEXT,
    tags TEXT,  -- JSON array
    is_custom BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_icons_name ON icons(name);
CREATE INDEX idx_icons_category ON icons(category);
CREATE INDEX idx_icons_active ON icons(is_active);
```

#### Rationale
- Sistema unificado de ícones para todas as plataformas
- Suporte a SVG customizado + bibliotecas padrão
- Fallback system para compatibilidade
- Self-reference para ícones alternativos

#### Impact Analysis
- **New Records**: 100+ ícones esperados no seed
- **Data Dependencies**: Screen, ScreenItem, RelayChannel references
- **Storage**: ~100KB para ícones base + SVGs
- **Performance**: Lookup table para icons por name/category

#### Integration Points
```python
# Uso em outros models
screen_item.icon = "water-pump"          # Referência por nome
relay_channel.icon = "electric-switch"   # Ícone do relé

# Query de resolução
icon = session.query(Icon).filter_by(
    name="water-pump", 
    is_active=True
).first()

# Fallback logic
if icon.lucide_name:
    return f"lucide:{icon.lucide_name}"
elif icon.material_name:
    return f"material:{icon.material_name}"
elif icon.emoji:
    return icon.emoji
```

---

### 🔧 #5: Standardize screen items types (cc3149ee98bd)
**Date**: 2025-08-17 22:11  
**Impact**: Medium  
**Reversibility**: Full ✅  
**Type**: Data Migration  

#### Changes
```python
# Data transformation - lowercase to UPPERCASE
connection = op.get_bind()

# item_type standardization
connection.execute(text("""
    UPDATE screen_items 
    SET item_type = CASE 
        WHEN item_type = 'display' THEN 'DISPLAY'
        WHEN item_type = 'button' THEN 'BUTTON'
        WHEN item_type = 'switch' THEN 'SWITCH'
        WHEN item_type = 'gauge' THEN 'GAUGE'
        ELSE item_type
    END
"""))

# action_type standardization  
connection.execute(text("""
    UPDATE screen_items 
    SET action_type = CASE 
        WHEN action_type = 'relay_control' THEN 'RELAY_CONTROL'
        WHEN action_type = 'command' THEN 'COMMAND'
        WHEN action_type = 'macro' THEN 'MACRO'
        WHEN action_type = 'navigation' THEN 'NAVIGATION'
        WHEN action_type = 'preset' THEN 'PRESET'
        ELSE action_type
    END
    WHERE action_type IS NOT NULL
"""))
```

#### Rationale
- Consistência na nomenclatura (UPPERCASE constants)
- Facilita validação e comparações
- Alinhamento com coding standards

#### Impact Analysis
- **Affected Records**: ~200 ScreenItems
- **Data Transformation**: lowercase → UPPERCASE
- **Breaking Changes**: Frontend constants precisam atualizar
- **Performance**: String comparisons mais consistentes

#### Validation
```python
# ANTES
item_type in ['display', 'button', 'switch', 'gauge']

# DEPOIS  
item_type in ['DISPLAY', 'BUTTON', 'SWITCH', 'GAUGE']
```

---

### 🛡️ #6: Add check constraints (8cb7e8483fa4)
**Date**: 2025-08-17 22:14  
**Impact**: High  
**Reversibility**: Full ✅  
**Type**: Data Validation  

#### Changes
```python
# Check constraints para integridade
with op.batch_alter_table('screen_items') as batch_op:
    # Consistência item_type × action_type
    batch_op.create_check_constraint(
        'check_item_action_consistency',
        "(item_type IN ('DISPLAY', 'GAUGE') AND action_type IS NULL) OR "
        "(item_type IN ('BUTTON', 'SWITCH') AND action_type IS NOT NULL)"
    )
    
    # Campos obrigatórios para RELAY_CONTROL
    batch_op.create_check_constraint(
        'check_relay_control_requirements',
        "action_type != 'RELAY_CONTROL' OR "
        "(action_type = 'RELAY_CONTROL' AND relay_board_id IS NOT NULL AND relay_channel_id IS NOT NULL)"
    )
    
    # Dados obrigatórios para DISPLAY/GAUGE
    batch_op.create_check_constraint(
        'check_display_data_requirements',
        "item_type NOT IN ('DISPLAY', 'GAUGE') OR "
        "(item_type IN ('DISPLAY', 'GAUGE') AND data_source IS NOT NULL AND data_path IS NOT NULL)"
    )
```

#### Rationale
- Data integrity no database level
- Previne estados inconsistentes
- Valida regras de negócio automaticamente

#### Impact Analysis
- **Validation Rules**: 3 constraints ativas
- **Data Quality**: 100% compliance enforced
- **Performance**: Minimal overhead na inserção
- **Development**: Catch errors earlier

#### Business Rules Enforced
```python
# Rule 1: DISPLAY/GAUGE não têm ação
assert display_item.action_type is None

# Rule 2: RELAY_CONTROL precisa de IDs  
assert relay_button.relay_board_id is not None
assert relay_button.relay_channel_id is not None

# Rule 3: DISPLAY/GAUGE precisam de dados
assert temp_display.data_source == 'mqtt'
assert temp_display.data_path == 'sensors/temp'
```

## 📊 Migration Statistics

### Database Size Evolution
| Migration | Tables | Columns | Indexes | Constraints | Size |
|-----------|--------|---------|---------|-------------|------|
| Base | 11 | ~80 | ~15 | ~5 | ~1MB |
| After #1-2 | 11 | ~76 | ~15 | ~5 | ~0.9MB |
| After #3 | 11 | ~77 | ~15 | ~5 | ~0.9MB |
| After #4 | 12 | ~94 | ~18 | ~6 | ~1.2MB |
| After #5 | 12 | ~94 | ~18 | ~6 | ~1.2MB |
| Current #6 | 12 | ~94 | ~18 | ~9 | ~1.2MB |

### Change Distribution
```
Schema Changes:  67% (4/6 migrations)
Data Changes:    17% (1/6 migrations) 
Constraints:     16% (1/6 migrations)

Additions:       50% (3 migrations)
Removals:        33% (2 migrations)
Modifications:   17% (1 migration)
```

### Risk Assessment
| Risk Level | Count | Migrations | Mitigation |
|------------|-------|------------|------------|
| Low | 2 | #3, #6 | Automated rollback |
| Medium | 2 | #1, #5 | Backup + testing |
| High | 2 | #2, #4 | Full backup + staged deploy |

## 🔍 Lessons Learned

### Best Practices Developed
- **Backup First**: Automatic backup before any migration
- **Batch Operations**: Always use batch_alter_table for SQLite
- **Data Validation**: Add constraints after data cleanup
- **Reversibility**: Document data loss scenarios
- **Testing**: Test both upgrade and downgrade paths

### Common Patterns
```python
# Pattern 1: Safe Column Addition
batch_op.add_column(Column('new_field', String(50), nullable=True))
# Set defaults via UPDATE
# Make non-nullable if needed

# Pattern 2: Data Transformation
connection = op.get_bind()
connection.execute(text("UPDATE table SET field = NEW_VALUE WHERE condition"))

# Pattern 3: Constraint Addition
with op.batch_alter_table('table') as batch_op:
    batch_op.create_check_constraint('name', 'condition')
```

### Rollback Strategies
- **Full Rollback**: Schema changes são reversíveis
- **Data Loss Warning**: Migrations #1, #2 perdem dados
- **Staged Rollback**: Test em staging primeiro
- **Emergency**: Keep SQL backup para recovery

## 🎯 Future Migration Planning

### v2.2.0 (Next Sprint)
- PostgreSQL preparation migrations
- Connection pooling tables
- Audit logging tables

### v3.0.0 (Major Release)
- PostgreSQL migration scripts
- UUID primary keys
- JSONB configuration fields
- Partitioning tables

---

**Next Review**: After each sprint  
**Documentation**: Update after every migration  
**Backup Policy**: 3 generations + pre-migration backup