# Como Começar

Guia para novos desenvolvedores no projeto Config-App Backend.

## 📋 Pré-requisitos

### Software Necessário
- **Python 3.10+** - [Download](https://www.python.org/downloads/)
- **Git** - [Instalação](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- **VSCode** (recomendado) - [Download](https://code.visualstudio.com/)

### Conhecimentos Recomendados
- **Python** - Básico a intermediário
- **FastAPI** - Framework web moderno
- **REST APIs** - Conceitos básicos
- **SQL** - Consultas básicas
- **Git** - Controle de versão

## 🚀 Setup Inicial

### 1. Clonar o Repositório
```bash
# Clone o repositório principal
git clone <repository-url>
cd AutoCore/config-app/backend

# Verificar estrutura
ls -la
```

### 2. Configurar Ambiente Virtual
```bash
# Criar ambiente virtual
python -m venv venv

# Ativar ambiente (Linux/Mac)
source venv/bin/activate

# Ativar ambiente (Windows)
venv\Scripts\activate

# Verificar ativação
which python  # deve apontar para venv/bin/python
```

### 3. Instalar Dependências
```bash
# Instalar dependências de produção
pip install -r requirements.txt

# Verificar instalação
pip list | grep fastapi
```

### 4. Configurar Variáveis de Ambiente
```bash
# Copiar template
cp .env.example .env

# Editar configurações
nano .env
```

**Exemplo de .env para desenvolvimento:**
```env
# Ambiente
ENV=development
DEBUG=true

# API
CONFIG_APP_HOST=0.0.0.0
CONFIG_APP_PORT=8081

# Banco de Dados (desenvolvimento local)
DATABASE_URL=sqlite:///./autocore_dev.db

# MQTT
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_USERNAME=
MQTT_PASSWORD=
MQTT_TOPIC_PREFIX=autocore

# Logs
LOG_LEVEL=DEBUG
```

### 5. Executar a Aplicação
```bash
# Método 1: Uvicorn direto
uvicorn main:app --host 0.0.0.0 --port 8081 --reload

# Método 2: Python direto
python main.py

# Método 3: Make (se disponível)
make dev
```

### 6. Verificar Funcionamento
```bash
# Testar endpoint básico
curl http://localhost:8081/

# Ou abrir no browser
open http://localhost:8081/docs
```

## 🔍 Explorando o Projeto

### Estrutura Principal
```
config-app/backend/
├── main.py              # 📍 COMECE AQUI - App principal
├── requirements.txt     # Dependências Python
├── .env.example        # Template de configuração
│
├── api/               # Definições da API REST
│   ├── models/        # Modelos Pydantic (schemas)
│   ├── routes/        # Routers por funcionalidade
│   ├── mqtt_routes.py # Endpoints MQTT
│   └── protocol_routes.py
│
├── services/          # Lógica de negócio
│   ├── mqtt_monitor.py # Cliente MQTT em tempo real
│   ├── macro_executor.py # Execução de macros
│   └── telegram_notifier.py
│
├── utils/             # Utilitários e helpers
├── simulators/        # Simuladores para desenvolvimento
├── tests/             # Testes automatizados
└── docs/              # Esta documentação
```

### Endpoints Principais
1. **Sistema**: `GET /api/status` - Status do sistema
2. **Dispositivos**: `GET /api/devices` - Lista dispositivos
3. **Telas**: `GET /api/screens` - Configuração de UI
4. **Relés**: `GET /api/relays/channels` - Controle de relés
5. **WebSocket**: `WS /ws/mqtt` - Streaming MQTT

### Banco de Dados
```bash
# O projeto usa um banco compartilhado
# Path: ../../../database/

# Ver modelos disponíveis
ls ../../../database/src/models/

# Repositories importantes
ls ../../../database/shared/repositories/
```

## 💡 Primeiras Tarefas

### 1. Explorar a Documentação Interativa
```bash
# Abrir Swagger UI
open http://localhost:8081/docs

# Testar endpoints básicos
curl -X GET "http://localhost:8081/api/health"
curl -X GET "http://localhost:8081/api/devices"
```

### 2. Entender o Fluxo MQTT
```bash
# Ver logs MQTT em tempo real
tail -f logs/mqtt.log

# Conectar WebSocket (JavaScript no browser console)
const ws = new WebSocket('ws://localhost:8081/ws/mqtt');
ws.onmessage = (e) => console.log(JSON.parse(e.data));
```

### 3. Executar Testes
```bash
# Executar todos os testes
pytest -v

# Executar teste específico
pytest tests/test_devices.py -v

# Ver cobertura
pytest --cov=. --cov-report=html
open htmlcov/index.html
```

### 4. Simular Dispositivos
```bash
# Executar simulador de relé
python simulators/relay_simulator.py

# Em outro terminal, ver dispositivos
curl http://localhost:8081/api/devices
```

## 🔧 Configuração do Editor

### VSCode Extensions Recomendadas
```json
{
  "recommendations": [
    "ms-python.python",
    "ms-python.flake8",
    "ms-python.black-formatter",
    "ms-python.pylint",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "humao.rest-client"
  ]
}
```

### Settings.json do VSCode
```json
{
  "python.defaultInterpreterPath": "./venv/bin/python",
  "python.formatting.provider": "black",
  "python.linting.enabled": true,
  "python.linting.flake8Enabled": true,
  "editor.formatOnSave": true,
  "files.associations": {
    "*.env": "properties"
  }
}
```

### Arquivo .rest para Testes
Criar `api-tests.rest`:
```rest
### Health Check
GET http://localhost:8081/api/health

### List Devices  
GET http://localhost:8081/api/devices

### Create Device
POST http://localhost:8081/api/devices
Content-Type: application/json

{
  "uuid": "test-device-001",
  "name": "Test Device",
  "type": "esp32_display"
}

### WebSocket Test (não funciona no REST Client)
# Use JavaScript no browser console para WebSocket
```

## 🐛 Debug e Solução de Problemas

### Problemas Comuns

#### 1. Erro de Importação
```bash
# Erro: ModuleNotFoundError: No module named 'shared'
# Solução: Verificar path do database
export PYTHONPATH="${PYTHONPATH}:../../../database"
```

#### 2. Erro de Conexão com Banco
```bash
# Erro: database connection failed
# Solução: Verificar se o database está configurado
cd ../../../database
python -m src.setup_database
```

#### 3. MQTT Não Conecta
```bash
# Erro: MQTT connection refused
# Solução: Instalar broker local ou usar config de desenvolvimento
# Para desenvolvimento, usar broker público de teste
MQTT_BROKER=test.mosquitto.org
```

#### 4. Porta já em Uso
```bash
# Erro: Port 8081 is already in use
# Solução: Usar outra porta ou parar processo existente
lsof -ti:8081 | xargs kill -9
```

### Logs de Debug
```python
# Adicionar logs temporários
import logging
logger = logging.getLogger(__name__)

logger.debug(f"🔍 Debug info: {variable}")
logger.info(f"📍 Checkpoint reached")
logger.warning(f"⚠️ Attention needed: {issue}")
logger.error(f"❌ Error occurred: {error}")
```

## 📚 Próximos Passos

### 1. Entender o Domínio
- Dispositivos ESP32 e suas capacidades
- Sistema de relés e controle
- Interface de configuração de telas
- Comunicação MQTT em tempo real

### 2. Estudar o Código
- Seguir fluxo de uma requisição do início ao fim
- Entender como os repositories funcionam
- Ver como o MQTT integra com WebSocket
- Analisar tratamento de erros

### 3. Fazer Pequenas Mudanças
- Adicionar log em um endpoint
- Melhorar uma mensagem de erro
- Criar um novo endpoint simples
- Escrever um teste

### 4. Participar do Time
- Fazer perguntas no Slack/Teams
- Revisar PRs de outros desenvolvedores
- Sugerir melhorias na documentação
- Compartilhar conhecimento adquirido

## 🎯 Tarefas Práticas Sugeridas

### Tarefa 1: Hello World
```python
# Adicionar endpoint em main.py
@app.get("/api/hello/{name}")
async def hello_world(name: str):
    return {"message": f"Hello, {name}! Welcome to AutoCore!"}
```

### Tarefa 2: Explorar Dispositivos
```python
# Criar função para contar dispositivos por tipo
@app.get("/api/devices/stats")
async def device_stats():
    all_devices = devices.get_all()
    stats = {}
    for device in all_devices:
        device_type = device.type
        stats[device_type] = stats.get(device_type, 0) + 1
    return stats
```

### Tarefa 3: WebSocket Simples
```html
<!-- Criar arquivo test-websocket.html -->
<script>
const ws = new WebSocket('ws://localhost:8081/ws/mqtt');
ws.onopen = () => console.log('Connected!');
ws.onmessage = (e) => {
    const data = JSON.parse(e.data);
    console.log('MQTT:', data);
};
</script>
```

## 💬 Obtendo Ajuda

### Recursos Internos
- **Documentação**: Esta pasta `docs/`
- **Código Existente**: Exemplos nos endpoints atuais
- **Testes**: Ver `tests/` para exemplos de uso

### Recursos Externos
- [FastAPI Tutorial](https://fastapi.tiangolo.com/tutorial/)
- [Python Type Hints](https://docs.python.org/3/library/typing.html)
- [MQTT Basics](https://www.hivemq.com/mqtt-essentials/)

### Comunidade
- Fazer perguntas específicas
- Compartilhar dúvidas e soluções
- Documentar problemas encontrados
- Ajudar outros desenvolvedores

---

**🎉 Parabéns!** Você está pronto para contribuir com o AutoCore Config-App!

*Continue com: [Setup Local Detalhado](local-setup.md)*