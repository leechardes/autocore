# 🗄️ AutoCore Database

Sistema de gerenciamento de banco de dados centralizado para o AutoCore usando **SQLAlchemy ORM**.

## 🎯 Visão Geral

Este projeto é o **owner** do banco de dados SQLite do sistema AutoCore, fornecendo:
- 🏗️ **SQLAlchemy ORM** para portabilidade entre bancos de dados
- 🔄 **Repository Pattern** compartilhado com ORM
- 🚀 **Migrations automáticas** com Alembic
- 🌱 **Seeds ORM** para desenvolvimento e testes
- 🧹 **Scripts de manutenção** automática

## 🏗️ Arquitetura

```
database/                     # Projeto independente
├── autocore.db              # Banco SQLite (criado após init)
├── alembic.ini              # Config do Alembic
├── requirements.txt         # Dependências Python
├── src/                     # Código fonte
│   ├── cli/                # Ferramentas CLI
│   │   └── manage.py       # CLI principal
│   ├── models/             # Modelos SQLAlchemy
│   │   └── models.py       # Definição das tabelas
│   └── migrations/         # Auto-migration
│       ├── alembic_setup.py
│       └── auto_migrate.py
├── shared/                  # Repository Pattern compartilhado
│   ├── connection.py       # Conexão otimizada
│   └── repositories.py     # Repositories
├── migrations/              # Migrations SQL
│   └── 001_initial_schema.sql
├── seeds/                   # Dados iniciais
│   └── 01_default_devices.sql
├── scripts/                 # Scripts de manutenção
│   ├── maintenance.py
│   └── schedule_maintenance.sh
├── alembic/                 # Diretório do Alembic (auto-criado)
└── docs/                    # Documentação
    ├── api/                 # Documentação de APIs
    │   └── repositories.md
    ├── architecture/        # Arquitetura e design
    │   ├── DATABASE.md
    │   ├── DATA_FLOW.md
    │   └── schema.dbml
    ├── guides/              # Guias e tutoriais
    │   ├── MAINTENANCE.md
    │   └── setup.md
    └── migrations/          # Documentação de migrations
```

## 🚀 Quick Start

### Instalação

```bash
cd database
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Inicializar Banco

```bash
# Criar banco do zero com schema e seeds
python src/cli/manage.py init

# Ou passo a passo:
python src/cli/manage.py migrate   # Aplica migrations
python src/cli/manage.py seed      # Aplica seeds
```

## 🔧 Gerenciamento com manage.py

### Comandos Disponíveis

```bash
# Inicialização e Setup
python src/cli/manage.py init        # Cria banco do zero
python src/cli/manage.py migrate     # Aplica migrations pendentes
python src/cli/manage.py seed        # Aplica dados iniciais

# Status e Monitoramento
python src/cli/manage.py status      # Mostra status do banco
python src/cli/manage.py console     # Abre console SQL interativo

# Backup e Restore
python src/cli/manage.py backup                    # Cria backup
python src/cli/manage.py restore --file backup.gz  # Restaura backup

# Manutenção
python src/cli/manage.py clean       # Limpa dados antigos (padrão 7 dias)
python src/cli/manage.py clean --days 3  # Limpa dados > 3 dias
```

### Exemplos de Uso

```bash
# Ver status completo
$ python src/cli/manage.py status

📊 Status do Banco de Dados
========================================
📁 Arquivo: /home/pi/autocore/database/autocore.db
💾 Tamanho: 2.5 MB

📋 Tabelas (15):
  • devices: 5 registros
  • relay_channels: 64 registros
  • telemetry_data: 10543 registros
  • event_logs: 1823 registros

🔄 Últimas migrations:
  • 001_initial_schema (2025-08-07 10:00:00)
```

## 📝 Migrations

### Auto-Migration com SQLAlchemy

```bash
# Sincronizar banco com models (desenvolvimento)
python src/migrations/auto_migrate.py sync

# Gerar migration automática
python src/migrations/auto_migrate.py generate -m "Descrição da mudança"

# Aplicar migrations
python src/migrations/auto_migrate.py apply

# Gerar e aplicar automaticamente
python src/migrations/auto_migrate.py auto -m "Descrição"

# Ver histórico
python src/migrations/auto_migrate.py history
```

### Criar Nova Migration Manual

```bash
# Criar arquivo de migration
touch migrations/002_add_new_feature.sql

# Editar com as mudanças
nano migrations/002_add_new_feature.sql
```

### Formato de Migration

```sql
-- Migration: 002_add_new_feature
-- Created: 2025-08-07
-- Description: Adiciona suporte para X

ALTER TABLE devices ADD COLUMN new_field VARCHAR(100);
CREATE INDEX idx_devices_new_field ON devices(new_field);
```

### Aplicar Migrations

```bash
# Aplica todas pendentes
python src/cli/manage.py migrate

