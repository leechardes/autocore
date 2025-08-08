#!/bin/bash

# ============================================
# Script de Setup Inicial - Raspberry Pi Zero
# AutoCore Gateway System
# Execute este script na Raspberry Pi após o primeiro boot
# ============================================

set -e  # Para em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}   AutoCore - Setup Inicial Pi Zero  ${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Verificar se está rodando na Pi
if [ ! -f /proc/device-tree/model ]; then
    echo -e "${RED}❌ Este script deve ser executado na Raspberry Pi!${NC}"
    exit 1
fi

echo -e "${GREEN}Modelo: $(cat /proc/device-tree/model)${NC}"
echo ""

# 1. Atualizar sistema
echo -e "${YELLOW}📦 Atualizando sistema...${NC}"
sudo apt update
sudo apt upgrade -y

# 2. Instalar dependências essenciais
echo -e "${YELLOW}🔧 Instalando dependências essenciais...${NC}"
sudo apt install -y \
    python3-pip \
    python3-venv \
    python3-dev \
    git \
    make \
    curl \
    wget \
    htop \
    mosquitto \
    mosquitto-clients \
    sqlite3 \
    nginx \
    ufw \
    fail2ban

# 3. Configurar timezone
echo -e "${YELLOW}🕐 Configurando timezone...${NC}"
sudo timedatectl set-timezone America/Sao_Paulo

# 4. Expandir filesystem
echo -e "${YELLOW}💾 Expandindo sistema de arquivos...${NC}"
sudo raspi-config --expand-rootfs

# 5. Configurar Mosquitto
echo -e "${YELLOW}🦟 Configurando Mosquitto MQTT...${NC}"
sudo tee /etc/mosquitto/conf.d/autocore.conf > /dev/null << EOF
listener 1883
allow_anonymous true
log_type all
log_dest file /var/log/mosquitto/mosquitto.log
log_dest stdout
EOF

sudo systemctl restart mosquitto
sudo systemctl enable mosquitto

# 6. Configurar firewall básico
echo -e "${YELLOW}🔒 Configurando firewall...${NC}"
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 8000/tcp  # API
sudo ufw allow 1883/tcp  # MQTT
sudo ufw allow 3000/tcp  # Frontend
sudo ufw allow 80/tcp    # HTTP
sudo ufw --force enable

# 7. Otimizações para Pi Zero
echo -e "${YELLOW}⚡ Aplicando otimizações...${NC}"

# Desabilitar serviços desnecessários
sudo systemctl disable bluetooth 2>/dev/null || true
sudo systemctl disable avahi-daemon 2>/dev/null || true
sudo systemctl disable triggerhappy 2>/dev/null || true

# Configurar swap (importante para Pi Zero com 512MB RAM)
if [ ! -f /swapfile ]; then
    echo -e "${YELLOW}💾 Criando arquivo swap...${NC}"
    sudo fallocate -l 1G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# 8. Criar estrutura de diretórios
echo -e "${YELLOW}📁 Criando estrutura de diretórios...${NC}"
mkdir -p ~/AutoCore
mkdir -p ~/backups
mkdir -p ~/logs

# 9. Criar scripts úteis
echo -e "${YELLOW}📝 Criando scripts auxiliares...${NC}"

# Script de monitoramento
cat > ~/monitor_autocore.sh << 'EOF'
#!/bin/bash
clear
echo "=== AutoCore Monitor ==="
echo ""
echo "📊 Recursos do Sistema:"
echo "----------------------"
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
echo "RAM: $(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}')"
echo "Temp: $(vcgencmd measure_temp | cut -d= -f2)"
echo "Disk: $(df -h / | awk 'NR==2{print $5}' | sed 's/%//')%"
echo ""
echo "🔧 Status dos Serviços:"
echo "----------------------"
systemctl is-active --quiet mosquitto && echo "✅ Mosquitto: Running" || echo "❌ Mosquitto: Stopped"
systemctl is-active --quiet autocore-config && echo "✅ Config App: Running" || echo "❌ Config App: Stopped"
systemctl is-active --quiet autocore-gateway && echo "✅ Gateway: Running" || echo "❌ Gateway: Stopped"
echo ""
echo "📡 MQTT Topics (últimas 5):"
mosquitto_sub -h localhost -t "autocore/#" -C 5 -v 2>/dev/null || echo "Sem mensagens recentes"
EOF
chmod +x ~/monitor_autocore.sh

