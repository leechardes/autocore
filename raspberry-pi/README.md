# 🍓 Raspberry Pi Zero 2 W - AutoCore Gateway

## 📦 Conteúdo

Este diretório contém tudo necessário para configurar uma Raspberry Pi Zero 2 W como gateway do AutoCore.

### 📁 Estrutura
```
raspberry-pi/
├── images/         # Imagem do SO (493MB)
│   └── 2025-05-13-raspios-bookworm-armhf-lite.img.xz
├── docs/          # Documentação completa
│   ├── SETUP_GUIDE.md    # Guia completo passo-a-passo
│   ├── QUICK_START.md    # Setup rápido em 5 minutos
│   └── IMAGER_CONFIG.md  # Configuração do Raspberry Pi Imager
└── scripts/       # Scripts de automação
```

## 🚀 Quick Start

### 1. Gravar SO no SD Card
```bash
# Use Raspberry Pi Imager com a imagem em images/
# Configurações pré-definidas em docs/IMAGER_CONFIG.md
```

### 2. Conectar
```bash
ssh leechardes@autocore.local
# Senha: lee159753
```

### 3. Instalar AutoCore
```bash
# Setup automático
wget https://raw.githubusercontent.com/leechardes/AutoCore/main/scripts/pi_initial_setup.sh
chmod +x pi_initial_setup.sh
./pi_initial_setup.sh
```

## 📋 Especificações

### Hardware
- **Modelo:** Raspberry Pi Zero 2 W
- **CPU:** BCM2710A1, quad-core 64-bit SoC @ 1GHz
- **RAM:** 512MB LPDDR2
- **WiFi:** 802.11 b/g/n 2.4GHz
- **GPIO:** 40 pinos
- **Alimentação:** 5V via micro USB

### Sistema Operacional
- **OS:** Raspberry Pi OS Lite (32-bit)
- **Versão:** Bookworm (Debian 12)
- **Kernel:** 6.6.x
- **Arquitetura:** armhf (32-bit)
- **Tamanho:** ~493MB comprimido, ~2GB instalado

## 🔧 Configurações Padrão

### Credenciais
```yaml
Hostname: autocore
Username: leechardes
Password: lee159753
```

### Portas
```yaml
SSH: 22
API: 8000
MQTT: 1883
Frontend: 3000
```

### Serviços
- **autocore-config** - API Backend
- **autocore-gateway** - Gateway MQTT
- **mosquitto** - Broker MQTT

## 📊 Performance

### Uso de Recursos (idle)
- **RAM:** ~80MB / 512MB
- **CPU:** ~5%
- **Temp:** ~45°C
- **SD:** ~2GB usado

### Capacidade
- **Dispositivos ESP32:** 50+
- **Mensagens MQTT/seg:** 1000+
- **Uptime:** 24/7

## 🛠️ Manutenção

### Comandos Úteis
```bash
ac-status   # Status geral
ac-monitor  # Monitor tempo real
ac-backup   # Fazer backup
ac-logs     # Ver logs
ac-restart  # Reiniciar serviços
```

### Backup
```bash
# Database
cp ~/AutoCore/database/autocore.db ~/backups/

# Imagem completa do SD
sudo dd if=/dev/mmcblk0 of=backup.img bs=4M
```

### Atualização
```bash
cd ~/AutoCore
git pull
ac-restart
```

## 📚 Documentação

- **[SETUP_GUIDE.md](docs/SETUP_GUIDE.md)** - Guia completo de instalação
- **[QUICK_START.md](docs/QUICK_START.md)** - Começar em 5 minutos
- **[IMAGER_CONFIG.md](docs/IMAGER_CONFIG.md)** - Config do Raspberry Pi Imager
- **[RASPBERRY_PI_CONFIG.md](../RASPBERRY_PI_CONFIG.md)** - Configurações privadas (não commitado)

## 🔒 Segurança

- Firewall (ufw) configurado
- Fail2ban para proteção SSH
- MQTT sem autenticação (desenvolvimento)
- Backup automático diário

## 🆘 Suporte

### Problemas Comuns
1. **Não conecta SSH** - Verificar WiFi/IP
2. **Serviços não iniciam** - Verificar logs com `ac-logs`
3. **Pouca memória** - Ativar swap
4. **Temperatura alta** - Adicionar dissipador

### Logs
```bash
# Sistema
sudo journalctl -xe

# AutoCore
ac-logs

# MQTT
mosquitto_sub -h localhost -t '#' -v
```

## 📝 Notas

- **NÃO commitar** arquivos .img ou .xz (muito grandes)
- Manter backup do SD Card
- Testar em ambiente isolado antes de produção
- Monitorar temperatura em uso contínuo

---

**Última Atualização:** Janeiro 2025
**Maintainer:** Lee Chardes
**Licença:** MIT