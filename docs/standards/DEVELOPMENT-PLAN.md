# 📋 Plano de Desenvolvimento - AutoCore

## 💻 Ambiente de Desenvolvimento

**Plataforma**: macOS  
**Deploy Target**: Raspberry Pi Zero 2W  
**Data Início**: 07 de agosto de 2025

## 🎯 Estratégia: Config-First

> **Filosofia**: Criar primeiro o sistema de configuração, pois sem ele nada funciona. Os dispositivos ESP32 e o Gateway dependem das configurações para saber o que fazer.

## 📦 FASE 1: DATABASE (2-3 dias)

### Objetivo
Estabelecer a base de dados funcional com dados de teste para desenvolvimento.

### Tasks

#### 1.1 Setup Inicial
```bash
# No macOS
cd /Users/leechardes/Projetos/AutoCore/database
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

#### 1.2 Inicialização
- [ ] Testar criação de tabelas com models.py
- [ ] Implementar manage.py completo
- [ ] Criar seeds realistas

#### 1.3 Seeds de Desenvolvimento
```python
# Dados iniciais necessários:
- 3 devices ESP32 (relay, display, controls)
- 1 relay_board com 16 channels
- 5 screens pré-configuradas
- 20 screen_items (botões e displays)
- 1 theme padrão
- 1 user admin
```

#### 1.4 Testes
- [ ] Testar todos os repositories
- [ ] Validar integridade referencial
- [ ] Testar performance com 1000 registros de telemetria

## 🌐 FASE 2: CONFIG-APP BACKEND (3-4 dias)

### Objetivo
API REST completa para gerenciar configurações do sistema.

### Tasks

#### 2.1 Setup FastAPI
```bash
cd /Users/leechardes/Projetos/AutoCore/config-app/backend
python3 -m venv .venv
source .venv/bin/activate
pip install fastapi uvicorn python-multipart python-dotenv
```

#### 2.2 Estrutura Base
```python
# main.py
- FastAPI app
- CORS configurado
- Exception handlers
- Middleware de logging

# models/
- Pydantic models para validação
- Request/Response schemas

# routers/
- devices.py
- relays.py
- screens.py
- config.py
```

#### 2.3 Endpoints Prioritários

##### Devices
- `GET /api/devices` - Listar todos
- `GET /api/devices/{id}` - Detalhes
- `POST /api/devices` - Criar novo
- `PUT /api/devices/{id}` - Atualizar
- `DELETE /api/devices/{id}` - Remover
- `GET /api/devices/{id}/status` - Status atual

##### Relay Boards
- `GET /api/relay-boards` - Listar placas
- `GET /api/relay-boards/{id}/channels` - Canais da placa
- `PUT /api/relay-channels/{id}` - Configurar canal
- `POST /api/relay-channels/{id}/toggle` - Alternar estado

##### Screens
- `GET /api/screens` - Listar telas
- `GET /api/screens/{id}/items` - Itens da tela
- `POST /api/screens` - Criar tela
- `PUT /api/screen-items/{id}` - Configurar item

##### Configuration
- `GET /api/config/export` - Exportar JSON completo
- `POST /api/config/import` - Importar configuração
- `GET /api/config/validate` - Validar configuração
- `GET /api/config/device/{uuid}` - Config específica do device

#### 2.4 Testes
- [ ] Testar todos os endpoints com Postman/Insomnia
- [ ] Validar responses JSON
- [ ] Testar concorrência

## 🎯 FASE 3: CONFIG-APP FRONTEND (3-4 dias)

### Objetivo
Interface web intuitiva para configuração sem necessidade de build.

### Tasks

#### 3.1 Estrutura HTML
```
frontend/
├── index.html         # Dashboard principal
├── devices.html       # Gerenciar dispositivos
├── relays.html        # Configurar relés
├── screens.html       # Designer de telas
├── assets/
│   ├── css/
│   │   └── custom.css
│   └── js/
│       ├── api.js      # Comunicação com backend
│       ├── devices.js   # Lógica de devices
│       ├── relays.js    # Lógica de relés
│       └── screens.js   # Lógica de telas
```

#### 3.2 Páginas Prioritárias

##### Dashboard (index.html)
- Status geral do sistema
- Dispositivos online/offline
- Ações rápidas
- Logs recentes

##### Dispositivos (devices.html)
- Lista com status em tempo real
- Formulário de cadastro
- Edição inline
- Ações em lote

##### Relés (relays.html)
- Grid visual dos canais
- Drag & drop para organizar
- Configuração de funções
- Teste individual de canais

##### Telas (screens.html)
- Designer visual drag & drop
- Preview em diferentes tamanhos
- Biblioteca de componentes
- Geração de JSON

#### 3.3 Integração Alpine.js
```javascript
// Exemplo de componente reativo
Alpine.data('deviceManager', () => ({
    devices: [],
    loading: false,
    
    async init() {
        await this.loadDevices();
    },
    
    async loadDevices() {
        this.loading = true;
        const response = await fetch('/api/devices');
        this.devices = await response.json();
        this.loading = false;
    },
    
    async toggleDevice(id) {
        // Lógica de toggle
    }
}))
```

#### 3.4 Testes
- [ ] Testar em Safari (macOS)
- [ ] Testar em Chrome
- [ ] Testar responsividade
- [ ] Validar geração de JSON

## 🔄 FASE 4: INTEGRAÇÃO (2 dias)

### Objetivo
Validar fluxo completo de configuração.

### Tasks

#### 4.1 Fluxo de Teste
1. Criar dispositivo via UI
2. Configurar relés
3. Desenhar tela
4. Gerar configuração JSON
5. Validar JSON gerado
6. Simular consumo por ESP32

#### 4.2 Scripts de Teste
```bash
# test_flow.sh
# 1. Reset database
# 2. Aplicar seeds
# 3. Iniciar backend
# 4. Abrir frontend
# 5. Executar testes automatizados
```

#### 4.3 Documentação
- [ ] README de uso
- [ ] Vídeo demonstrativo
- [ ] Guia de configuração

## 🏯 FASE 5: GATEWAY (3-4 dias)

### Objetivo
Bridge MQTT funcional consumindo configurações.

### Tasks

#### 5.1 Setup MQTT
```bash
# macOS (desenvolvimento)
brew install mosquitto
brew services start mosquitto

