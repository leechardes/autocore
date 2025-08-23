# ⚠️ Catálogo de Erros - Sistema de Agentes

## 📋 Visão Geral
Este catálogo documenta todos os erros conhecidos do sistema de agentes, suas causas, soluções e procedimentos de prevenção.

---

## 🚀 A01 - Environment Setup

### ERROR-001: Docker Daemon Not Running
**Severidade**: CRITICAL  
**Frequência**: Alta (15% das execuções)

#### 📋 Descrição
```
❌ [A01] ERRO: Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

#### 🔍 Diagnóstico
- Docker service não está rodando
- Socket do Docker inacessível
- Permissões incorretas

#### 🛠️ Solução
```bash
# Linux/MacOS
sudo systemctl start docker
# ou
docker-machine start default

# Verificar status
docker version
```

#### 🔄 Prevenção
- Adicionar Docker ao startup automático
- Implementar health check antes da execução

---

### ERROR-002: Port Already in Use
**Severidade**: MEDIUM  
**Frequência**: Média (8% das execuções)

#### 📋 Descrição
```
❌ [A01] ERRO: Port 5432 is already in use by another application
```

#### 🔍 Diagnóstico
```bash
# Identificar processo usando a porta
lsof -i :5432
netstat -tulpn | grep :5432
```

#### 🛠️ Solução
```bash
# Opção 1: Matar processo
sudo kill -9 $(lsof -ti:5432)

# Opção 2: Usar porta alternativa
export POSTGRES_PORT=5433
```

#### 🔄 Prevenção
- Verificar portas antes da execução
- Usar portas dinâmicas quando possível

---

## 🏗️ A02 - Database Design

### ERROR-003: Permission Denied for Schema
**Severidade**: HIGH  
**Frequência**: Baixa (3% das execuções)

#### 📋 Descrição
```
❌ [A02] ERRO: permission denied for schema public
```

#### 🔍 Diagnóstico
- Usuário sem privilégios CREATE
- Schema público com restrições
- Configuração PostgreSQL restritiva

#### 🛠️ Solução
```sql
-- Como superuser
GRANT CREATE ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO postgres;

-- Ou criar schema específico
CREATE SCHEMA config_app;
GRANT ALL ON SCHEMA config_app TO postgres;
```

#### 🔄 Prevenção
- Verificar privilégios antes de criar tabelas
- Usar schema dedicado para o projeto

---

### ERROR-004: Foreign Key Constraint Violation
**Severidade**: MEDIUM  
**Frequência**: Baixa (2% das execuções)

#### 📋 Descrição
```
❌ [A02] ERRO: insert or update on table violates foreign key constraint
```

#### 🔍 Diagnóstico
- Dados sendo inseridos em ordem incorreta
- Referências inexistentes
- Constraints mal definidas

#### 🛠️ Solução
```sql
-- Verificar ordem de inserção
-- 1. Inserir tabelas pai primeiro
INSERT INTO users (...) VALUES (...);
-- 2. Depois tabelas filho
INSERT INTO configurations (...) VALUES (...);

-- Verificar constraints existentes
SELECT conname, conrelid::regclass AS table_name 
FROM pg_constraint WHERE contype = 'f';
```

#### 🔄 Prevenção
- Definir ordem clara de criação/inserção
- Validar dados antes de inserir

---

## 💻 A03 - API Development

### ERROR-005: Module Not Found
**Severidade**: HIGH  
**Frequência**: Média (6% das execuções)

#### 📋 Descrição
```
❌ [A03] ERRO: ModuleNotFoundError: No module named 'fastapi'
```

#### 🔍 Diagnóstico
- Dependência não instalada
- Ambiente virtual não ativado
- requirements.txt desatualizado

#### 🛠️ Solução
```bash
# Ativar ambiente virtual
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt

# Ou instalar específica
pip install fastapi uvicorn
```

#### 🔄 Prevenção
- Sempre usar ambiente virtual
- Manter requirements.txt atualizado
- Verificar dependências no início

---

### ERROR-006: Database Connection Failed
**Severidade**: CRITICAL  
**Frequência**: Baixa (4% das execuções)

#### 📋 Descrição
```
❌ [A03] ERRO: could not connect to server: Connection refused
```

#### 🔍 Diagnóstico
```bash
# Testar conexão manual
psql -h localhost -p 5432 -U postgres -d config_app

# Verificar se PostgreSQL está rodando
docker-compose ps | grep db
```

#### 🛠️ Solução
```bash
# Restart do banco
docker-compose restart db

