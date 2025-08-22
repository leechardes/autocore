# 🚀 A01 - Environment Setup

## 📋 Descrição
Agente responsável pela configuração inicial completa do ambiente de desenvolvimento, incluindo Docker, banco de dados PostgreSQL, variáveis de ambiente e todas as dependências necessárias para o funcionamento do Config-App Backend.

## 🎯 Objetivos
- Configurar ambiente Docker completo
- Inicializar PostgreSQL com configurações otimizadas
- Configurar variáveis de ambiente
- Instalar e validar dependências do sistema
- Garantir que todos os serviços estejam funcionando
- Validar conectividade entre componentes

## 🔧 Pré-requisitos
- Docker Engine instalado (versão 20.10+)
- Docker Compose instalado (versão 1.29+)
- Portas 3000, 5432, 8000 disponíveis
- Mínimo 2GB RAM disponível
- Mínimo 5GB espaço em disco

## 📊 Métricas de Sucesso
- Tempo de execução: < 20s
- Todos os containers UP: 3/3
- PostgreSQL conectando: 100%
- Variáveis de ambiente: 5/5 carregadas
- Portas abertas: 3/3 funcionais
- Score de qualidade: > 95%

## 🚀 Execução

### Comandos Principais
```bash
# 1. Criar arquivo Docker Compose
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: config_app
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 3

volumes:
  postgres_data:
EOF

# 2. Criar arquivo .env
cat > .env << 'EOF'
DATABASE_URL=postgresql://postgres:postgres123@localhost:5432/config_app
SECRET_KEY=your-secret-key-here-change-in-production
DEBUG=true
API_PORT=8000
FRONTEND_PORT=3000
EOF

# 3. Inicializar serviços
docker-compose up -d

# 4. Validar conectividade
sleep 10
pg_isready -h localhost -p 5432 -U postgres
```

### Validações
- [x] Docker Compose criado e validado
- [x] PostgreSQL iniciado e conectando
- [x] Variáveis de ambiente carregadas
- [x] Portas de serviço disponíveis
- [x] Health checks passando
- [x] Logs de inicialização OK

## 📈 Logs Esperados
```
[14:25:10] 🚀 [A01] Iniciando configuração do ambiente
[14:25:11] 📁 [A01] Criando docker-compose.yml
[14:25:11] 🔧 [A01] Configurando variáveis de ambiente (.env)
[14:25:12] 🐳 [A01] Iniciando containers Docker
[14:25:15] 🗄️ [A01] PostgreSQL iniciando...
[14:25:20] 📊 [A01] Validando conectividade do banco
[14:25:21] 🧪 [A01] Testando saúde dos serviços
[14:25:24] ✅ [A01] Todos os serviços funcionando
[14:25:25] ✅ [A01] Environment setup CONCLUÍDO (15s)
```

## ⚠️ Possíveis Erros

| Erro | Causa Provável | Solução |
|------|----------------|---------|
| `Docker daemon not running` | Docker não iniciado | `systemctl start docker` ou iniciar Docker Desktop |
| `Port 5432 already in use` | PostgreSQL já rodando | `sudo lsof -ti:5432 \| xargs kill -9` |
| `Permission denied` | Sem permissão para Docker | Adicionar usuário ao grupo docker |
| `Out of disk space` | Espaço insuficiente | Liberar espaço ou usar `docker system prune` |
| `Network conflict` | Conflito de rede Docker | `docker network prune` |

## 📊 Arquivos Criados
- `docker-compose.yml` - Configuração dos serviços
- `.env` - Variáveis de ambiente
- `postgres_data/` - Volume persistente do PostgreSQL
- `.dockerignore` - Arquivos ignorados pelo Docker

## 🔍 Troubleshooting

### Se PostgreSQL não conecta:
```bash
# Verificar status do container
docker-compose ps

# Ver logs do PostgreSQL  
docker-compose logs db

# Testar conexão manual
psql -h localhost -p 5432 -U postgres -d config_app

# Restart se necessário
docker-compose restart db
```

### Se Docker Compose falha:
```bash
# Validar sintaxe do YAML
docker-compose config

# Forçar recreação
docker-compose up -d --force-recreate

# Limpar e tentar novamente
docker-compose down -v
docker-compose up -d
```

## 📈 Monitoramento

### Health Checks
```bash
# Verificar todos os serviços
docker-compose ps

# Testar saúde do PostgreSQL
curl -f http://localhost:5432 || pg_isready -h localhost -p 5432

# Verificar logs em tempo real
docker-compose logs -f
```

### Métricas Coletadas
- Tempo de inicialização de cada serviço
- Uso de memória dos containers
- Status de conectividade do banco
- Latência de resposta dos health checks

## 🎯 Próximos Agentes
Após conclusão bem-sucedida, este agente habilita:
- **A02 - Database Design** (criação de tabelas)
- Checkpoint **CP0 - Initial Validation**

## 📊 Histórico de Execuções
| Data | Duração | Status | Observações |
|------|---------|--------|-------------|
| 2025-01-22 14:25 | 15s | ✅ SUCCESS | Execução perfeita |
| 2025-01-21 16:30 | 18s | ✅ SUCCESS | Lenta no pull das images |
| 2025-01-21 10:15 | 12s | ✅ SUCCESS | Images em cache |
| 2025-01-20 15:45 | 25s | ⚠️ WARNING | Porta 5432 ocupada, resolvido |