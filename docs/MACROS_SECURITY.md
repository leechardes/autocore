# Segurança do Sistema de Macros

## Visão Geral

O sistema de macros do AutoCore implementa várias camadas de segurança para prevenir acionamentos acidentais ou perigosos de equipamentos críticos do veículo.

## Proteções Implementadas

### 1. Campo `allow_in_macro`

Cada canal de relé possui um campo booleano `allow_in_macro` que determina se pode ser usado em macros:

```python
# database/src/models/models.py
class RelayChannel(Base):
    # ...
    allow_in_macro = Column(Boolean, default=True)
```

### 2. Filtros por Tipo de Função

Canais com `function_type = 'momentary'` são automaticamente excluídos de macros:

```javascript
// MacroActionEditor.jsx
const availableChannels = channels.filter(channel => 
    channel.function_type !== 'momentary' && 
    channel.allow_in_macro !== false
);
```

### 3. Canais Críticos Protegidos

Por padrão, os seguintes canais são marcados como `allow_in_macro = false`:

- **Guincho (Winch)** - Equipamento de alta potência
- **Canais Momentâneos** - Requerem ação contínua do usuário
- **Equipamentos de Segurança** - Definidos pelo administrador

### 4. Script de Atualização

Script automatizado para configurar permissões em canais existentes:

```python
# database/scripts/update_macro_permissions.py
def update_macro_permissions():
    # Desabilita macros para canais momentâneos
    channels = session.query(RelayChannel).filter_by(
        function_type='momentary'
    ).all()
    
    for channel in channels:
        channel.allow_in_macro = False
    
    # Desabilita para canais específicos (guincho)
    winch_channels = session.query(RelayChannel).filter(
        RelayChannel.name.ilike('%guincho%') |
        RelayChannel.name.ilike('%winch%')
    ).all()
    
    for channel in winch_channels:
        channel.allow_in_macro = False
```

## Interface do Usuário

### Editor de Macros

O editor de macros mostra apenas canais permitidos:

1. **Lista Filtrada** - Apenas canais com `allow_in_macro = true`
2. **Nomes Descritivos** - Mostra "Canal X - Nome" para clareza
3. **Validação em Tempo Real** - Impede seleção de canais bloqueados

### Indicadores Visuais

- Canais bloqueados não aparecem no dropdown
- Tooltips explicam por que certos canais não estão disponíveis
- Ícones de cadeado em canais protegidos na lista principal

## Configuração

### Via API

```python
# Atualizar permissão de um canal
PUT /api/relays/channels/{channel_id}
{
    "allow_in_macro": false
}
```

### Via Interface Web

1. Navegue para **Configuração de Relés**
2. Clique em **Editar** no canal desejado
3. Desmarque **"Permitir em Macros"**
4. Salve as alterações

## Heartbeat para Canais Críticos

Canais momentâneos usam sistema de heartbeat:

```javascript
// Macro não pode controlar canais com heartbeat
if (channel.requires_heartbeat) {
    throw new Error("Canal requer heartbeat manual");
}
```

## Auditoria e Logs

Todas as mudanças em `allow_in_macro` são registradas:

```python
# Log de alteração
logger.info(f"Canal {channel_id} - allow_in_macro alterado para {value}")
```

## Boas Práticas

1. **Revise Regularmente** - Verifique permissões de macros periodicamente
2. **Princípio do Menor Privilégio** - Habilite apenas o necessário
3. **Teste em Ambiente Seguro** - Sempre teste macros antes de usar
4. **Documente Exceções** - Se habilitar canal crítico, documente o motivo
5. **Backup de Configurações** - Mantenha backup das configurações de segurança

## Recuperação de Emergência

Se uma macro causar problemas:

1. **Parada de Emergência** - Botão físico de corte de energia
2. **Desabilitar Todas as Macros** - Via comando MQTT de emergência
3. **Reset de Permissões** - Script para restaurar configurações seguras

```bash
# Reset de emergência
python database/scripts/emergency_reset_macros.py
```

## Checklist de Segurança

Antes de criar uma macro:

- [ ] Verificar se todos os canais são apropriados
- [ ] Testar com simulador primeiro
- [ ] Adicionar delays adequados entre ações
- [ ] Configurar heartbeat se necessário
- [ ] Documentar o propósito da macro
- [ ] Revisar com outro operador
- [ ] Fazer backup antes de ativar

## Suporte

Para questões de segurança ou configuração:
- Documentação: `/docs/security`
- Logs: `/logs/macro_security.log`
- Suporte: security@autocore.local