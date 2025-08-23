# Troubleshooting - [Nome do Problema]

Template para documentar soluções de problemas comuns no Config-App Backend.

## 📋 Informações do Problema

- **Categoria**: `Conexão|Performance|Erro de API|MQTT|Database|Autenticação|Configuração`
- **Severidade**: `Crítica|Alta|Média|Baixa`
- **Frequência**: `Sempre|Frequente|Ocasional|Rara`
- **Ambiente**: `Produção|Staging|Desenvolvimento|Todos`
- **Componente**: `API|Database|MQTT|WebSocket|Específico`

## 🔍 Descrição do Problema

### Sintomas
[Descreva os sintomas visíveis do problema]
- Comportamento observado
- Mensagens de erro
- Impacto nos usuários
- Quando ocorre

### Mensagens de Erro
```
[Cole aqui as mensagens de erro completas]
```

### Screenshots/Logs
```
[Cole logs relevantes ou referência a screenshots]
```

## 🚨 Impacto

### Usuários Afetados
- **Administradores**: [Como são impactados]
- **Operadores**: [Como são impactados]
- **Dispositivos ESP32**: [Como são impactados]
- **Sistemas Externos**: [Como são impactados]

### Funcionalidades Afetadas
- [ ] Login/Autenticação
- [ ] Gerenciamento de dispositivos
- [ ] Controle de relés
- [ ] Configuração de telas
- [ ] Monitoramento MQTT
- [ ] WebSocket streaming
- [ ] API endpoints específicos
- [ ] Performance geral

### Criticidade do Impacto
- 🔴 **Sistema Inoperante**: Serviço completamente fora do ar
- 🟠 **Funcionalidade Crítica**: Recursos importantes indisponíveis
- 🟡 **Degradação**: Funciona mas com problemas
- 🟢 **Inconveniente**: Problema menor que não afeta operação

## 🔍 Diagnóstico

### Primeiros Passos
1. **Verificar Status Geral**
   ```bash
   curl -f http://localhost:8081/api/health
   curl -f http://localhost:8081/api/status
   ```

2. **Verificar Logs**
   ```bash
   # Docker
   docker logs config-app-backend --tail=100

   # Kubernetes
   kubectl logs deployment/config-app-backend --tail=100

   # Sistema
   tail -100 /var/log/config-app/app.log
   ```

3. **Verificar Recursos**
   ```bash
   # CPU e Memória
   top -p $(pgrep -f "python.*main")

   # Disco
   df -h

   # Conexões de rede
   netstat -an | grep :8081
   ```

### Verificações Específicas

#### Database Connection
```bash
# Testar conexão com banco
python -c "
import os
from sqlalchemy import create_engine
engine = create_engine(os.getenv('DATABASE_URL'))
with engine.connect() as conn:
    result = conn.execute('SELECT 1')
    print('Database OK')
"
```

#### MQTT Connection
```bash
# Testar conexão MQTT
mosquitto_pub -h $MQTT_BROKER -t "test/topic" -m "test message"
mosquitto_sub -h $MQTT_BROKER -t "test/topic" -C 1
```

#### API Endpoints
```bash
# Testar endpoints principais
curl -f http://localhost:8081/api/devices
curl -f http://localhost:8081/api/screens
curl -f http://localhost:8081/api/relays/channels
```

#### WebSocket
```javascript
// Testar WebSocket no browser console
const ws = new WebSocket('ws://localhost:8081/ws/mqtt');
ws.onopen = () => console.log('WebSocket Connected');
ws.onmessage = (e) => console.log('Message:', e.data);
ws.onerror = (e) => console.log('Error:', e);
```

### Identificação da Causa Raiz

#### Análise de Logs
```bash
# Procurar por erros específicos
grep -i "error\|exception\|failed" /var/log/config-app/app.log | tail -20

# Buscar padrões temporais
grep "$(date '+%Y-%m-%d %H:%M')" /var/log/config-app/app.log | grep -i error
```

#### Métricas de Performance
```bash
# Verificar latência dos endpoints
curl -w "@curl-format.txt" -s -o /dev/null http://localhost:8081/api/devices

# Conteúdo do curl-format.txt:
#      time_namelookup:  %{time_namelookup}\n
#         time_connect:  %{time_connect}\n
#      time_appconnect:  %{time_appconnect}\n
#     time_pretransfer:  %{time_pretransfer}\n
#        time_redirect:  %{time_redirect}\n
#   time_starttransfer:  %{time_starttransfer}\n
#                     ----------\n
#           time_total:  %{time_total}\n
```

#### Debugging Interativo
```python
# Adicionar breakpoints para debug
import pdb; pdb.set_trace()

# Ou usar debugger mais avançado
import ipdb; ipdb.set_trace()

# Logs detalhados temporários
import logging
logging.getLogger().setLevel(logging.DEBUG)
```

## 🛠️ Soluções

### Solução Rápida (Workaround)
```bash
# Comandos para solução temporária
[comandos ou configurações para contornar o problema temporariamente]
```

**⚠️ Atenção**: Esta é uma solução temporária. Aplicar a solução definitiva o quanto antes.

### Solução Definitiva

#### Passo 1: [Primeira Ação]
```bash
# Comandos específicos
comando1
comando2
```

**Verificação**:
```bash
# Como verificar se o passo funcionou
comando_verificacao
```

#### Passo 2: [Segunda Ação]
```bash
# Mais comandos
comando3
comando4
```

**Verificação**:
```bash
# Verificação do segundo passo
outro_comando_verificacao
```

