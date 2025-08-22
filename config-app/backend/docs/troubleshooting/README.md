# Troubleshooting

Guias para resolução de problemas comuns no Config-App Backend.

## 📋 Problemas Categorizados

### 🔌 Conectividade
- [MQTT Broker Connection Failed](mqtt-broker-timeout.md) - Falha na conexão MQTT
- [Database Connection Error](database-connection-failed.md) - Problemas de conexão com banco
- [WebSocket Not Connecting](websocket-connection-issues.md) - WebSocket não conecta
- [ESP32 Registration Failed](esp32-registration-failed.md) - Dispositivos não se registram

### 🚀 Performance
- [High CPU Usage](high-cpu-usage.md) - CPU constantemente alta
- [Memory Leaks](memory-leak-issues.md) - Vazamentos de memória
- [Slow API Response](slow-api-response.md) - APIs lentas
- [Database Query Timeout](database-query-timeout.md) - Queries demoradas

### 🔌 API Errors
- [500 Internal Server Error](api-500-errors.md) - Erros internos do servidor
- [422 Validation Errors](api-validation-errors.md) - Erros de validação
- [404 Not Found Issues](api-404-errors.md) - Recursos não encontrados
- [CORS Issues](cors-policy-errors.md) - Problemas de CORS

### 🔐 Autenticação
- [Token Validation Failed](token-validation-failed.md) - Problemas com JWT
- [Permission Denied](permission-denied-errors.md) - Problemas de autorização
- [Session Expired](session-expired-issues.md) - Sessões expiradas

### ⚙️ Configuração
- [Environment Variables](environment-variable-issues.md) - Problemas de configuração
- [Docker Container Issues](docker-container-problems.md) - Problemas com containers
- [Port Already in Use](port-already-in-use.md) - Conflitos de porta

## 🆘 Guia de Resolução Rápida

### 1. Problemas Mais Comuns

#### API Não Responde
```bash
# Verificar se o serviço está rodando
ps aux | grep python | grep main
netstat -tulpn | grep :8081

# Verificar logs
docker logs config-app-backend --tail=50
```

#### Erro 500 Interno
```bash
# Ver último erro nos logs
tail -100 /var/log/config-app/app.log | grep -i error

# Verificar conexão com banco
python -c "
from sqlalchemy import create_engine
import os
try:
    engine = create_engine(os.getenv('DATABASE_URL'))
    with engine.connect() as conn:
        result = conn.execute('SELECT 1')
    print('✅ Database OK')
except Exception as e:
    print(f'❌ Database Error: {e}')
"
```

#### WebSocket Não Conecta
```bash
# Testar WebSocket com curl
curl --include \
     --no-buffer \
     --header "Connection: Upgrade" \
     --header "Upgrade: websocket" \
     --header "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" \
     --header "Sec-WebSocket-Version: 13" \
     http://localhost:8081/ws/mqtt
```

#### MQTT Não Funciona
```bash
# Testar broker MQTT
mosquitto_pub -h localhost -t "test/topic" -m "test message"
mosquitto_sub -h localhost -t "test/topic" -C 1
```

### 2. Comandos de Diagnóstico Rápido

#### Health Check Completo
```bash
#!/bin/bash
echo "🔍 Config-App Health Check"
echo "=========================="

# API Status
echo "📡 API Status:"
curl -f http://localhost:8081/api/health 2>/dev/null && echo "✅ API OK" || echo "❌ API Failed"

# Database
echo "🗄️ Database:"
python3 -c "
import os, sys
sys.path.append('../../..')
try:
    from database.shared.repositories import devices
    devices.get_all()
    print('✅ Database OK')
except Exception as e:
    print(f'❌ Database Error: {e}')
" 2>/dev/null

# MQTT
echo "📡 MQTT:"
timeout 5 mosquitto_pub -h ${MQTT_BROKER:-localhost} -t "test" -m "test" 2>/dev/null && echo "✅ MQTT OK" || echo "❌ MQTT Failed"

# Resources
echo "💻 Resources:"
echo "CPU: $(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')"
echo "Memory: $(ps -o pid,vsz,rss,comm -p $(pgrep -f "python.*main") | tail -1 | awk '{print $2/1024 "MB"}')"
echo "Disk: $(df -h . | tail -1 | awk '{print $5}')"
```

#### Log Analysis
```bash
#!/bin/bash
echo "📊 Log Analysis - Last Hour"
echo "============================"

LOG_FILE="/var/log/config-app/app.log"

# Errors
echo "❌ Errors:"
grep -i "error" $LOG_FILE | tail -5

# Warnings  
echo "⚠️ Warnings:"
grep -i "warning" $LOG_FILE | tail -5

# Recent Activity
echo "📈 Recent Activity:"
grep "$(date '+%Y-%m-%d %H')" $LOG_FILE | wc -l | awk '{print $1 " requests in last hour"}'

# Top Endpoints
echo "🔝 Top Endpoints:"
grep -o 'GET\|POST\|PUT\|PATCH\|DELETE /api/[^ ]*' $LOG_FILE | sort | uniq -c | sort -nr | head -5
```

## 🚨 Procedimento de Emergência

### Severidade Crítica (Sistema Fora do Ar)