# Configurar usuário/senha
mosquitto_passwd -c /usr/local/etc/mosquitto/passwd autocore
```

#### 5.2 Implementação
- [ ] Cliente MQTT com paho
- [ ] Subscriber de configurações
- [ ] Publisher de comandos
- [ ] Bridge com database
- [ ] Cache de configurações

#### 5.3 Tópicos MQTT
```
autocore/config/+              # Configurações por device
autocore/telemetry/+           # Telemetria dos devices
autocore/command/+/+           # Comandos para devices
autocore/status/+              # Status dos devices
autocore/logs/+                # Logs do sistema
```

## 📈 Métricas de Sucesso

### Database
- [ ] 100% dos repositories funcionando
- [ ] Seeds aplicados sem erros
- [ ] Backup/restore funcionando

### Config-App Backend
- [ ] Todos os endpoints respondendo < 200ms
- [ ] Validação Pydantic em 100% dos inputs
- [ ] Tratamento de erros consistente

### Config-App Frontend
- [ ] Interface funciona sem build
- [ ] Responsivo em telas 768px+
- [ ] Geração de JSON válido

### Gateway
- [ ] Conexão MQTT estável
- [ ] Processa 100 msgs/seg
- [ ] Recupera de falhas

## 📅 Cronograma Estimado

| Fase | Início | Fim | Dias |
|------|--------|-----|------|
| Database | 07/08 | 09/08 | 3 |
| Backend | 10/08 | 13/08 | 4 |
| Frontend | 14/08 | 17/08 | 4 |
| Integração | 18/08 | 19/08 | 2 |
| Gateway | 20/08 | 23/08 | 4 |
| **Total** | **07/08** | **23/08** | **17** |

## 🔧 Ferramentas de Desenvolvimento

### macOS
```bash
# Instalar ferramentas
brew install python@3.11
brew install mosquitto
brew install sqlite3
brew install httpie  # Para testar APIs

# VS Code extensions
code --install-extension ms-python.python
code --install-extension dbaeumer.vscode-eslint
code --install-extension bradlc.vscode-tailwindcss
```

### Testes
- **API**: Postman ou Insomnia
- **MQTT**: MQTT Explorer (Mac App)
- **Database**: TablePlus ou DB Browser for SQLite
- **Frontend**: Chrome DevTools

## 🚀 Comandos Úteis

```bash
# Desenvolvimento no macOS
make dev-database    # Inicia database
make dev-backend     # Inicia backend (porta 8000)
make dev-frontend    # Abre frontend no browser
make test-all        # Roda todos os testes

# Deploy para Pi
make deploy-pi       # Faz deploy via SSH
```

## ✅ Checklist de Conclusão

- [ ] Database inicializado com seeds
- [ ] Backend com todos os endpoints
- [ ] Frontend configurando dispositivos
- [ ] Geração de JSON funcional
- [ ] Gateway consumindo configs
- [ ] Documentação completa
- [ ] Vídeo demonstrativo

---

**Início**: 07 de agosto de 2025  
**Previsão de Conclusão**: 23 de agosto de 2025  
**Desenvolvedor**: Lee Chardes  
**Plataforma Dev**: macOS  
**Target**: Raspberry Pi Zero 2W