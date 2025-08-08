# 🤖 Instruções para Claude - Config-App Backend

## 🎯 Visão Geral

O Backend do Config-App é uma API FastAPI que serve como interface entre o frontend e o database centralizado do AutoCore. **NÃO possui banco próprio** - utiliza os repositories do projeto database.

## 🏗️ Arquitetura

### Integração com Database

```python
# IMPORTANTE: Database é compartilhado
sys.path.append("../../database")
from shared.repositories import devices, relays, telemetry, events, config
```

**Nunca:**
- ❌ Criar models SQLAlchemy no backend
- ❌ Fazer migrations no backend
- ❌ Conectar diretamente ao SQLite
- ❌ Duplicar lógica dos repositories

**Sempre:**
- ✅ Usar repositories do database
- ✅ Validar com Pydantic antes de enviar aos repositories
- ✅ Tratar exceções dos repositories
- ✅ Registrar eventos importantes

## 📁 Estrutura

```
backend/
├── main.py              # Aplicação principal FastAPI
├── requirements.txt     # Dependências Python
├── .env.example        # Variáveis de ambiente
├── api/                # Endpoints organizados (futuro)
│   ├── __init__.py
│   ├── devices.py
│   ├── relays.py
│   ├── screens.py
│   └── auth.py
├── models/             # Modelos Pydantic APENAS
│   ├── __init__.py
│   ├── device.py
│   ├── relay.py
│   └── screen.py
├── services/           # Lógica de negócio
│   └── config_generator.py
└── tests/             # Testes unitários
```

## 🛠️ Stack

- **FastAPI** - Framework web
- **Pydantic** - Validação de dados (NÃO confundir com SQLAlchemy models!)
- **Uvicorn** - Servidor ASGI
- **python-jose** - JWT para autenticação
- **passlib** - Hash de senhas

## 📝 Padrões de Código

### Endpoints

```python
# PADRÃO: Sempre validar entrada e saída
@app.get("/api/devices", response_model=List[DeviceResponse])
async def get_devices():
    try:
        # Chama repository
        all_devices = devices.get_all()
        
        # Converte para Pydantic
        return [DeviceResponse.from_orm(d) for d in all_devices]
    except Exception as e:
        # Log e retorna erro apropriado
        raise HTTPException(status_code=500, detail=str(e))
```

### Modelos Pydantic

```python
# models/device.py
class DeviceBase(BaseModel):
    """Base - campos comuns"""
    uuid: str
    name: str
    type: str

class DeviceCreate(DeviceBase):
    """Criação - campos obrigatórios"""
    pass

class DeviceUpdate(BaseModel):
    """Update - todos opcionais"""
    name: Optional[str] = None
    ip_address: Optional[str] = None

class DeviceResponse(DeviceBase):
    """Response - inclui campos do banco"""
    id: int
    status: str
    created_at: datetime
    
    class Config:
        from_attributes = True  # Para converter do ORM
```

### Tratamento de Erros

```python
# SEMPRE tratar erros específicos
try:
    device = devices.get_by_id(device_id)
    if not device:
        raise HTTPException(404, "Dispositivo não encontrado")
    # ... lógica
except HTTPException:
    raise  # Re-raise HTTP exceptions
except Exception as e:
    # Log erro completo
    logger.error(f"Erro inesperado: {e}", exc_info=True)
    raise HTTPException(500, "Erro interno do servidor")
```

## 🔐 Autenticação

### JWT Flow

```python
# TODO: Implementar após MVP
# 1. Login endpoint retorna token
# 2. Token enviado no header Authorization
# 3. Dependência verifica token
# 4. User injetado nos endpoints

async def get_current_user(token: str = Depends(oauth2_scheme)):
    # Verificar token
    # Retornar user
    pass
```

## 🚀 Performance

### Otimizações para Raspberry Pi

1. **Connection Pooling** - Já gerenciado pelo database
2. **Async Operations** - Usar async/await sempre
3. **Caching** - Cache responses quando possível
4. **Pagination** - Limitar resultados grandes
5. **Lazy Loading** - Não carregar dados desnecessários

### Exemplo de Paginação

```python
@app.get("/api/telemetry/{device_id}")
async def get_telemetry(
    device_id: int,
    skip: int = 0,
    limit: int = Query(default=100, le=1000)
):
    data = telemetry.get_latest(device_id, limit, skip)
    return data
```

