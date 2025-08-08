# 🚀 Guia Completo de Setup - Raspberry Pi Zero 2 W

## 📋 Pré-requisitos

### Hardware
- Raspberry Pi Zero 2 W
- Cartão microSD (mínimo 8GB, recomendado 16GB)
- Fonte de alimentação USB (5V, 2A mínimo)
- Adaptador microUSB para USB-A (opcional)
- Leitor de cartão SD

### Software
- Raspberry Pi Imager (incluído neste repositório)
- Imagem do SO (incluída em `../images/`)

## 🔧 Instalação do Sistema Operacional

### 1. Preparar o Cartão SD

#### Usando Raspberry Pi Imager (Recomendado)

1. **Abra o Raspberry Pi Imager**
2. **Escolha o SO:**
   - Clique em "Choose OS"
   - Selecione "Use custom"
   - Navegue até: `AutoCore/raspberry-pi/images/2025-05-13-raspios-bookworm-armhf-lite.img.xz`

3. **Configure (⚙️ Configurações Avançadas):**
   
   **Aba Geral:**
   - ✅ Set hostname: `autocore`
   - ✅ Enable SSH
   - ✅ Set username and password:
     - Username: `leechardes`
     - Password: `lee159753`
   - ✅ Configure wireless LAN:
     - SSID: (sua rede WiFi)
     - Password: (senha do WiFi)
     - Country: BR

   **Aba Services:**
   - ✅ Enable SSH
   - Use password authentication

   **Aba Options:**
   - ✅ Eject media when finished
   - ✅ Enable telemetry (opcional)

4. **Escolha o Storage:**
   - Selecione seu cartão SD

5. **Write:**
   - Clique em "Write"
   - Confirme que deseja apagar o cartão
   - Aguarde a gravação e verificação (~10 minutos)

### 2. Primeiro Boot

1. **Insira o cartão** na Raspberry Pi Zero 2 W
2. **Conecte a alimentação**
3. **Aguarde ~2 minutos** para o primeiro boot
4. **LED verde** piscando = Sistema rodando

### 3. Conexão Inicial

#### Via SSH (Terminal)
```bash
# Descobrir IP (se necessário)
ping autocore.local

# Conectar
ssh leechardes@autocore.local
# Senha: lee159753
```

#### Primeiro Login
```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Expandir filesystem
sudo raspi-config --expand-rootfs
sudo reboot
```

## 🛠️ Instalação do AutoCore

### 1. Setup Automático

```bash
# Baixar e executar script de setup
cd ~
wget https://raw.githubusercontent.com/leechardes/AutoCore/main/scripts/pi_initial_setup.sh
chmod +x pi_initial_setup.sh
./pi_initial_setup.sh
```

### 2. Setup Manual (se preferir)

#### Dependências Base
```bash
# Atualizar sistema
sudo apt update
sudo apt upgrade -y

# Instalar dependências
sudo apt install -y \
    python3-pip \
    python3-venv \
    python3-dev \
    git \
    make \
    mosquitto \
    mosquitto-clients \
    sqlite3 \
    htop \
    curl \
    wget
```

#### Clone do Repositório
```bash
# Clonar AutoCore
cd ~
git clone https://github.com/leechardes/AutoCore.git
cd AutoCore
```

#### Database Setup
```bash
cd ~/AutoCore/database
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
make reset
deactivate
```

#### Backend Setup
```bash
cd ~/AutoCore/config-app/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
deactivate
```

#### Gateway Setup
```bash
cd ~/AutoCore/gateway
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
deactivate
```

## 🔌 Configuração do MQTT (Mosquitto)

### 1. Configurar Mosquitto
```bash
sudo nano /etc/mosquitto/conf.d/autocore.conf
```

Adicione:
```conf
listener 1883
allow_anonymous true
log_type all
log_dest file /var/log/mosquitto/mosquitto.log
log_dest stdout
```

### 2. Reiniciar Mosquitto
```bash
sudo systemctl restart mosquitto
sudo systemctl enable mosquitto
```

### 3. Testar MQTT
```bash
# Terminal 1 - Subscriber
mosquitto_sub -h localhost -t test

# Terminal 2 - Publisher
mosquitto_pub -h localhost -t test -m "Hello MQTT"
```

## 🚀 Configurar Serviços

### 1. Serviço do Config App

```bash
sudo nano /etc/systemd/system/autocore-config.service
```

