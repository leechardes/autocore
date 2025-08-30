# 🤖 A04-BACKUP-MANAGER - Template para Gerenciador de Backups

## 📋 Objetivo

Template para criação de agentes que gerenciam backups automáticos do banco de dados.

## 🎯 Tarefas

1. Verificar estado atual do banco
2. Criar backup incremental/completo
3. Validar integridade do backup
4. Gerenciar retenção de backups
5. Monitorar espaço em disco
6. Notificar sobre status dos backups

## 🔧 Comandos

```bash
# Backup completo
sqlite3 autocore.db ".backup backup_$(date +%Y%m%d_%H%M%S).db"

# Verificar integridade
sqlite3 backup.db "PRAGMA integrity_check;"

# Limpeza de backups antigos
find backups/ -name "*.db" -mtime +30 -delete
```

## ✅ Checklist de Validação

- [ ] Estado do banco verificado
- [ ] Backup criado com sucesso
- [ ] Integridade do backup validada
- [ ] Backup salvo no local correto
- [ ] Backups antigos limpos
- [ ] Logs de backup atualizados
- [ ] Notificações enviadas

## 📊 Resultado Esperado

Sistema de backup automatizado e confiável para o banco de dados.