# Verificar status
python src/cli/manage.py status
```

## 🌱 Seeds (Dados Iniciais)

### Estrutura

```
seeds/
├── 01_default_devices.sql    # Dispositivos padrão
├── 02_default_screens.sql    # Telas padrão
└── 03_default_themes.sql     # Temas padrão
```

### Aplicar Seeds

```bash
# Todos os seeds
python src/cli/manage.py seed

# Seed específico
python src/cli/manage.py seed --file 01_default_devices.sql
```

## 🔗 Uso pelos Outros Projetos

### Gateway

```python
# gateway/main.py
import sys
sys.path.append('../database')

from shared.repositories import devices, telemetry, events

# Usa os repositories
devices.update_status(1, 'online')
telemetry.save(1, 'sensor', 'temp', 25.5, '°C')
```

### Config App

```python
# config-app/backend/main.py
import sys
sys.path.append('../../database')

from shared.repositories import devices, config

# Usa os repositories
all_devices = devices.get_all()
screens = config.get_screens()
```

## 🧹 Manutenção Automática

### Agendamento no Cron

```bash
# Instalar agendamentos
cd database/scripts
./schedule_maintenance.sh
```

### Tarefas Agendadas

| Frequência | Tarefa | Descrição |
|------------|--------|-----------|
| Diária 3AM | Clean | Remove telemetria > 7 dias |
| Semanal | Vacuum | Desfragmenta banco |
| Mensal | Full | Manutenção completa |

### Manutenção Manual

```bash
# Limpeza completa
python src/cli/manage.py clean

# Ver estatísticas antes
python scripts/maintenance.py stats

# Executar manutenção full
python scripts/maintenance.py full
```

## 💾 Backup e Restore

### Backup Manual

```bash
# Criar backup (compactado)
python src/cli/manage.py backup

# Backup em diretório específico
python src/cli/manage.py backup --output /mnt/usb/backups
```

### Backup Automático

```bash
# Adicionar ao cron
0 2 * * * cd /home/pi/autocore/database && python src/cli/manage.py backup
```

### Restore

```bash
# Restaurar de backup
python src/cli/manage.py restore --file /backups/autocore_backup_20250807.db.gz
```

## 📊 Schema

### Tabelas Principais

| Tabela | Descrição | Gerenciado por |
|--------|-----------|----------------|
| devices | Dispositivos ESP32 | Gateway + Config |
| relay_boards | Placas de relé | Config App |
| relay_channels | Canais individuais | Config App |
| telemetry_data | Dados de sensores | Gateway (write) |
| event_logs | Logs do sistema | Ambos |
| screens | Configuração UI | Config App |
| users | Usuários | Config App |

### Documentação Completa

- [Schema DBML](docs/architecture/schema.dbml) - Documentação visual
- [Database Original](docs/architecture/DATABASE.md) - Documentação detalhada
- [Data Flow](docs/architecture/DATA_FLOW.md) - Fluxo de dados
- [Maintenance](docs/guides/MAINTENANCE.md) - Guia de manutenção
- [Setup Guide](docs/guides/setup.md) - Guia de configuração
- [API Repositories](docs/api/repositories.md) - API dos repositories

## 🔐 Segurança

### Configurações SQLite

```python
# Aplicadas automaticamente em shared/connection.py
PRAGMA journal_mode=WAL;      # Permite concorrência
PRAGMA synchronous=NORMAL;    # Balanço performance/segurança
PRAGMA foreign_keys=ON;       # Integridade referencial
```

### Permissões

```bash
# Apenas o usuário pi pode acessar
chmod 600 autocore.db
chown pi:pi autocore.db
```

## 📈 Performance

### Otimizações para Raspberry Pi Zero 2W

- WAL mode para concorrência
- Cache de 10MB em RAM
- Memory-mapped I/O (30MB)
- Índices estratégicos
- Limpeza automática

### Métricas

| Métrica | Valor |
|---------|-------|
| Tamanho máximo | < 50MB com limpeza |
| RAM usage | ~10MB |
| Queries/seg | ~1000 |
| Latência | < 10ms |

## 🐛 Troubleshooting

### Banco corrompido

```bash
# Verificar integridade
sqlite3 autocore.db "PRAGMA integrity_check"

# Tentar recuperar
sqlite3 autocore.db ".recover" | sqlite3 recovered.db

# Ou restaurar backup
python src/cli/manage.py restore --file último_backup.gz
```

### Performance ruim

```bash
# Executar manutenção
python src/cli/manage.py clean
python src/cli/manage.py vacuum

# Recriar índices
sqlite3 autocore.db "REINDEX"
```

### Banco muito grande

```bash
# Ver o que está ocupando espaço
python scripts/maintenance.py stats

# Limpar agressivamente
python src/cli/manage.py clean --days 1
```

## 📚 Referências

- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- [Alembic Migrations](https://alembic.sqlalchemy.org/)

---

**Última Atualização:** 07 de agosto de 2025  
**Maintainer:** Lee Chardes  
**Versão:** 1.0.0