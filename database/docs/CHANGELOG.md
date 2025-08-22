# 📋 Database Changelog

Histórico de mudanças estruturais no banco de dados AutoCore.

## [2.1.0] - 2025-08-17

### ✅ Added
- **Icons Management**: Nova tabela `icons` para gestão unificada de ícones
  - Suporte a SVG customizado
  - Mapeamentos para bibliotecas (Lucide, Material, FontAwesome, LVGL)
  - Sistema de fallbacks e alternativas
  - Migration: `20250816_1007_add_icons_table_for_icon_management`

### 🔧 Changed
- **Screen Items Types**: Padronização de tipos para maiúsculas
  - `item_type`: display → DISPLAY, button → BUTTON, etc.
  - `action_type`: relay_control → RELAY_CONTROL, etc.
  - Migration: `20250817_2211_standardize_screen_items_types`

- **Check Constraints**: Adicionadas validações de consistência
  - Consistência entre `item_type` e `action_type`
  - Validação de campos obrigatórios para `relay_control`
  - Validação de dados para `display` e `gauge`
  - Migration: `20250817_2214_add_check_constraints_to_screen_items`

### 🗑️ Removed
- **RelayChannel**: Campos desnecessários removidos
  - `name` e `location` (redundantes)
  - `default_state` e `current_state` (movidos para runtime)
  - Migrations: `20250808_0611_remove_name_and_location_fields`
  - Migration: `20250808_0630_remove_default_state_and_current_state`

## [2.0.0] - 2025-08-08

### ✅ Added
- **Macro Permissions**: Campo `allow_in_macro` para RelayChannel
  - Controla quais relés podem ser usados em macros
  - Default: `true` para compatibilidade
  - Migration: `20250808_1600_add_allow_in_macro_field_to_relay`

### 🔧 Changed
- **Model Structure**: Refatoração completa dos models
  - Padronização nomenclatura (snake_case)
  - Remoção de enums para strings validadas
  - Melhoria de relationships e constraints
  - Otimização de índices

## [1.5.0] - 2025-07-XX

### ✅ Added
- **Base Models**: Estrutura inicial SQLAlchemy
  - Device, RelayBoard, RelayChannel
  - Screen, ScreenItem
  - User, EventLog
  - TelemetryData, CANSignal
  - Theme, Macro

### 🏗️ Infrastructure
- **Alembic Setup**: Configuração migrations
- **SQLite Database**: Implementação inicial
- **Repository Pattern**: Estrutura de acesso dados

## 📋 Convenções de Versionamento

### Números de Versão
- **Major** (X.0.0): Mudanças breaking, redesign schema
- **Minor** (x.Y.0): Novas features, tabelas, campos
- **Patch** (x.y.Z): Bugfixes, otimizações, índices

### Tags de Mudanças
- ✅ **Added**: Novas features, tabelas, campos
- 🔧 **Changed**: Modificações em estruturas existentes
- 🗑️ **Removed**: Remoção de campos, tabelas
- 🔒 **Security**: Mudanças relacionadas a segurança
- 🐛 **Fixed**: Correções de bugs, constraints
- 📊 **Performance**: Otimizações, índices

## 🔄 Migration Status

### Aplicadas ✅
- [x] `6bae50cd6001` - Remove name/location fields
- [x] `1a1a631ee7ec` - Remove default/current state
- [x] `79697777cf1e` - Add allow_in_macro field
- [x] `59042b38c022` - Add icons table
- [x] `cc3149ee98bd` - Standardize screen items types
- [x] `8cb7e8483fa4` - Add check constraints

### Planejadas 📋
- [ ] PostgreSQL migration scripts
- [ ] Performance índices adicionais
- [ ] Audit logging tables
- [ ] Partitioning strategy (PostgreSQL)

## 📊 Schema Evolution

### V1.0 → V2.0
```sql
-- Principais mudanças estruturais
ALTER TABLE relay_channels DROP COLUMN name;
ALTER TABLE relay_channels DROP COLUMN location;
ALTER TABLE relay_channels ADD COLUMN allow_in_macro BOOLEAN DEFAULT true;

-- Nova tabela icons
CREATE TABLE icons (
    id INTEGER PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    -- ... campos detalhados
);

-- Constraints adicionadas
ALTER TABLE screen_items ADD CONSTRAINT check_item_action_consistency ...;
```

### V2.0 → V3.0 (Planejado)
```sql
-- Migração PostgreSQL
-- UUID como primary keys
-- JSONB para configurações
-- Partitioning para telemetry
-- Full-text search para logs
```

## 🎯 Breaking Changes

### v2.1.0
- **Screen Items**: Tipos padronizados para UPPERCASE
  - Atualizar código que verifica `item_type`/`action_type`
  - Usar valores: DISPLAY, BUTTON, SWITCH, GAUGE
  - Usar valores: RELAY_CONTROL, COMMAND, MACRO, etc.

### v2.0.0
- **Relay Channels**: Campos removidos
  - `name` → usar `description` ou logic no frontend
  - `location` → usar configuração externa
  - `default_state`/`current_state` → mover para runtime

## 🔍 Migration Scripts

### Reverter para versão anterior
```bash
# Última migration
alembic downgrade -1

# Versão específica
alembic downgrade 79697777cf1e

# Base (rebuild completo)
alembic downgrade base
```

### Aplicar atualizações
```bash
# Próxima migration
alembic upgrade +1

# Última versão
alembic upgrade head

# Versão específica
alembic upgrade 8cb7e8483fa4
```

## 📞 Referências

- [Alembic Workflow](./migrations/alembic-workflow.md)
- [Migration Guide](./migrations/migration-guide.md)
- [Rollback Procedures](./migrations/rollback-procedures.md)
- [SQLite to PostgreSQL](./migrations/sqlite-to-postgres.md)

---

**Próxima revisão**: v2.2.0 (PostgreSQL migration)  
**Responsável**: Database Team  
**Frequência**: A cada sprint (2 semanas)