```ini
[Unit]
Description=AutoCore Config App
After=network.target mosquitto.service

[Service]
Type=simple
User=leechardes
WorkingDirectory=/home/leechardes/AutoCore/config-app/backend
Environment="PATH=/home/leechardes/AutoCore/config-app/backend/.venv/bin"
ExecStart=/home/leechardes/AutoCore/config-app/backend/.venv/bin/python -m uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 2. Serviço do Gateway

```bash
sudo nano /etc/systemd/system/autocore-gateway.service
```

```ini
[Unit]
Description=AutoCore Gateway
After=network.target mosquitto.service autocore-config.service

[Service]
Type=simple
User=leechardes
WorkingDirectory=/home/leechardes/AutoCore/gateway
Environment="PATH=/home/leechardes/AutoCore/gateway/.venv/bin"
ExecStart=/home/leechardes/AutoCore/gateway/.venv/bin/python src/main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 3. Habilitar Serviços

```bash
# Recarregar daemon
sudo systemctl daemon-reload

# Habilitar serviços
sudo systemctl enable autocore-config
sudo systemctl enable autocore-gateway

# Iniciar serviços
sudo systemctl start autocore-config
sudo systemctl start autocore-gateway

# Verificar status
sudo systemctl status autocore-config
sudo systemctl status autocore-gateway
```

## 🔒 Segurança

### 1. Firewall
```bash
sudo apt install ufw
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 8000/tcp  # API
sudo ufw allow 1883/tcp  # MQTT
sudo ufw enable
```

### 2. Fail2ban
```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## 📊 Monitoramento

### Verificar Logs
```bash
# Config App
sudo journalctl -u autocore-config -f

# Gateway
sudo journalctl -u autocore-gateway -f

# Mosquitto
sudo journalctl -u mosquitto -f
```

### Verificar Recursos
```bash
# CPU e Memória
htop

# Temperatura
vcgencmd measure_temp

# Espaço em disco
df -h
```

## 🌐 Acesso

### Interfaces Web
- **Config App API:** http://autocore.local:8000
- **Frontend:** http://autocore.local:3000 (se instalado)

### SSH
```bash
ssh leechardes@autocore.local
```

### MQTT
- **Broker:** autocore.local:1883
- **Sem autenticação** (desenvolvimento)

## 🔧 Comandos Úteis

### Aliases Configurados
```bash
ac-status   # Status do sistema
ac-monitor  # Monitor em tempo real
ac-backup   # Fazer backup
ac-logs     # Ver logs
ac-restart  # Reiniciar serviços
ac-mqtt     # Monitor MQTT
```

### Manutenção
```bash
# Atualizar AutoCore
cd ~/AutoCore
git pull

# Reiniciar tudo
sudo systemctl restart autocore-config autocore-gateway mosquitto

# Backup do database
cp ~/AutoCore/database/autocore.db ~/backups/autocore_$(date +%Y%m%d).db
```

## 🆘 Troubleshooting

### Problema: Não consigo conectar via SSH
```bash
# No seu computador
ping autocore.local

# Se não funcionar, descubra o IP no roteador
# ou conecte monitor/teclado temporariamente
```

### Problema: Serviços não iniciam
```bash
# Ver logs detalhados
sudo journalctl -xe

# Verificar Python
python3 --version  # Deve ser 3.9+

# Reinstalar dependências
cd ~/AutoCore/config-app/backend
source .venv/bin/activate
pip install -r requirements.txt
```

### Problema: MQTT não conecta
```bash
# Verificar se Mosquitto está rodando
sudo systemctl status mosquitto

# Ver logs do Mosquitto
sudo tail -f /var/log/mosquitto/mosquitto.log

# Testar conexão local
mosquitto_pub -h localhost -t test -m "test"
```

### Problema: Pouca memória
```bash
# Ver uso de memória
free -h

# Criar/aumentar swap
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## 📝 Notas Importantes

1. **Credenciais padrão:**
   - Usuário: `leechardes`
   - Senha: `lee159753`
   - Hostname: `autocore`

2. **Portas utilizadas:**
   - 22: SSH
   - 1883: MQTT
   - 8000: API Backend
   - 3000: Frontend (opcional)

3. **Recursos mínimos:**
   - RAM: 512MB (Pi Zero 2 W)
   - SD Card: 8GB mínimo
   - CPU: BCM2710A1 (4 cores)

4. **Backup regular:**
   - Database: Diário
   - Configurações: Semanal
   - Imagem SD: Mensal

## 🎯 Próximos Passos

1. **Configurar dispositivos ESP32**
2. **Testar comunicação MQTT**
3. **Configurar macros no sistema**
4. **Integrar com veículo**

---

**Última atualização:** Janeiro 2025
**Versão do OS:** Raspberry Pi OS Bookworm Lite (32-bit)
**Compatível com:** Raspberry Pi Zero 2 W