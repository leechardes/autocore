# Guias de Deployment

Documentação para implantação do Config-App Backend em diferentes ambientes.

## 📋 Índice

### 🏗️ Infraestrutura
- [Configuração Docker](docker-setup.md) - Containerização completa
- [Deploy com Kubernetes](kubernetes.md) - Orquestração de containers
- [Variáveis de Ambiente](environment-variables.md) - Configurações por ambiente

### ✅ Validação
- [Checklist de Produção](production-checklist.md) - Verificações antes do deploy

## 🎯 Ambientes Suportados

### 🔧 Desenvolvimento Local
- **Propósito**: Desenvolvimento e testes
- **Banco**: SQLite local
- **MQTT**: Broker local ou público
- **Logs**: Debug completo
- **Performance**: Não otimizada

### 🧪 Staging/Homologação
- **Propósito**: Testes de integração
- **Banco**: PostgreSQL dedicado
- **MQTT**: Broker dedicado
- **Logs**: Info + errors
- **Performance**: Otimizada para testes

### 🚀 Produção
- **Propósito**: Sistema em operação
- **Banco**: PostgreSQL com backup
- **MQTT**: Cluster MQTT
- **Logs**: Apenas errors e métricas
- **Performance**: Máxima otimização

## 🏗️ Arquitetura de Deploy

### Componentes Principais
```
┌─────────────────────────────────────────────────────────┐
│                    Load Balancer                        │
│                 (nginx/traefik)                        │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│                Config-App API                          │
│            (FastAPI + Uvicorn)                        │
│                3 réplicas                             │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│              Banco de Dados                            │
│              PostgreSQL                                │
│           (compartilhado)                             │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                 MQTT Broker                            │
│              Eclipse Mosquitto                         │
│                 Cluster                               │
└─────────────────────────────────────────────────────────┘
```

## 🐳 Docker

### Dockerfile de Produção
```dockerfile
FROM python:3.10-slim

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Criar usuário não-root
RUN adduser --disabled-password --gecos '' appuser

WORKDIR /app

# Copiar e instalar dependências
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código
COPY . .

# Mudar para usuário não-root
USER appuser

# Expor porta
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8081/api/health || exit 1

# Comando padrão
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8081", "--workers", "4"]
```

### Docker Compose para Desenvolvimento
```yaml
version: '3.8'

services:
  config-app:
    build: .
    ports:
      - "8081:8081"
    environment:
      - ENV=development
      - DATABASE_URL=postgresql://user:pass@postgres:5432/autocore
      - MQTT_BROKER=mosquitto
    depends_on:
      - postgres
      - mosquitto
    volumes:
      - .:/app
    command: uvicorn main:app --host 0.0.0.0 --port 8081 --reload

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_DB=autocore
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  mosquitto:
    image: eclipse-mosquitto:2.0
    ports:
      - "1883:1883"
      - "9001:9001"
    volumes:
      - mosquitto_data:/mosquitto/data
      - mosquitto_logs:/mosquitto/log

volumes:
  postgres_data:
  mosquitto_data:
  mosquitto_logs:
```

## ☸️ Kubernetes

### Deployment Básico
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: config-app-backend
  labels:
    app: config-app-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: config-app-backend
  template:
    metadata:
      labels:
        app: config-app-backend
    spec:
      containers:
      - name: config-app
        image: autocore/config-app-backend:latest
        ports:
        - containerPort: 8081
        env:
        - name: ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: url
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8081
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 8081
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Service e Ingress
```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: config-app-service
spec:
  selector:
    app: config-app-backend
  ports:
  - port: 80
    targetPort: 8081
  type: ClusterIP

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: config-app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: api.autocore.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: config-app-service
            port:
              number: 80
```

## 🔐 Configurações de Segurança

### Variáveis Sensíveis
```bash
# Usar Kubernetes Secrets
kubectl create secret generic database-secret \
  --from-literal=url="postgresql://user:pass@postgres:5432/autocore"

kubectl create secret generic mqtt-secret \
  --from-literal=username="mqtt_user" \
  --from-literal=password="mqtt_pass"
```

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: config-app-netpol
spec:
  podSelector:
    matchLabels:
      app: config-app-backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: nginx-ingress
    ports:
    - protocol: TCP
      port: 8081
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
```

## 📊 Monitoramento

### Health Checks
```python
# Endpoint de health check detalhado
@app.get("/api/health/detailed")
async def detailed_health():
    return {
        "status": "healthy",
        "version": "2.0.0",
        "timestamp": datetime.now(),
        "checks": {
            "database": check_database_connection(),
            "mqtt": check_mqtt_connection(),
            "memory": get_memory_usage(),
            "disk": get_disk_usage()
        }
    }
