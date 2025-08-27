# A44 - MQTT Button Analysis Agent

## 📋 Objetivo
Analisar a documentação MQTT-ARCHITECTURE.md para entender completamente os fluxos de botões toggle e momentâneos, identificar gaps de implementação e criar plano detalhado de alterações.

## 🎯 Escopo da Análise

### 1. Análise de Documentação
- [ ] Ler /Users/leechardes/Projetos/AutoCore/docs/architecture/MQTT-ARCHITECTURE.md
- [ ] Mapear tópicos MQTT relevantes para botões
- [ ] Entender protocolo de heartbeat/keepalive
- [ ] Identificar fluxo de feedback de estado

### 2. Fluxos de Botão Toggle
- [ ] Comando de toggle enviado
- [ ] Aguardo de confirmação MQTT
- [ ] Atualização de estado baseada em feedback
- [ ] Tratamento de timeouts e falhas

### 3. Fluxos de Botão Momentâneo
- [ ] onPressed → enviar comando ON + iniciar heartbeat
- [ ] Durante pressionamento → enviar heartbeat a cada 500ms
- [ ] onReleased → parar heartbeat + enviar comando OFF
- [ ] Timeout de segurança (1s sem heartbeat = OFF automático)

### 4. Análise de Implementação Atual
- [ ] Verificar ButtonItemWidget atual
- [ ] Verificar MqttService atual
- [ ] Identificar gaps de implementação
- [ ] Mapear alterações necessárias

## 🔧 Pontos de Verificação

### Tópicos MQTT Esperados
```
# Para Toggle
autocore/devices/{device_id}/relays/set      # Comando
autocore/devices/{device_id}/relays/status   # Feedback

# Para Momentâneo
autocore/devices/{device_id}/relays/set      # Comando inicial
autocore/devices/{device_id}/relays/heartbeat # Keep-alive
autocore/devices/{device_id}/relays/status   # Confirmação
```

### Payload Esperado
```json
// Toggle Command
{
  "channel": 1,
  "state": true/false,
  "timestamp": "2025-08-25T10:00:00Z"
}

// Momentary Command
{
  "channel": 1,
  "state": true/false,
  "momentary": true,
  "timestamp": "2025-08-25T10:00:00Z"
}

// Heartbeat
{
  "channel": 1,
  "sequence": 1,
  "timestamp": "2025-08-25T10:00:00Z"
}
```

## 📊 Resultado Esperado

### Entregáveis
1. **Mapeamento Completo**: Fluxos MQTT documentados
2. **Gap Analysis**: O que falta implementar
3. **Plano de Implementação**: Passo a passo detalhado
4. **Estimativa**: Tempo e complexidade

### Formato do Relatório
```markdown
## Análise MQTT - Botões

### 1. Fluxo Toggle Atual
- Como está implementado
- Problemas identificados
- Melhorias necessárias

### 2. Fluxo Momentâneo Atual
- Como está implementado
- Riscos de segurança
- Implementação de heartbeat

### 3. Plano de Implementação
- Fase 1: Correção Toggle
- Fase 2: Implementação Momentâneo
- Fase 3: Testes e Validação

### 4. Alterações Necessárias
- ButtonItemWidget
- MqttService
- Novos componentes
```

## ⚠️ Pontos Críticos

### Segurança
- Heartbeat OBRIGATÓRIO para momentâneos
- Timeout de 1s sem heartbeat = OFF
- Evitar travamento em estado ON
- Feedback visual de estado

### Performance
- Debounce para evitar spam
- Otimização de heartbeat
- Cache de estados
- Retry inteligente

### UX
- Feedback visual imediato (otimista)
- Indicador de sincronização
- Tratamento de latência
- Estados de erro claros

## 🚀 Comando de Execução

```bash
# O agente deve:
1. Ler documentação MQTT
2. Analisar código atual
3. Identificar gaps
4. Criar plano detalhado
5. NÃO IMPLEMENTAR - apenas planejar
```

---
**Data de Criação**: 25/08/2025
**Tipo**: Análise e Planejamento
**Prioridade**: CRÍTICA
**Estimativa**: 30 minutos
**Status**: Pronto para Execução