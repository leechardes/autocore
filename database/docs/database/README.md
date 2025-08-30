# 🗄️ Database AutoCore

## 📋 Visão Geral

Documentação completa da base de dados do sistema AutoCore, incluindo esquemas, modelos e migrações.

## 📁 Estrutura

### 🔗 Schemas
- **Core Schema**: Tabelas principais (users, devices, relays)
- **UI Schema**: Telas, componentes e temas
- **Telemetry Schema**: Dados históricos e métricas
- **Configuration Schema**: Configurações do sistema

### 📊 Models
- **Entity Models**: Modelos de entidades SQLAlchemy
- **Relationships**: Relacionamentos entre entidades
- **Validations**: Validações e constraints

### 🔄 Migrations
- **Alembic Migrations**: Histórico de alterações
- **Migration Scripts**: Scripts de migração personalizados
- **Rollback Procedures**: Procedimentos de rollback

## 🚀 Quick Start

1. Consulte `schemas/` para estrutura das tabelas
2. Revise `models/` para modelos SQLAlchemy
3. Verifique `migrations/` para histórico de mudanças

## 📖 Documentação Detalhada

- [Database Design](../architecture/DATABASE-DESIGN.md)
- [Models Documentation](../models/README.md)
- [Migration History](../migrations/MIGRATION-HISTORY.md)