```

### Métricas Prometheus
```python
from prometheus_client import Counter, Histogram, generate_latest

# Métricas customizadas
request_count = Counter('http_requests_total', 'Total requests', ['method', 'endpoint'])
request_duration = Histogram('http_request_duration_seconds', 'Request duration')

@app.middleware("http")
async def add_metrics(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    duration = time.time() - start_time
    
    request_count.labels(request.method, request.url.path).inc()
    request_duration.observe(duration)
    return response

@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type="text/plain")
```

## 🔄 Estratégias de Deploy

### Blue-Green Deployment
1. **Deploy na versão Green** (inativa)
2. **Executar testes** na versão Green
3. **Switchar tráfego** de Blue para Green
4. **Monitorar** por período determinado
5. **Rollback** para Blue se necessário

### Rolling Updates
```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
```

### Canary Releases
```yaml
# Usar Istio ou Argo Rollouts
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: config-app-rollout
spec:
  strategy:
    canary:
      steps:
      - setWeight: 10
      - pause: {duration: 2m}
      - setWeight: 50
      - pause: {duration: 5m}
      - setWeight: 100
```

## 📋 Checklist de Deploy

### Pré-Deploy
- [ ] Código revisado e aprovado
- [ ] Testes unitários passando (100%)
- [ ] Testes de integração passando
- [ ] Documentação atualizada
- [ ] Variáveis de ambiente configuradas
- [ ] Secrets criados no ambiente
- [ ] Backup do banco de dados realizado

### Deploy
- [ ] Build da imagem Docker bem-sucedido
- [ ] Push para registry realizado
- [ ] Deploy executado (Blue-Green ou Rolling)
- [ ] Health checks passando
- [ ] Métricas normais
- [ ] Logs sem erros críticos

### Pós-Deploy
- [ ] Testes de smoke executados
- [ ] Funcionalidades críticas testadas
- [ ] Performance dentro do esperado
- [ ] Monitoring configurado
- [ ] Alertas funcionando
- [ ] Documentação de rollback preparada

## 🚨 Rollback

### Processo de Rollback
```bash
# Kubernetes
kubectl rollout undo deployment/config-app-backend

# Docker Compose
docker-compose up -d --scale config-app=0
docker-compose up -d config-app:previous-version

# Verificar status
kubectl rollout status deployment/config-app-backend
```

### Rollback Automático
```yaml
# Configurar com Argo CD
apiVersion: argoproj.io/v1alpha1
kind: Application
spec:
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    retry:
      limit: 3
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

## 📝 Logs e Auditoria

### Configuração de Logs
```python
import structlog

# Configurar logs estruturados
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.stdlib.BoundLogger,
    logger_factory=structlog.stdlib.LoggerFactory(),
    cache_logger_on_first_use=True,
)
```

### Agregação de Logs
```yaml
# Fluent Bit para Elasticsearch
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         1
        Log_Level     info
        Daemon        off
        
    [INPUT]
        Name              tail
        Tag               config-app.*
        Path              /var/log/containers/*config-app*.log
        Parser            docker
        
    [OUTPUT]
        Name              es
        Match             config-app.*
        Host              elasticsearch.logging
        Port              9200
        Index             autocore-logs
```

## 🔧 Troubleshooting

### Problemas Comuns
1. **Container não inicia**: Verificar logs com `docker logs`
2. **Banco não conecta**: Validar string de conexão
3. **MQTT falha**: Verificar conectividade de rede
4. **High CPU**: Revisar workers e configurações
5. **Memory leak**: Analisar com profilers

### Comandos Úteis
```bash
# Debug do container
docker exec -it container_id bash
kubectl exec -it pod_name -- bash

# Logs em tempo real
docker logs -f container_id
kubectl logs -f deployment/config-app-backend

# Recursos do pod
kubectl top pods
kubectl describe pod pod_name

# Network debug
kubectl exec pod_name -- nslookup postgres
kubectl exec pod_name -- telnet postgres 5432
```

---

*Para deployment específico, consulte os guias detalhados em cada seção.*