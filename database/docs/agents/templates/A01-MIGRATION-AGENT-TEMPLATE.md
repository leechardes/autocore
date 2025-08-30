# 🤖 A01-MIGRATION-CREATOR - Template para Agente de Migração

## 📋 Objetivo

Template para criação de agentes que gerenciam migrações de banco de dados automaticamente.

## 🎯 Tarefas

1. Detectar mudanças nos models
2. Gerar migrações Alembic
3. Validar integridade dos dados
4. Executar testes de migração
5. Aplicar migrações de forma segura

## 🔧 Comandos

```bash
# Gerar nova migração
alembic revision --autogenerate -m "descrição_da_mudança"

# Validar migração
alembic check

# Aplicar migração
alembic upgrade head

# Rollback em caso de erro
alembic downgrade -1
```

## ✅ Checklist de Validação

- [ ] Models modificados detectados
- [ ] Migração gerada com sucesso
- [ ] Schema validado
- [ ] Backup criado antes da aplicação
- [ ] Migração aplicada com sucesso
- [ ] Testes pós-migração executados

## 📊 Resultado Esperado

Migração de banco de dados aplicada de forma segura e automática.