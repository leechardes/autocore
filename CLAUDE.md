# 🤖 Instruções para Claude - AutoCore

Este documento contém instruções específicas para assistentes IA (Claude) trabalharem com o projeto AutoCore.

## 📋 Visão Geral

O AutoCore é um sistema modular de automação veicular que integra:
- ESP32 (firmware PlatformIO/ESP-IDF)
- MQTT Broker (Mosquitto)  
- Backend API (FastAPI)
- Frontend Web (React)
- App Mobile (Flutter)
- Database (PostgreSQL + SQLAlchemy)

## 🗃️ Estrutura do Projeto

```
/Users/leechardes/Projetos/AutoCore/
├── config-app/              # Aplicação principal
│   ├── backend/            # API FastAPI
│   └── frontend/           # React SPA
├── database/               # Schema PostgreSQL
├── app-flutter/            # App mobile Flutter
├── firmware/               # Firmware ESP32
│   ├── platformio/         # ESP32 Display/Relés
│   └── esp-idf/           # Versões ESP-IDF
├── gateway/                # Gateway MQTT/HTTP
├── raspberry-pi/           # Sistema embarcado
├── archived_projects/      # Projetos legados
├── monitor/               # Ferramentas de monitoramento
└── docs/                  # Documentação central
```

## 📝 Nomenclatura de Documentação

### Regra Principal
Arquivos .md em pastas docs/ devem usar MAIÚSCULAS, mantendo .md minúsculo. Agentes preservam numeração AXX-.

### Exemplos
- `flutter-config.md` → `FLUTTER-CONFIG.md`
- `api-endpoints.md` → `API-ENDPOINTS.md`
- `A01-agent-name.md` → `A01-AGENT-NAME.md`
- `README.md` → `README.md` (exceção)

## 🛠️ Tecnologias por Componente

### Backend (`config-app/backend/`)
- **Framework**: FastAPI + Uvicorn
- **Database**: PostgreSQL + SQLAlchemy + Alembic
- **MQTT**: paho-mqtt
- **Autenticação**: JWT tokens
- **Estrutura**: Repository Pattern + Services

### Frontend (`config-app/frontend/`)  
- **Framework**: React 18 + TypeScript
- **Build**: Vite
- **UI**: Tailwind CSS + shadcn/ui
- **Estado**: Zustand
- **Comunicação**: Axios + WebSocket

### Mobile (`app-flutter/`)
- **Framework**: Flutter 3.24+
- **Estado**: Provider/Riverpod
- **HTTP**: Dio
- **MQTT**: mqtt_client
- **Persistência**: SharedPreferences + SQLite

### Firmware (`firmware/platformio/esp32-display/`)
- **Platform**: ESP32 + PlatformIO
- **Display**: TFT_eSPI (ILI9341)
- **Touch**: XPT2046
- **MQTT**: PubSubClient
- **JSON**: ArduinoJson
- **WiFi**: WiFiManager

### Database (`database/`)
- **SGBD**: PostgreSQL 15+
- **ORM**: SQLAlchemy 2.0+
- **Migrations**: Alembic
- **Schema**: Modular (users, devices, screens, etc)

## 🔧 Comandos Importantes

### Backend
```bash
cd config-app/backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py
```

### Frontend
```bash
cd config-app/frontend  
npm install
npm run dev
```

### Flutter App
```bash
cd app-flutter
flutter pub get
flutter run
```

### Database
```bash
cd database
python src/cli/init_database.py
python src/cli/migrate_database.py
```

### Firmware
```bash
cd firmware/platformio/esp32-display
pio run --target upload
```

## 📊 Arquitetura MQTT

### Tópicos Principais
```
autocore/
├── devices/{device_id}/
│   ├── status/           # Estado do dispositivo
│   ├── commands/         # Comandos para device
│   └── telemetry/        # Dados de sensores
├── relays/{device_id}/
│   ├── status/           # Estado dos relés
│   └── control/          # Comandos de controle
└── displays/{device_id}/
    ├── config/           # Configuração de telas
    └── interaction/      # Interações do usuário
```

### Comunicação
- **QoS 0**: Telemetria (tolerável perda)
- **QoS 1**: Comandos críticos
- **QoS 2**: Configurações importantes

## 🗄️ Padrões de Banco de Dados

### Tabelas Principais
- `users` - Autenticação e perfis
- `devices` - ESP32s registrados  
- `relays` - Configuração de relés
- `screens` - Layouts de interface
- `themes` - Temas visuais
- `telemetry` - Dados históricos

### Relacionamentos
- User 1:N Devices
- Device 1:N Relays  
- Device 1:N Screens
- Screen N:M Components

## 🔒 Segurança

### Backend
- JWT com refresh tokens
- Rate limiting por endpoint
- Validação Pydantic rigorosa
- CORS configurado adequadamente

### ESP32
- WiFi WPA2/WPA3
- MQTT over TLS (opcional)
- OTA com assinatura
- Heartbeat para relés críticos

### App Flutter
- Secure Storage para tokens
- Certificate pinning
- Biometric authentication (opcional)

## 🧪 Testes

### Backend
```bash
pytest tests/ -v --cov=src
```

### Frontend  
```bash
npm run test
npm run test:coverage
```

### Flutter
```bash
flutter test
flutter test --coverage
```

## 📚 Documentação

Cada componente tem documentação completa em `docs/`:
- **API**: OpenAPI/Swagger automático
- **Database**: Schema visual + migrations
- **Firmware**: Diagramas de pinout + código
- **Mobile**: Screenshots + guias de uso

## 🚀 Deploy

### Desenvolvimento
- Docker Compose para stack completa
- Hot reload em todos os componentes
- Database em container PostgreSQL

### Produção  
- Nginx como reverse proxy
- PostgreSQL dedicado
- MQTT broker SSL/TLS
- ESP32 com OTA via HTTPS

## 🐛 Debugging

### Logs Estruturados
- Backend: Python logging + structured JSON
- Frontend: Console + network tab
- ESP32: Serial Monitor + telnet
- MQTT: mosquitto_sub/pub para debug

### Monitoramento
- Health checks em todos endpoints
- Métricas de MQTT (QoS, latência)  
- Telemetria de dispositivos
- Dashboard Grafana (opcional)

## 📱 Funcionalidades Principais

### Dashboard
- Status em tempo real de dispositivos
- Controle individual de relés
- Gráficos de telemetria
- Alertas configuráveis

### Configuração
- Wizard de setup inicial
- Templates de dispositivos
- Backup/restore de configurações
- Modo simulação para testes

### Automação
- Macros programáveis
- Triggers: manual, agendado, condicional
- Preservação de estados anteriores
- Controle de permissões por canal

## 💡 Boas Práticas

### Código
- Type hints obrigatórios (Python/TypeScript)
- Documentação inline para funções públicas
- Testes unitários para lógica crítica
- Code review obrigatório para PRs

### Git
- Commits semânticos (feat/fix/docs/refactor)
- Branches por feature
- Squash merge para manter histórico limpo
- Tags para releases

### Performance
- Lazy loading em interfaces
- Cache de configurações no ESP32
- Debounce em comandos MQTT
- Paginação em listagens grandes

---

*Este documento é atualizado automaticamente pelos agentes do sistema.*

**Última atualização**: 23/08/2025