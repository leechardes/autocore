# 🔄 Database Migrations

## 📋 Visão Geral

Gerenciamento de migrações de banco de dados usando Alembic.

## 📁 Estrutura

### Migrations Folder
- `alembic/versions/` - Scripts de migração gerados
- `alembic/env.py` - Configuração do ambiente Alembic
- `alembic.ini` - Configuração principal

### Migration Scripts
- **Auto-generated**: Criados via `alembic revision --autogenerate`
- **Custom**: Scripts manuais para mudanças complexas

## 🚀 Comandos Principais

```bash
# Gerar nova migração
alembic revision --autogenerate -m "descrição"

# Aplicar migrações
alembic upgrade head

# Rollback
alembic downgrade -1

# Histórico
alembic history
```

## 📖 Documentação

- [Migration History](../../migrations/MIGRATION-HISTORY.md)
- [Breaking Changes](../../migrations/BREAKING-CHANGES-V2.md)
- [Alembic Workflow](../../development/ALEMBIC-WORKFLOW.md)