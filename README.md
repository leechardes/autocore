# 🚗 AutoCore - Sistema de Automação Veicular

Sistema completo de automação veicular com ESP32, MQTT e controle via app.

## 📚 Documentação Completa

### [📖 Central de Documentação](docs/README.md)
Acesso completo a toda documentação organizada do projeto.

### [🚀 Hub de Projetos](docs/projects/README.md)
Links diretos para documentação de cada componente do sistema.

### [🤖 Sistema de Agentes](docs/agents/README.md)
Agentes automatizados para documentação e desenvolvimento.

## 📋 Visão Geral

O AutoCore é um sistema modular de automação veicular que permite controlar e monitorar diversos aspectos do veículo através de dispositivos ESP32 conectados via MQTT. O sistema oferece controle local (display touch), remoto (app mobile) e configuração via web.

## 🏗️ Arquitetura

- **ESP32 Relay**: Controle de até 32 relés por placa
- **ESP32 Display**: Interface touch local no veículo  
- **ESP32 CAN**: Integração com ECU (FuelTech, MegaSquirt)
- **ESP32 Sensor**: Leitura de sensores analógicos/digitais
- **Flutter App**: Controle remoto multiplataforma
- **Web Config**: Interface de configuração
- **MQTT Broker**: Comunicação central via Mosquitto

## ✨ Principais Funcionalidades

### Sistema de Ajuda Integrado
- Documentação contextual em cada página
- Guias rápidos e completos
- Atalhos do sistema documentados
- Interface clara sem emojis desnecessários

### Controle de Relés
- 16/32 canais por placa
- Tipos: Toggle, Momentâneo (com heartbeat), Pulse, Temporizado
- Sistema de segurança com heartbeat para relés críticos

### Telemetria
- Integração com ECU via CAN Bus
- Sensores analógicos e digitais
- Armazenamento e visualização em tempo real

### Macros e Automação
- Sequências programáveis de ações
- Triggers: Manual, Agendado, Condicional
- Preservação de estado anterior
- **Sistema de segurança aprimorado**:
  - Controle de permissões por canal (`allow_in_macro`)
  - Canais momentâneos automaticamente excluídos
  - Proteção especial para equipamentos críticos

## 🚀 Quick Start

```bash
# Clone o repositório
git clone https://github.com/leechardes/autocore.git
cd autocore

# Configure o banco de dados
cd database
python3 src/cli/init_database.py

# Configure o backend
cd ../config-app/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py

# Configure o frontend (em outro terminal)
cd ../config-app/frontend
npm install
npm run dev
```

## 📁 Estrutura do Projeto

```
autocore/
├── config-app/              # Aplicação de configuração
│   ├── backend/            # API FastAPI [100% documentado]
│   └── frontend/           # Interface React [100% documentado]
├── database/               # Schema e migrations [100% documentado]
├── app-flutter/            # App mobile Flutter [100% documentado]
├── firmware/               # Firmware ESP32 [100% documentado]
│   └── platformio/
│       └── esp32-display/
├── gateway/                # Gateway MQTT/HTTP [em desenvolvimento]
├── raspberry-pi/           # Sistema embarcado [em desenvolvimento]
└── docs/                   # Documentação central [reorganizada]
    ├── agents/             # Sistema de agentes
    ├── projects/           # Hub de navegação
    ├── architecture/       # Arquitetura do sistema
    ├── hardware/           # Documentação ESP32
    ├── deployment/         # Guias de deploy
    ├── standards/          # Padrões e convenções
    └── guides/             # Guias gerais
```

## 📖 Documentação Rápida

### Por Componente
- [Backend API](config-app/backend/docs/README.md)
- [Frontend React](config-app/frontend/docs/README.md)
- [Database](database/docs/README.md)
- [App Flutter](app-flutter/docs/README.md)
- [Firmware ESP32](firmware/platformio/esp32-display/docs/README.md)

### Por Categoria
- [Arquitetura MQTT](docs/architecture/mqtt-architecture.md)
- [Estrutura do Projeto](docs/architecture/project-structure.md)
- [Guias de Deploy](docs/deployment/deployment-guide.md)
- [Segurança](docs/standards/security.md)

## 📝 Padrões de Documentação

Todos os arquivos de documentação em pastas docs/ devem usar MAIÚSCULAS no nome, mantendo .md minúsculo. Arquivos de agentes devem preservar o prefixo AXX-.

Exemplos:
- `flutter-config.md` → `FLUTTER-CONFIG.md`
- `A01-agent-name.md` → `A01-AGENT-NAME.md`

## 🔒 Segurança

Sistema de heartbeat para relés críticos que desliga automaticamente em caso de perda de conexão ou travamento.

## 📝 Licença

MIT License

## 👥 Autor

**Lee Chardes** - [@leechardes](https://github.com/leechardes)

---

Feito com ❤️ para a comunidade automotiva