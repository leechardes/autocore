# 🔒 Configurações de Segurança - AutoCore

## 📋 Checklist de Segurança

### ✅ Secrets Configurados

| Serviço | Variável | Status | Observação |
|---------|----------|--------|------------|
| **Backend** | SECRET_KEY | ✅ Segura | Hash 64 caracteres hex |
| **Backend** | ADMIN_PASSWORD | ✅ Segura | Base64 16 bytes |
| **Gateway** | SECRET_KEY | ✅ Segura | Hash 64 caracteres hex |
| **MQTT** | MQTT_PASSWORD | ✅ Configurada | Senha forte personalizada |

### 🔐 Variáveis de Ambiente Sensíveis

#### Backend (`config-app/backend/.env`)
```env
SECRET_KEY=<hash-64-hex>           # JWT signing
ADMIN_PASSWORD=<base64-string>     # Admin inicial
MQTT_PASSWORD=<sua-senha>          # Autenticação MQTT
```

#### Gateway (`gateway/.env`)
```env
SECRET_KEY=<hash-64-hex>           # Autenticação interna
MQTT_PASSWORD=<sua-senha>          # Autenticação MQTT
```

#### Frontend (`config-app/frontend/.env`)
```env
# Frontend não deve ter secrets!
# Apenas URLs públicas
```

## 🛡️ Boas Práticas Implementadas

### 1. Geração de Secrets
```bash
# Gerar SECRET_KEY segura (64 caracteres hex)
openssl rand -hex 32

# Gerar senha segura (base64)
openssl rand -base64 16

# Gerar senha alfanumérica
openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
```

### 2. Arquivos .env
- ✅ `.env` no `.gitignore`
- ✅ `.env.example` com placeholders
- ✅ Sem senhas reais em exemplos
- ✅ Comentários explicativos

### 3. Placeholders Seguros
```env
# CORRETO - .env.example
SECRET_KEY=SERA_GERADA_AUTOMATICAMENTE_NO_DEPLOY
MQTT_PASSWORD=SUA_SENHA_AQUI

# ERRADO - .env.example
SECRET_KEY=your-secret-key-here
MQTT_PASSWORD=admin123
```

## 🚨 Avisos de Segurança

### ⚠️ NUNCA faça commit de:
- Arquivos `.env` com dados reais
- Senhas em texto claro no código
- Tokens de API válidos
- Chaves privadas SSH

### ⚠️ SEMPRE:
- Use variáveis de ambiente para secrets
- Gere novos secrets para cada ambiente
- Rotacione secrets periodicamente
- Use senhas fortes (min 16 caracteres)

## 🔄 Rotação de Secrets

### Quando rotacionar:
- A cada 90 dias (recomendado)
- Após vazamento suspeito
- Mudança de equipe
- Deploy em produção

### Como rotacionar:
1. Gerar novo secret
2. Atualizar `.env` local
3. Deploy gradual
4. Remover secret antigo

## 🏭 Deploy Seguro

### Desenvolvimento
```bash
# Copiar .env.example e configurar
cp .env.example .env
# Editar com valores seguros
nano .env
```

### Produção (Raspberry Pi)
```bash
# Secrets gerados automaticamente no deploy
./deploy/deploy_to_raspberry.sh

# Ou manualmente:
ssh pi@autocore.local
openssl rand -hex 32 > /tmp/secret.txt
# Configurar no .env
```

## 📊 Níveis de Segurança

### 🟢 Alto (Produção)
- Secrets únicos por instalação
- HTTPS/TLS habilitado
- Firewall configurado
- Autenticação em todos serviços

### 🟡 Médio (Staging)
- Secrets diferentes de produção
- Rede isolada
- Logs habilitados

### 🔴 Baixo (Desenvolvimento)
- Secrets locais apenas
- Sem dados sensíveis reais
- Ambiente isolado

## 🔍 Auditoria

### Verificar configurações:
```bash
# Listar variáveis sensíveis (sem mostrar valores)
grep -E "SECRET|KEY|TOKEN|PASSWORD" .env | cut -d= -f1

# Verificar se .env está no git
git ls-files | grep "\.env$"

# Buscar senhas hardcoded
grep -r "password\|secret" --include="*.py" --include="*.js"
```

## 📝 Registro de Mudanças

| Data | Mudança | Responsável |
|------|---------|------------|
| 2025-01-19 | Secrets iniciais gerados | Sistema |
| 2025-01-19 | Removidas senhas dos .example | Sistema |
| 2025-01-19 | Documentação criada | Sistema |

---

**IMPORTANTE**: Este documento contém informações sensíveis sobre a segurança do sistema. Mantenha-o atualizado mas não exponha detalhes específicos de produção.

**Última atualização**: Janeiro 2025  
**Versão**: 1.0.0