## 🧪 Testes

### Estrutura de Testes

```python
# tests/test_devices.py
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_get_devices():
    response = client.get("/api/devices")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
```

### Mocking Repositories

```python
# Para testes unitários, mock os repositories
from unittest.mock import patch

@patch('main.devices.get_all')
def test_devices_endpoint(mock_get_all):
    mock_get_all.return_value = [...]
    # teste
```

## 🔧 Desenvolvimento

### Adicionar Novo Endpoint

1. **Criar modelos Pydantic** em `models/`
2. **Implementar endpoint** em `main.py` ou `api/`
3. **Documentar** com docstrings
4. **Testar** com pytest
5. **Registrar eventos** importantes

### Config Generator

```python
# services/config_generator.py
def generate_esp32_config(device_uuid: str) -> dict:
    """
    Gera configuração JSON para ESP32
    Baseado no tipo do dispositivo
    """
    device = devices.get_by_uuid(device_uuid)
    
    if device.type == "esp32_relay":
        # Buscar canais de relé
        # Montar config
        pass
    elif device.type == "esp32_display":
        # Buscar screens
        # Montar config
        pass
    
    return config_dict
```

## 📊 Endpoints Principais

### System
- `GET /` - Health check
- `GET /api/status` - Status detalhado

### Devices
- `GET /api/devices` - Lista todos
- `GET /api/devices/{id}` - Busca por ID
- `POST /api/devices` - Cria novo
- `PATCH /api/devices/{id}` - Atualiza
- `DELETE /api/devices/{id}` - Remove (soft)

### Relays
- `GET /api/relays/boards` - Lista placas
- `GET /api/relays/channels` - Lista canais
- `POST /api/relays/channels/{id}/toggle` - Alterna
- `PATCH /api/relays/channels/{id}/state` - Define estado

### Screens & UI
- `GET /api/screens` - Lista telas
- `GET /api/screens/{id}/items` - Itens da tela
- `GET /api/themes` - Lista temas
- `GET /api/themes/default` - Tema padrão

### Config Generator
- `GET /api/config/generate/{device_uuid}` - Gera config JSON

## 🐛 Debugging

### Logs Úteis

```python
import logging

logger = logging.getLogger(__name__)

# No endpoint
logger.info(f"Device {device_id} requested")
logger.error(f"Failed to update: {e}")
```

### Debug Mode

```python
# .env
DEBUG=true
LOG_LEVEL=DEBUG

# main.py
if settings.DEBUG:
    app.add_middleware(DebugMiddleware)
```

## 🚨 Erros Comuns

### ImportError nos repositories

```python
# Verificar path
import sys
print(sys.path)

# Path deve incluir ../../database
```

### Device não encontrado

```python
# Sempre verificar None
device = devices.get_by_id(id)
if not device:
    raise HTTPException(404, "Not found")
```

### CORS errors

```python
# Adicionar origem do frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080"],
    ...
)
```

## 📦 Deploy

### Development

```bash
# Com reload automático
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Production

```bash
# Com workers e sem reload
uvicorn main:app --workers 2 --host 0.0.0.0 --port 8000
```

### Systemd Service

```ini
[Unit]
Description=AutoCore Config API
After=network.target

[Service]
User=pi
WorkingDirectory=/home/pi/autocore/config-app/backend
Environment="PATH=/home/pi/autocore/config-app/backend/venv/bin"
ExecStart=/home/pi/autocore/config-app/backend/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000

[Install]
WantedBy=multi-user.target
```

## 🎯 Checklist de Qualidade

Antes de commit:
- [ ] Endpoints testados manualmente
- [ ] Documentação das rotas atualizada
- [ ] Erros tratados apropriadamente
- [ ] Logs adicionados onde necessário
- [ ] Performance adequada para Pi Zero
- [ ] Sem imports diretos do SQLite
- [ ] Usando repositories corretamente

## 💡 Dicas

1. **NÃO reinvente a roda** - Use os repositories existentes
2. **Valide tudo** - Pydantic é seu amigo
3. **Async sempre** - Mesmo para operações simples
4. **Documente** - FastAPI gera docs automaticamente
5. **Teste localmente** - Simule Pi Zero limitado

---

**Última Atualização:** 07 de agosto de 2025  
**Versão:** 2.0.0  
**Maintainer:** Lee Chardes