# Endpoints - Autenticação

Sistema de autenticação e autorização da API Config-App.

## 📋 Estado Atual

**⚠️ IMPORTANTE**: Atualmente a API opera **SEM AUTENTICAÇÃO** para facilitar desenvolvimento e integração com dispositivos ESP32.

Em ambiente de produção, implementar os endpoints descritos abaixo.

## 🔒 Endpoints de Autenticação (Planejados)

### `POST /api/auth/login`

Autentica usuário no sistema.

**Body (JSON):**
```json
{
  "username": "admin",
  "password": "senha_secreta"
}
```

**Resposta:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "refresh_token_here",
  "user": {
    "id": 1,
    "username": "admin",
    "roles": ["admin", "operator"]
  }
}
```

---

### `POST /api/auth/refresh`

Renova token de acesso usando refresh token.

**Body (JSON):**
```json
{
  "refresh_token": "refresh_token_here"
}
```

**Resposta:**
```json
{
  "access_token": "new_access_token",
  "token_type": "bearer",
  "expires_in": 3600
}
```

---

### `POST /api/auth/logout`

Invalida tokens do usuário.

**Headers:**
```http
Authorization: Bearer {access_token}
```

**Resposta:**
```json
{
  "message": "Logout realizado com sucesso"
}
```

---

### `GET /api/auth/me`

Retorna informações do usuário autenticado.

**Headers:**
```http
Authorization: Bearer {access_token}
```

**Resposta:**
```json
{
  "id": 1,
  "username": "admin",
  "email": "admin@autocore.com",
  "roles": ["admin", "operator"],
  "permissions": [
    "devices:read",
    "devices:write",
    "screens:read",
    "screens:write",
    "relays:control"
  ],
  "last_login": "2025-01-22T10:00:00Z"
}
```

## 🔐 Autenticação de Dispositivos ESP32

### `POST /api/auth/device`

Autentica dispositivo ESP32 no sistema.

**Body (JSON):**
```json
{
  "device_uuid": "esp32-001",
  "mac_address": "AA:BB:CC:DD:EE:FF",
  "device_secret": "secret_hash_from_device"
}
```

**Resposta:**
```json
{
  "device_token": "device_jwt_token",
  "token_type": "bearer",
  "expires_in": 86400,
  "mqtt_credentials": {
    "username": "esp32-001",
    "password": "mqtt_password"
  }
}
```

---

### `POST /api/auth/device/register`

Registra novo dispositivo no sistema (auto-registro).

**Body (JSON):**
```json
{
  "device_uuid": "esp32-002",
  "device_name": "Novo Display",
  "device_type": "esp32_display",
  "mac_address": "BB:CC:DD:EE:FF:AA",
  "hardware_info": {
    "firmware_version": "1.2.0",
    "hardware_version": "v2.1",
    "memory_mb": 4,
    "flash_mb": 16
  }
}
```

**Resposta:**
```json
{
  "device_id": 5,
  "device_token": "new_device_jwt",
  "registration_status": "approved",
  "message": "Dispositivo registrado com sucesso"
}
```

## 👥 Níveis de Acesso

### Administrador (admin)
- Acesso completo a todas as funcionalidades
- Gerenciamento de usuários
- Configurações globais do sistema
- Logs e auditoria

### Operador (operator)
- Controle de dispositivos
- Configuração de telas
- Monitoramento de telemetria
- Controle de relés

### Visualizador (viewer)
- Apenas leitura
- Visualização de dados
- Acesso a dashboards
- Sem permissões de controle

### Dispositivo (device)
- Auto-registro
- Atualização de status
- Envio de telemetria
- Recebimento de comandos

## 🔑 Estrutura do JWT

### Token de Usuário
```json
{
  "sub": "user_id",
  "username": "admin",
  "roles": ["admin"],
  "permissions": ["devices:write"],
  "iat": 1642867200,
  "exp": 1642870800
}
```

### Token de Dispositivo
```json
{
  "sub": "device_id",
  "device_uuid": "esp32-001",
  "device_type": "esp32_display",
  "permissions": ["telemetry:send", "status:update"],
  "iat": 1642867200,
  "exp": 1643953200
}
```

## 🛡️ Middleware de Segurança

### Rate Limiting
- **Usuários**: 100 requests/minuto
- **Dispositivos**: 1000 requests/minuto
- **Auth endpoints**: 5 tentativas/minuto

### CORS Policy
```python
CORS_ORIGINS = [
    "http://localhost:3000",  # Frontend dev
    "https://autocore.local", # Produção local
    "https://app.autocore.com" # Produção
]
```

### Headers de Segurança
```http
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000
```

## 🔒 Implementação Recomendada

### Dependências
```python
# Adicionar ao requirements.txt
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
bcrypt==4.1.1
```

### Configuração JWT
```python
SECRET_KEY = os.getenv("JWT_SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60
REFRESH_TOKEN_EXPIRE_DAYS = 30
```

### Middleware de Autenticação
```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer

security = HTTPBearer()

async def get_current_user(token: str = Depends(security)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
        if username is None:
            raise HTTPException(401, "Token inválido")
        return username
    except jwt.JWTError:
        raise HTTPException(401, "Token inválido")
```

## 📝 TODO - Implementação

- [ ] Tabelas de usuários e permissões
- [ ] Hash de senhas com bcrypt
- [ ] Geração e validação de JWT
- [ ] Middleware de autenticação
- [ ] Rate limiting por usuário
- [ ] Sistema de refresh tokens
- [ ] Logs de auditoria
- [ ] Integração com LDAP/OAuth (opcional)

## ⚠️ Considerações de Segurança

1. **Senhas**: Sempre hash com bcrypt (salt rounds >= 12)
2. **Tokens**: Usar segredos criptograficamente seguros
3. **HTTPS**: Obrigatório em produção
4. **Refresh Tokens**: Armazenar de forma segura
5. **Device Secrets**: Únicos por dispositivo
6. **Logs**: Registrar tentativas de login
7. **Timeout**: Sessões com tempo limitado