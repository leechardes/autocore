# 📋 PADRONIZAÇÃO DE TIPOS E ENUMS - AUTOCORE DATABASE

## 🎯 Objetivo
Padronizar todos os tipos e enums do sistema para minúsculo, garantindo consistência entre Database, Backend e Frontend.

## 🔴 Problemas Identificados

### 1. Inconsistência de Tipos no Banco
```sql
-- Situação Atual (INCORRETO)
item_type: 'display', 'DISPLAY', 'BUTTON', 'SWITCH'  -- Misturado
action_type: 'relay_toggle', 'RELAY_CONTROL'         -- Misturado
```

### 2. Erro ao Salvar
- Frontend envia minúsculo
- Backend espera maiúsculo (Enums)
- Database tem misturado
- **Resultado**: Erro 500 mas salva mesmo assim

### 3. Valores Inconsistentes
```python
# Encontrados no banco
item_type = ['display', 'DISPLAY', 'BUTTON', 'SWITCH', 'GAUGE']
action_type = ['relay_toggle', 'RELAY_CONTROL', None]
size_* = ['small', 'normal', 'large', 'full']
```

## ✅ Padrão Definido (TUDO MINÚSCULO)

### item_type
```python
ITEM_TYPES = [
    'display',  # Exibição de dados (gauge digital)
    'button',   # Botão de ação
    'switch',   # Switch toggle
    'gauge'     # Medidor analógico (futuro)
]
```

### action_type
```python
ACTION_TYPES = [
    'relay_control',  # Controle de relé
    'navigation',     # Navegação entre telas
    'command',        # Comando customizado
    'preset',         # Ativar preset
    'macro',          # Executar macro
    None              # Sem ação (displays)
]
```

### device_type
```python
DEVICE_TYPES = [
    'esp32_display',   # Display HMI
    'relay_board',     # Placa de relés
    'sensor_board',    # Placa de sensores
    'gateway'          # Gateway MQTT
]
```

### status (devices)
```python
DEVICE_STATUS = [
    'online',
    'offline', 
    'error',
    'maintenance'
]
```

### function_type (relays)
```python
FUNCTION_TYPES = [
    'toggle',      # Liga/desliga alternado
    'momentary',   # Momentâneo (segura pressionado)
    'pulse',       # Pulso único
    'timer'        # Temporizado
]
```

### protection_mode
```python
PROTECTION_MODES = [
    'none',        # Sem proteção
    'interlock',   # Intertravamento
    'exclusive',   # Exclusivo no grupo
    'timed'        # Proteção temporizada
]
```

### Tamanhos (size_mobile, size_display_small, size_display_large, size_web)
```python
SIZES = [
    'small',   # Tamanho pequeno (70x60)
    'normal',  # Tamanho padrão (86x72)
    'large',   # Tamanho grande (140x90)
    'full'     # Largura total (320xN)
]
```

## 🔧 Plano de Execução

### Fase 1: Análise (Agente 1)
- [ ] Analisar models.py - verificar Enums definidos
- [ ] Analisar repositories - como está salvando
- [ ] Analisar normalizers - conversões aplicadas
- [ ] Analisar frontend - como envia dados
- [ ] Listar todas inconsistências

### Fase 2: Correção Database (Agente 2A)
- [ ] Criar migration para converter tudo para minúsculo
- [ ] UPDATE em todos registros existentes
- [ ] Remover Enums SQLAlchemy (usar strings)
- [ ] Adicionar CHECK constraints para validar valores

### Fase 3: Correção Backend (Agente 2B)
- [ ] Atualizar models.py - remover Enums, usar strings
- [ ] Atualizar normalizers.py - sempre converter para minúsculo
- [ ] Atualizar repositories - validar antes de salvar
- [ ] Adicionar validadores customizados

### Fase 4: Correção Frontend (Agente 2C)
- [ ] Atualizar constants.js com valores minúsculos
- [ ] Ajustar componentes de formulário
- [ ] Garantir envio sempre em minúsculo
- [ ] Atualizar validações client-side

### Fase 5: Validação (Agente 3)
- [ ] Verificar todos registros padronizados
- [ ] Testar criação de novo item
- [ ] Testar edição de item existente
- [ ] Verificar se ESP32 continua funcionando
- [ ] Confirmar ausência de erros 500

## 📊 Queries de Verificação

### Verificar Inconsistências Atuais
```sql
-- Item types inconsistentes
SELECT DISTINCT item_type, COUNT(*) 
FROM screen_items 
GROUP BY item_type;

-- Action types inconsistentes
SELECT DISTINCT action_type, COUNT(*) 
FROM screen_items 
GROUP BY action_type;

-- Device types inconsistentes
SELECT DISTINCT type, COUNT(*) 
FROM devices 
GROUP BY type;
```

### Queries de Correção (BACKUP PRIMEIRO!)
```sql
-- Padronizar item_type
UPDATE screen_items 
SET item_type = LOWER(item_type)
WHERE item_type IS NOT NULL;

-- Padronizar action_type
UPDATE screen_items 
SET action_type = LOWER(action_type)
WHERE action_type IS NOT NULL;

-- Padronizar device type
UPDATE devices 
SET type = LOWER(type)
WHERE type IS NOT NULL;

-- Padronizar relay function_type
UPDATE relay_channels 
SET function_type = LOWER(function_type)
WHERE function_type IS NOT NULL;
```

## 🚨 Pontos de Atenção

1. **FAZER BACKUP DO BANCO ANTES DE QUALQUER ALTERAÇÃO**
2. **Testar em ambiente de desenvolvimento primeiro**
3. **ESP32 precisa continuar funcionando após mudanças**
4. **Frontend precisa ser atualizado simultaneamente**
5. **Documentar todas as mudanças**

## 📝 Checklist de Validação Final

- [ ] Todos os tipos no banco estão em minúsculo
- [ ] Backend aceita e valida apenas minúsculo
- [ ] Frontend envia apenas minúsculo
- [ ] Novo registro salva sem erro 500
- [ ] Edição funciona corretamente
- [ ] ESP32 recebe configuração corretamente
- [ ] Documentação atualizada

## 🔄 Rollback (se necessário)

### Database
```sql
-- Restaurar backup
psql autocore < backup_antes_padronizacao.sql
```

### Backend
```bash
# Reverter commits
git revert <commit_hash>
```

### Frontend
```bash
# Reverter para branch anterior
git checkout main-before-padronization
```

## 📅 Timeline

| Fase | Descrição | Tempo Estimado | Status |
|------|-----------|----------------|--------|
| 1 | Análise Completa | 30 min | ⏳ Pendente |
| 2A | Correção Database | 45 min | ⏳ Pendente |
| 2B | Correção Backend | 30 min | ⏳ Pendente |
| 2C | Correção Frontend | 30 min | ⏳ Pendente |
| 3 | Validação | 30 min | ⏳ Pendente |
| **Total** | **Implementação Completa** | **~2h45min** | ⏳ Pendente |

## 🎯 Resultado Esperado

Após conclusão:
1. **100% consistência** nos tipos e enums
2. **Zero erros 500** ao salvar/editar
3. **Validação automática** de tipos
4. **Documentação completa** e atualizada
5. **Sistema mais robusto** e maintível

---

**Data de Criação**: 19/01/2025  
**Autor**: Sistema AutoCore  
**Versão**: 1.0.0  
**Status**: 🔴 Em Implementação