# Script de backup
cat > ~/backup_autocore.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/leechardes/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Backup database
if [ -f ~/AutoCore/database/autocore.db ]; then
    cp ~/AutoCore/database/autocore.db $BACKUP_DIR/autocore_$DATE.db
    echo "✅ Database backup: $BACKUP_DIR/autocore_$DATE.db"
fi

# Backup configs
if [ -d ~/AutoCore ]; then
    tar -czf $BACKUP_DIR/config_$DATE.tar.gz \
        ~/AutoCore/config-app/backend/.env \
        ~/AutoCore/gateway/.env \
        2>/dev/null || echo "Configs não encontradas ainda"
fi

# Limpar backups antigos (manter últimos 7)
cd $BACKUP_DIR
ls -t autocore_*.db 2>/dev/null | tail -n +8 | xargs rm -f 2>/dev/null
ls -t config_*.tar.gz 2>/dev/null | tail -n +8 | xargs rm -f 2>/dev/null

echo "✅ Backup completo"
EOF
chmod +x ~/backup_autocore.sh

# 10. Configurar cron para backup automático
echo -e "${YELLOW}⏰ Configurando backup automático...${NC}"
(crontab -l 2>/dev/null; echo "0 3 * * * /home/leechardes/backup_autocore.sh") | crontab -

# 11. Criar arquivo de status
cat > ~/autocore_status.sh << 'EOF'
#!/bin/bash
echo "AutoCore System Status"
echo "====================="
echo ""
echo "System Info:"
echo "  Hostname: $(hostname)"
echo "  IP: $(hostname -I | awk '{print $1}')"
echo "  Uptime: $(uptime -p)"
echo "  Temperature: $(vcgencmd measure_temp)"
echo ""
echo "Services:"
sudo systemctl status mosquitto --no-pager | head -n 3
sudo systemctl status autocore-config --no-pager 2>/dev/null | head -n 3 || echo "  Config: Not installed"
sudo systemctl status autocore-gateway --no-pager 2>/dev/null | head -n 3 || echo "  Gateway: Not installed"
echo ""
echo "Resources:"
free -h | grep -E "^Mem|^Swap"
df -h / | grep -E "^Filesystem|^/dev"
echo ""
echo "Network:"
ip -4 addr show wlan0 | grep inet
echo ""
echo "MQTT Test:"
mosquitto_pub -h localhost -t test -m "ping" && echo "  ✅ MQTT working" || echo "  ❌ MQTT error"
EOF
chmod +x ~/autocore_status.sh

# 12. Aliases úteis
echo -e "${YELLOW}🔧 Configurando aliases...${NC}"
cat >> ~/.bashrc << 'EOF'

# AutoCore Aliases
alias ac-status='~/autocore_status.sh'
alias ac-monitor='~/monitor_autocore.sh'
alias ac-backup='~/backup_autocore.sh'
alias ac-logs='sudo journalctl -f'
alias ac-restart='sudo systemctl restart mosquitto autocore-config autocore-gateway'
alias ac-temp='vcgencmd measure_temp'
alias ac-mqtt='mosquitto_sub -h localhost -t "autocore/#" -v'
EOF

# 13. Mensagem final
echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}    ✅ Setup Inicial Completo!       ${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "${BLUE}Próximos passos:${NC}"
echo "1. Reinicie a Pi: ${YELLOW}sudo reboot${NC}"
echo "2. Após reiniciar, clone o projeto:"
echo "   ${YELLOW}git clone https://github.com/leechardes/AutoCore.git${NC}"
echo "3. Execute o deploy do seu computador:"
echo "   ${YELLOW}./scripts/deploy_to_pi.sh${NC}"
echo ""
echo -e "${BLUE}Comandos úteis disponíveis:${NC}"
echo "  ${GREEN}ac-status${NC}  - Ver status do sistema"
echo "  ${GREEN}ac-monitor${NC} - Monitor em tempo real"
echo "  ${GREEN}ac-backup${NC}  - Fazer backup manual"
echo "  ${GREEN}ac-logs${NC}    - Ver logs em tempo real"
echo "  ${GREEN}ac-mqtt${NC}    - Monitor MQTT"
echo ""
echo -e "${YELLOW}⚠️  A Pi será reiniciada em 10 segundos...${NC}"
sleep 10
sudo reboot