# 📋 AutoCore Database Documentation

Documentação completa do sistema de banco de dados do AutoCore - Sistema de controle IoT para ESP32 com SQLAlchemy ORM e Alembic migrations.

## 🎯 Visão Geral

O AutoCore usa SQLite como banco principal com planejamento de migração para PostgreSQL. Todo gerenciamento é feito através de SQLAlchemy ORM e Alembic migrations - **nunca comandos SQL diretos**.

### 🏗️ Arquitetura
- **ORM**: SQLAlchemy 2.0+
- **Migrations**: Alembic 
- **Database Atual**: SQLite
- **Database Futuro**: PostgreSQL
- **Padrão**: Repository Pattern com declarative base

## 📁 Estrutura da Documentação

### 🔧 Models & Schema
- [`database/`](./database/) - Estrutura central de database, schemas e modelos
- [`models/`](./models/) - Documentação dos SQLAlchemy models
- [`schemas/`](./schemas/) - Estrutura do banco, ER diagrams, constraints
- [`services/`](./services/) - Padrões SQLAlchemy, queries, repositories

### 🔄 Migrations & Deployment  
- [`migrations/`](./migrations/) - Alembic workflows e histórico
- [`deployment/`](./deployment/) - Docker, setup SQLite/PostgreSQL
- [`development/`](./development/) - Ambiente dev, seeds, testes

### 🚀 Performance & Segurança
- [`performance/`](./performance/) - Otimização, índices, caching
- [`security/`](./security/) - Controle acesso, encryption, audit
- [`troubleshooting/`](./troubleshooting/) - Resolução de problemas

### 🤖 Automação
- [`templates/`](./templates/) - Templates para models, migrations, repos
- [`agents/`](./agents/) - Sistema de agentes para database

## 🚀 Quick Start

### SQLAlchemy Models
```python
from src.models.models import Device, RelayChannel, Screen
from src.models.models import get_session

# Session management
session = get_session()
devices = session.query(Device).filter_by(status='online').all()
```

### Alembic Migrations
```bash
# Gerar migration
alembic revision --autogenerate -m "descrição da mudança"

# Aplicar migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

## 📊 Estatísticas do Sistema

- **Models**: 15 models principais
- **Migrations**: 6+ migrations aplicadas
- **Relationships**: 20+ relationships mapeados
- **Índices**: 25+ índices otimizados
- **Constraints**: 10+ constraints de validação

## 📈 Roadmap SQLite → PostgreSQL

### Fase 1: Preparação ✅
- [x] Audit features SQLite específicas
- [x] Mapeamento tipos de dados
- [x] Identificação incompatibilidades

### Fase 2: Migration 🔄
- [ ] Setup PostgreSQL com Docker
- [ ] Adaptação Alembic migrations
- [ ] Scripts migração de dados

### Fase 3: Validação 📋
- [ ] Testes integridade dados
- [ ] Comparação performance
- [ ] Plano rollback

## 🎛️ Models Principais

| Model | Descrição | Relationships |
|-------|-----------|---------------|
| `Device` | ESP32 devices | → RelayBoard, TelemetryData |
| `RelayBoard` | Placas de relé | ← Device, → RelayChannel |
| `RelayChannel` | Canais individuais | ← RelayBoard |
| `Screen` | Telas da interface | → ScreenItem |
| `ScreenItem` | Itens das telas | ← Screen, → RelayChannel |
| `User` | Usuários sistema | → EventLog |
| `TelemetryData` | Dados telemetria | ← Device |
| `EventLog` | Logs eventos | ← User |
| `Icon` | Ícones sistema | Self-reference |
| `Theme` | Temas visuais | - |
| `Macro` | Automações | - |
| `CANSignal` | Sinais CAN | - |

## 🔍 Navegação Rápida

### Para Desenvolvedores
- [Getting Started](./development/getting-started.md)
- [SQLAlchemy Guide](./development/sqlalchemy-guide.md)
- [Alembic Workflow](./development/alembic-workflow.md)

### Para DBAs
- [Database Design](./architecture/database-design.md)
- [Performance Optimization](./performance/query-optimization.md)
- [Backup Strategy](./deployment/backup-strategy.md)

### Para DevOps
- [Docker PostgreSQL](./deployment/docker-postgres.md)
- [Monitoring](./deployment/monitoring.md)
- [Troubleshooting](./troubleshooting/common-errors.md)

## 🤖 Sistema de Agentes

Os agentes automatizam tarefas do database:

- **A01-migration-creator**: Cria migrations com Alembic
- **A02-model-generator**: Gera models SQLAlchemy
- **A03-seed-runner**: Popula dados de teste
- **A04-backup-manager**: Gerencia backups automatizados
- **A05-performance-analyzer**: Analisa queries lentas

Ver [Agentes Dashboard](./agents/A98-DASHBOARD.md) para mais detalhes.

## 📞 Suporte

### Documentação
- [CHANGELOG](./CHANGELOG.md) - Histórico de mudanças
- [VERSION](./VERSION.md) - Versionamento
- [Architecture](./architecture/) - Design patterns

### Troubleshooting
- [Common Errors](./troubleshooting/common-errors.md)
- [Migration Issues](./troubleshooting/migration-issues.md)
- [Performance Problems](./troubleshooting/performance-problems.md)

---

**Última atualização**: 22/08/2025  
**Versão da documentação**: 2.0  
**Database version**: SQLite → PostgreSQL migration planned