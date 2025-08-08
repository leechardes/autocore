# 📋 Changelog - AutoCore Database

## [2.0.0] - 2025-08-07

### 🎉 Major Release - SQLAlchemy ORM Migration

#### ✨ Added
- **SQLAlchemy ORM** - Completa migração para ORM
- **Repository Pattern com ORM** - Todos os repositories agora usam SQLAlchemy
- **Seeds ORM** - Seeds reescritos usando models ao invés de SQL
- **Type Safety** - Validação automática de tipos via SQLAlchemy
- **Portabilidade** - Fácil migração para outros bancos (PostgreSQL, MySQL, etc)

#### 🔄 Changed
- `shared/repositories.py` - Agora usa SQLAlchemy ORM (anteriormente SQL raw)
- `seeds/seed_development.py` - Usa models ORM ao invés de SQL
- `src/cli/init_database.py` - Inicialização via ORM
- `test_repositories.py` - Testes atualizados para ORM

#### 🗑️ Removed
- **Arquivos SQL obsoletos**:
  - `migrations/001_initial_schema.sql`
  - `seeds/01_default_devices.sql`
  - `seeds/02_development_seeds.sql`
- **Scripts antigos**:
  - Versões antigas dos repositories (SQL raw)
  - Scripts de conexão sem ORM
- **Pasta obsoleta**:
  - `database/migrations/` - Removida (agora usa Alembic)

#### 📦 Dependencies
- SQLAlchemy 2.0.23
- Alembic 1.13.0
- Click 8.1.7
- Tabulate 0.9.0

#### 🔧 Breaking Changes
- Imports mudaram de `repositories_orm` para `repositories`
- Todos os projetos devem usar: `from shared.repositories import ...`

---

## [1.0.0] - 2025-08-07

### 🚀 Initial Release

#### ✨ Features
- Schema inicial com 15 tabelas
- Repository Pattern com SQL raw
- Seeds SQL para desenvolvimento
- Scripts de manutenção
- CLI com manage.py
- Backup e restore
- Documentação completa

#### 📊 Tables
- devices
- relay_boards & relay_channels
- screens & screen_items
- telemetry_data
- event_logs
- users
- themes
- can_signals
- macros

---

**Maintainer:** Lee Chardes  
**License:** MIT