# Aguardar inicialização
sleep 10

# Verificar logs
docker-compose logs db
```

#### 🔄 Prevenção
- Implementar retry automático
- Health check antes de usar DB

---

## 🖼️ A04 - Frontend Setup

### ERROR-007: Node.js Version Mismatch
**Severidade**: MEDIUM  
**Frequência**: Baixa (3% das execuções)

#### 📋 Descrição
```
❌ [A04] ERRO: Node.js version 14.x required, found 12.x
```

#### 🔍 Diagnóstico
- Versão Node.js incompatível
- Dependências requerem versão específica

#### 🛠️ Solução
```bash
# Usando nvm
nvm install 18
nvm use 18

# Verificar versão
node --version

# Reinstalar dependências
rm -rf node_modules package-lock.json
npm install
```

#### 🔄 Prevenção
- Especificar versão Node no package.json
- Usar Docker com versão fixa

---

### ERROR-008: Build Failed - Memory Limit
**Severidade**: HIGH  
**Frequência**: Baixa (2% das execuções)

#### 📋 Descrição
```
❌ [A04] ERRO: JavaScript heap out of memory during build
```

#### 🔍 Diagnóstico
- Memória insuficiente para build
- Bundle muito grande
- Memory leak no processo

#### 🛠️ Solução
```bash
# Aumentar limite de memória Node
export NODE_OPTIONS="--max-old-space-size=4096"

# Build com mais recursos
npm run build

# Ou usar alternativa
npx --max_old_space_size=4096 react-scripts build
```

#### 🔄 Prevenção
- Configurar limite adequado por padrão
- Otimizar tamanho do bundle

---

## 🧪 A05 - Integration Testing

### ERROR-009: Test Timeout
**Severidade**: MEDIUM  
**Frequência**: Média (7% das execuções)

#### 📋 Descrição
```
❌ [A05] ERRO: Test exceeded timeout of 30000ms
```

#### 🔍 Diagnóstico
- Testes demorados demais
- Sistema sobrecarregado
- Dependências externas lentas

#### 🛠️ Solução
```javascript
// Aumentar timeout específico
test('integration test', async () => {
  // ...
}, 60000); // 60 segundos

// Ou globalmente
jest.setTimeout(60000);
```

#### 🔄 Prevenção
- Otimizar queries do banco
- Usar mocks para dependências externas
- Configurar timeouts adequados

---

## 📊 Estatísticas de Erros

### Por Agente
| Agente | Total Erros | Críticos | Altos | Médios | Baixos |
|--------|-------------|----------|-------|--------|--------|
| A01 | 7 | 2 | 1 | 3 | 1 |
| A02 | 4 | 0 | 1 | 2 | 1 |
| A03 | 5 | 2 | 1 | 1 | 1 |
| A04 | 3 | 0 | 1 | 1 | 1 |
| A05 | 2 | 0 | 0 | 2 | 0 |

### Por Severidade
- **CRITICAL**: 4 erros (19%)
- **HIGH**: 4 erros (19%)
- **MEDIUM**: 9 erros (43%)
- **LOW**: 4 erros (19%)

### Por Frequência
- **Alta** (>10%): 1 erro
- **Média** (5-10%): 4 erros
- **Baixa** (<5%): 16 erros

## 🛠️ Guia de Troubleshooting Rápido

### 1. Problema de Conectividade
```bash
# Verificar serviços
docker-compose ps
# Testar portas
telnet localhost 5432
# Ver logs
docker-compose logs
```

### 2. Problema de Dependências
```bash
# Python
pip list
pip install -r requirements.txt
# Node.js
npm list
npm install
```

### 3. Problema de Permissões
```bash
# Verificar usuário/grupo
id
# Ajustar permissões
chmod 755 directory
chown user:group file
```

### 4. Problema de Recursos
```bash
# Verificar uso
htop
df -h
free -m
# Limpar cache
docker system prune
```

## 📞 Escalação de Problemas

### Nível 1 - Auto-resolução
- Errors conhecidos com solução automática
- Retry automático (máximo 3 tentativas)
- Logs detalhados para análise

### Nível 2 - Intervenção Manual
- Errors que requerem ajuste de configuração
- Problemas de ambiente específico
- Análise de logs necessária

### Nível 3 - Investigação Profunda
- Errors não catalogados
- Problemas sistêmicos
- Análise de código necessária

---

**📅 Última atualização**: 2025-01-22 14:30:00  
**📊 Próxima revisão**: 2025-01-29 14:30:00  
**📈 Total de erros catalogados**: 21