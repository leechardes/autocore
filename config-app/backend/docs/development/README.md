# Guias de Desenvolvimento

Documentação para desenvolvedores trabalhando com o Config-App Backend.

## 📋 Índice

### 🚀 Início Rápido
- [Como Começar](getting-started.md) - Primeiros passos no projeto
- [Setup Local](local-setup.md) - Configuração do ambiente de desenvolvimento

### 📚 Padrões e Convenções
- [Padrões de Código](coding-standards.md) - Estilo e boas práticas
- [Guia de Testes](testing-guide.md) - Como escrever e executar testes
- [Como Contribuir](contributing.md) - Workflow de contribuição

## 🛠️ Stack Tecnológica

### Backend
- **Python 3.10+** - Linguagem principal
- **FastAPI 0.104.1** - Framework web moderno
- **SQLAlchemy 2.0.23** - ORM para banco de dados
- **Pydantic 2.5.2** - Validação de dados
- **Uvicorn** - Servidor ASGI de alta performance

### Comunicação
- **MQTT (paho-mqtt)** - Messaging para IoT
- **WebSocket** - Comunicação em tempo real
- **HTTP/REST** - APIs RESTful

### Banco de Dados
- **PostgreSQL** - Banco principal (compartilhado)
- **SQLite** - Desenvolvimento local
- **Alembic** - Migrações de banco

### Desenvolvimento
- **pytest** - Framework de testes
- **black** - Formatação de código
- **flake8** - Linting
- **pre-commit** - Hooks de commit

## 🏗️ Arquitetura

### Estrutura do Projeto
```
config-app/backend/
├── main.py              # Aplicação FastAPI principal
├── requirements.txt     # Dependências Python
├── .env.example        # Template de variáveis de ambiente
├── Makefile           # Automação de tarefas
│
├── api/               # Definições da API
│   ├── models/        # Modelos Pydantic
│   ├── routes/        # Routers organizados
│   ├── mqtt_routes.py # Endpoints MQTT
│   └── protocol_routes.py # Protocolo de comunicação
│
├── services/          # Lógica de negócio
│   ├── mqtt_monitor.py # Cliente MQTT
│   ├── macro_executor.py # Executor de macros
│   └── telegram_notifier.py # Notificações
│
├── utils/             # Utilitários
│   └── normalizers.py # Normalizadores de dados
│
├── simulators/        # Simuladores para desenvolvimento
│   └── relay_simulator.py
│
├── tests/             # Testes automatizados
└── docs/              # Documentação
```

### Padrões de Design

#### Repository Pattern
```python
# Acesso aos dados através de repositories
from shared.repositories import devices, relays, config

# Buscar dispositivos
all_devices = devices.get_all()
device = devices.get_by_uuid("esp32-001")
```

#### Dependency Injection
```python
from fastapi import Depends

async def get_current_device(device_id: str) -> Device:
    device = devices.get_by_uuid(device_id)
    if not device:
        raise HTTPException(404, "Device not found")
    return device

@app.get("/api/devices/{device_id}/status")
async def device_status(device: Device = Depends(get_current_device)):
    return {"status": device.status}
```

#### Event-Driven Architecture
```python
# Registrar eventos importantes
events.log(
    event_type="device",
    source="config-app",
    action="create", 
    target=f"device_{device.id}",
    payload={"device_uuid": device.uuid}
)
```

## 🔧 Ferramentas de Desenvolvimento

### Comandos Make
```bash
make install    # Instalar dependências
make dev        # Executar em modo desenvolvimento
make test       # Executar todos os testes
make format     # Formatar código com black
make lint       # Verificar código com flake8
make clean      # Limpar arquivos temporários
```

### Scripts Úteis
```bash
# Executar servidor com reload
uvicorn main:app --host 0.0.0.0 --port 8081 --reload

# Executar testes específicos
pytest tests/test_devices.py -v

# Verificar cobertura
pytest --cov=. --cov-report=html

# Gerar documentação OpenAPI
python -c "import main; import json; print(json.dumps(main.app.openapi(), indent=2))" > docs/api/openapi.json
```

## 🧪 Ambiente de Testes

### Dados de Teste
- Dispositivos simulados com diferentes tipos
- Placas de relé com configurações variadas
- Telas e componentes de exemplo
- Dados de telemetria sintéticos

### Mocking
- Cliente MQTT mockado para testes
- Repositories mockados para testes unitários
- Simuladores para desenvolvimento local

## 📊 Monitoramento e Debug

### Logs
```python
import logging

logger = logging.getLogger(__name__)

# Logs estruturados
logger.info(f"📡 POST /api/devices")
logger.info(f"   Payload: {device_data}")
logger.info(f"   ✅ Device created: {device.id}")
```

### Métricas
- Número de dispositivos online
- Latência das APIs
- Mensagens MQTT por segundo
- Erros e timeouts

### Health Checks
- `/api/health` - Status básico
- `/api/status` - Status detalhado
- Conexão com banco de dados
- Conectividade MQTT

## 🔐 Segurança no Desenvolvimento

### Variáveis de Ambiente
- Nunca commitar `.env` com credenciais reais
- Usar `.env.example` como template
- Validar variáveis obrigatórias na inicialização

### Dados Sensíveis
- Não logar credenciais ou tokens
- Sanitizar payloads em logs de debug
- Usar hash para identificadores em logs

### CORS para Desenvolvimento
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Frontend local
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## 🚀 Deploy e Produção

### Containerização
```dockerfile
FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8081"]
```

### Configurações de Produção
- Desabilitar reload automático
- Configurar logs estruturados
- Usar variáveis de ambiente para configuração
- Implementar rate limiting
- Configurar HTTPS

## 📚 Recursos Adicionais

### Documentação Externa
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy 2.0 Tutorial](https://docs.sqlalchemy.org/en/20/)
- [Pydantic User Guide](https://docs.pydantic.dev/)
- [MQTT Protocol](https://mqtt.org/)

### Ferramentas Recomendadas
- **VSCode** com extensões Python
- **Postman** para teste de APIs  
- **MQTT Explorer** para debug MQTT
- **pgAdmin** para gerenciamento do banco

### Comunidade
- Code reviews obrigatórios
- Discussões sobre arquitetura
- Compartilhamento de conhecimento
- Mentoria para novos desenvolvedores

## 🎯 Próximos Passos

1. Ler [Como Começar](getting-started.md)
2. Configurar [Setup Local](local-setup.md) 
3. Revisar [Padrões de Código](coding-standards.md)
4. Executar [Guia de Testes](testing-guide.md)
5. Seguir [Como Contribuir](contributing.md)

---

*Mantenha esta documentação atualizada conforme o projeto evolui!*