#### Passo 3: [Terceira Ação]
```bash
# Comandos finais
comando5
```

### Validação da Solução
```bash
# Testes para confirmar que o problema foi resolvido
curl -f http://localhost:8081/api/health
curl -f http://localhost:8081/api/status

# Monitorar por alguns minutos
tail -f /var/log/config-app/app.log
```

## 🔄 Prevenção

### Monitoramento
- **Alertas**: Configurar alertas para detectar o problema antes que afete usuários
- **Métricas**: Monitorar métricas específicas
- **Health Checks**: Implementar verificações automáticas

### Configuração Recomendada
```python
# Configurações para prevenir o problema
RECOMMENDED_CONFIG = {
    "timeout": 30,
    "retry_attempts": 3,
    "connection_pool_size": 10
}
```

### Manutenção Preventiva
- [ ] Limpeza regular de logs
- [ ] Atualização de dependências
- [ ] Monitoramento proativo
- [ ] Testes regulares de conectividade

## 📊 Métricas para Monitorar

### Métricas Específicas
| Métrica | Threshold Normal | Threshold Alerta | Ação |
|---------|------------------|------------------|------|
| [Métrica 1] | < 100ms | > 500ms | Investigar performance |
| [Métrica 2] | < 5% | > 10% | Verificar recursos |
| [Métrica 3] | > 95% | < 90% | Reiniciar serviço |

### Dashboards
- **Grafana**: Link para dashboard específico
- **Logs**: Agregação de logs relacionados
- **Alerting**: Configuração de alertas

## 🚨 Escalação

### Níveis de Escalação
1. **L1 - Suporte Básico** (15 minutos)
   - Aplicar soluções conhecidas
   - Reiniciar serviços se necessário
   - Verificar status básico

2. **L2 - Suporte Técnico** (30 minutos)
   - Análise detalhada de logs
   - Investigação de causa raiz
   - Aplicar soluções avançadas

3. **L3 - Desenvolvimento** (1 hora)
   - Análise de código
   - Debug profundo
   - Implementar correções

### Contatos de Escalação
- **L1 Support**: [contato-l1@empresa.com]
- **L2 Technical**: [contato-l2@empresa.com]
- **L3 Development**: [contato-l3@empresa.com]
- **Emergency**: [emergencia@empresa.com]

### Quando Escalar
- ✅ Solução não funcionou após 2 tentativas
- ✅ Problema afeta > 50% dos usuários
- ✅ Dados podem ser perdidos
- ✅ Problema persiste por > tempo_limite
- ✅ Causa raiz desconhecida

## 📋 Checklist de Resolução

### Durante o Incidente
- [ ] Problema identificado e categorizado
- [ ] Impacto avaliado
- [ ] Stakeholders notificados
- [ ] Solução temporária aplicada (se possível)
- [ ] Investigação da causa raiz iniciada
- [ ] Solução definitiva implementada
- [ ] Validação da solução realizada
- [ ] Sistema monitorado pós-correção

### Pós-Incidente
- [ ] Post-mortem documentado
- [ ] Causa raiz identificada
- [ ] Ações preventivas definidas
- [ ] Documentação atualizada
- [ ] Monitoramento aprimorado
- [ ] Equipe treinada (se necessário)
- [ ] Stakeholders informados da resolução

## 📚 Recursos Relacionados

### Documentação
- [Guia de Debug](../troubleshooting/debugging-guide.md)
- [Arquitetura do Sistema](../architecture/system-overview.md)
- [Configurações](../deployment/environment-variables.md)

### Ferramentas Úteis
- **Logs Aggregator**: [Link/comando]
- **Monitoring Dashboard**: [Link]
- **Debug Tools**: [Lista de ferramentas]

### Problemas Similares
- [Problema Similar 1](similar-problem-1.md)
- [Problema Similar 2](similar-problem-2.md)

## 📝 Histórico de Ocorrências

### Incidentes Anteriores
| Data | Duração | Causa | Solução Aplicada |
|------|---------|-------|------------------|
| 15/01/2025 | 30min | [Causa] | [Solução] |
| 10/01/2025 | 15min | [Causa] | [Solução] |

### Padrões Identificados
- **Horário**: Problema ocorre mais em [horário/dia]
- **Trigger**: Geralmente causado por [evento]
- **Ambiente**: Mais comum em [ambiente]

## 🔍 Análise Post-Mortem

### O que Funcionou Bem
- [Item 1 que funcionou]
- [Item 2 que funcionou]

### O que Pode Melhorar
- [Item 1 para melhorar]
- [Item 2 para melhorar]

### Ações de Seguimento
- [ ] Implementar monitoramento adicional
- [ ] Melhorar documentação
- [ ] Treinamento da equipe
- [ ] Automatizar correção

---

## ✏️ Como Usar Este Template

1. **Copie este arquivo** para `docs/troubleshooting/[nome-problema].md`
2. **Preencha todas as seções** com informações específicas
3. **Teste todas as soluções** em ambiente seguro
4. **Valide com a equipe** de operações
5. **Mantenha atualizado** conforme novos casos surgem

### Nomenclatura de Arquivos
- `database-connection-failed.md`
- `mqtt-broker-timeout.md`
- `high-cpu-usage.md`
- `websocket-not-connecting.md`
- `api-500-errors.md`

### Categorias Sugeridas
- **connection-issues/** - Problemas de conectividade
- **performance-issues/** - Problemas de performance
- **api-errors/** - Erros de API
- **auth-problems/** - Problemas de autenticação
- **config-issues/** - Problemas de configuração

---

*Template atualizado em: 22/01/2025*