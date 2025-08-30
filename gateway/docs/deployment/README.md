# 📚 Deployment - Gateway AutoCore

## 🎯 Visão Geral

Guias e configurações para deploy do Gateway AutoCore em ambientes de produção.

## 📖 Conteúdo

### Setup
- [SETUP-GUIDE.md](SETUP-GUIDE.md) - Guia completo de instalação
- [RASPBERRY-PI-SETUP.md](RASPBERRY-PI-SETUP.md) - Setup específico para Raspberry Pi
- [DOCKER-SETUP.md](DOCKER-SETUP.md) - Deploy com containers

### Configuração
- [CONFIGURATION.md](CONFIGURATION.md) - Configurações do sistema
- [MQTT-CONFIG.md](MQTT-CONFIG.md) - Configuração do broker MQTT
- [DATABASE-CONFIG.md](DATABASE-CONFIG.md) - Configuração do banco

### Monitoramento
- [MONITORING.md](MONITORING.md) - Sistema de monitoramento
- [LOGS-SETUP.md](LOGS-SETUP.md) - Configuração de logs

## 🚀 Quick Deploy

```bash
# Clone o repositório
git clone https://github.com/autocore/gateway

# Configure ambiente
cd gateway
cp .env.example .env

# Instale dependências
pip install -r requirements.txt

# Inicie o gateway
python main.py
```

## 🔧 Requisitos Mínimos

- Raspberry Pi Zero 2W ou superior
- 512MB RAM mínimo
- 4GB armazenamento
- Python 3.9+
- Mosquitto MQTT broker

---

**Última atualização**: 27/01/2025