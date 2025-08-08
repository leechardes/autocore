# 🚗 AutoCore - Sistema de Automação Veicular

Sistema completo de automação veicular com ESP32, MQTT e controle via app.

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
├── config-app/          # Aplicação de configuração
│   ├── backend/        # API FastAPI
│   └── frontend/       # Interface React
├── database/           # Schema e migrations
├── gateway/           # Gateway central (desenvolvimento)
├── firmware/          # Código ESP32 (desenvolvimento)
├── mobile/           # App Flutter (desenvolvimento)
└── docs/             # Documentação
```

## 📖 Documentação

- [Arquitetura MQTT](docs/MQTT_ARCHITECTURE.md)
- [Setup Completo](docs/guides/SETUP.md)

## 🔒 Segurança

Sistema de heartbeat para relés críticos que desliga automaticamente em caso de perda de conexão ou travamento.

## 📝 Licença

MIT License

## 👥 Autor

**Lee Chardes** - [@leechardes](https://github.com/leechardes)

---

Feito com ❤️ para a comunidade automotiva