#### 1. Primeiros 2 Minutos
```bash
# Verificar se processo está rodando
pgrep -f "python.*main" || echo "❌ Process not running"

# Restart rápido
docker restart config-app-backend
# OU
systemctl restart config-app

# Verificar se voltou
curl -f http://localhost:8081/api/health
```

#### 2. Minutos 3-5
```bash
# Verificar logs de erro
docker logs config-app-backend --since=10m | grep -i error

# Verificar recursos
docker stats config-app-backend --no-stream

# Verificar conectividade
ping -c 3 $DATABASE_HOST
ping -c 3 $MQTT_BROKER
```

#### 3. Minutos 6-10
```bash
# Se problema persistir, rollback para versão anterior
docker run -d --name config-app-backend-emergency \
  -p 8081:8081 \
  -e DATABASE_URL="$DATABASE_URL" \
  -e MQTT_BROKER="$MQTT_BROKER" \
  autocore/config-app-backend:last-known-good

# Notificar stakeholders
curl -X POST "$SLACK_WEBHOOK" \
  -H 'Content-type: application/json' \
  --data '{"text":"🚨 Config-App Backend em emergency mode"}'
```

### Severidade Alta (Funcionalidade Crítica Afetada)

#### 1. Identificar Escopo
```bash
# Testar endpoints críticos
curl -f http://localhost:8081/api/devices
curl -f http://localhost:8081/api/status  
curl -f http://localhost:8081/api/config/full/preview
```

#### 2. Solução Temporária
```bash
# Aumentar timeout se for problema de performance
export UVICORN_TIMEOUT=60

# Reduzir workers se for problema de recursos  
export UVICORN_WORKERS=1

# Restart com nova configuração
docker restart config-app-backend
```

## 📞 Escalação e Contatos

### Níveis de Suporte
| Nível | Tempo Resposta | Responsabilidade |
|-------|----------------|------------------|
| **L1** | 15 minutos | Operações básicas, restart |
| **L2** | 30 minutos | Análise de logs, troubleshooting |  
| **L3** | 1 hora | Debug de código, hotfix |

### Quando Escalar
- ✅ Sistema fora do ar por > 5 minutos
- ✅ Perda de dados detectada
- ✅ > 50% dos usuários afetados
- ✅ Problema de segurança identificado
- ✅ Solução não encontrada em 15 min (L1→L2)

### Contatos de Emergência
```bash
# Slack
curl -X POST "$SLACK_EMERGENCY_WEBHOOK" \
  -d '{"text":"🚨 CRITICAL: Config-App Backend Issue", "channel":"#ops-alerts"}'

# Email (se configurado)
echo "Config-App Backend emergency" | mail -s "CRITICAL ALERT" ops-team@company.com

# PagerDuty (se configurado)  
curl -X POST "https://events.pagerduty.com/generic/2010-04-15/create_event.json" \
  -H "Content-Type: application/json" \
  -d '{
    "service_key": "YOUR_SERVICE_KEY",
    "event_type": "trigger", 
    "incident_key": "config-app-backend-down",
    "description": "Config-App Backend is down"
  }'
```

## 📊 Monitoramento Preventivo

### Métricas Importantes
| Métrica | Normal | Atenção | Crítico |
|---------|--------|---------|---------|
| Response Time | < 200ms | > 500ms | > 2s |
| Error Rate | < 1% | > 5% | > 10% |
| CPU Usage | < 70% | > 80% | > 95% |
| Memory Usage | < 80% | > 90% | > 95% |
| Disk Usage | < 80% | > 85% | > 95% |

### Alertas Recomendados
```yaml
# Alertmanager config
groups:
- name: config-app-backend
  rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
    for: 2m
    annotations:
      summary: "Config-App Backend high error rate"
      
  - alert: HighLatency
    expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
    for: 5m
    annotations:
      summary: "Config-App Backend high latency"
```

## 🔧 Ferramentas de Debug

### Logs em Tempo Real
```bash
# Seguir logs com filtros
tail -f /var/log/config-app/app.log | grep -i --color error

# Logs estruturados com jq
docker logs config-app-backend -f | jq 'select(.level == "ERROR")'
```

### Debug de Performance
```bash
# Profile de CPU
py-spy top --pid $(pgrep -f "python.*main")

# Análise de memória
python -c "
import psutil
p = psutil.Process($(pgrep -f 'python.*main'))
print(f'Memory: {p.memory_info().rss / 1024 / 1024:.2f} MB')
print(f'CPU: {p.cpu_percent():.2f}%')
"
```

### Network Debug
```bash
# Conexões ativas
netstat -an | grep :8081

# Tráfego de rede
iftop -i any -P -n -N -b -t -s 10
```

## 📚 Recursos Úteis

### Documentação
- [FAQ](faq.md) - Perguntas frequentes
- [Debugging Guide](debugging-guide.md) - Guia detalhado de debug
- [Common Errors](common-errors.md) - Erros mais comuns

### Ferramentas Externas
- **Postman Collection**: [link] - Testes de API
- **Grafana Dashboard**: [link] - Métricas em tempo real
- **Log Aggregator**: [link] - Análise de logs

### Scripts Auxiliares
```bash
# Health check script
./scripts/health-check.sh

# Log analyzer
./scripts/analyze-logs.sh

# Performance report
./scripts/performance-report.sh
```

---

*Esta documentação é atualizada regularmente com novos problemas e soluções identificados.*