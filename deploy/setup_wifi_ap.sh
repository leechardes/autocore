#!/bin/bash

# Setup WiFi Access Point + Station mode para Raspberry Pi
# Permite que o Pi se conecte a uma rede WiFi e ao mesmo tempo crie seu próprio hotspot

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🌐 Configuração WiFi AP+STA para AutoCore${NC}"
echo "=========================================="

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Este script precisa ser executado como root${NC}"
    echo "Use: sudo $0"
    exit 1
fi

# Obter MAC address da interface wlan0 (sem os :)
MAC_ADDRESS=$(cat /sys/class/net/wlan0/address | tr -d ':' | tr '[:lower:]' '[:upper:]')
AP_SSID="AutoCore_${MAC_ADDRESS}"
AP_PASSWORD="autocore123"  # Senha padrão, pode ser mudada

echo -e "${BLUE}📡 Configurando Access Point${NC}"
echo "  SSID: ${AP_SSID}"
echo "  IP do AP: 192.168.10.1"
echo ""

# 1. Instalar pacotes necessários
echo -e "${GREEN}📦 Instalando pacotes necessários...${NC}"
apt-get update
apt-get install -y hostapd dnsmasq iptables-persistent netfilter-persistent

# Parar serviços temporariamente
systemctl stop hostapd 2>/dev/null || true
systemctl stop dnsmasq 2>/dev/null || true

# 2. Configurar interface virtual para AP
echo -e "${GREEN}🔧 Configurando interface virtual...${NC}"

# Criar interface virtual ap0
cat > /etc/systemd/network/12-ap0.netdev << EOF
[NetDev]
Name=ap0
Kind=vlan

[VLAN]
Id=4
EOF

# Configurar interface ap0
cat > /etc/systemd/network/13-ap0.network << EOF
[Match]
Name=ap0

[Network]
Address=192.168.10.1/24
DHCPServer=no
IPForward=yes
EOF

# 3. Configurar hostapd
echo -e "${GREEN}📡 Configurando hostapd...${NC}"
cat > /etc/hostapd/hostapd.conf << EOF
# Interface e driver
interface=ap0
driver=nl80211

# Configurações WiFi
ssid=${AP_SSID}
hw_mode=g
channel=6
ieee80211n=1
wmm_enabled=1
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]

# Segurança
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_passphrase=${AP_PASSWORD}
rsn_pairwise=CCMP

# País (ajuste conforme necessário)
country_code=BR
ieee80211d=1

# Configurações adicionais
macaddr_acl=0
ignore_broadcast_ssid=0
EOF

# Apontar para o arquivo de configuração
sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

# 4. Configurar dnsmasq
echo -e "${GREEN}🌐 Configurando DHCP/DNS (dnsmasq)...${NC}"

# Backup da configuração original
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig 2>/dev/null || true

cat > /etc/dnsmasq.conf << EOF
# Interface do AP
interface=ap0
bind-interfaces

# Range DHCP
dhcp-range=192.168.10.10,192.168.10.100,255.255.255.0,24h

# DNS
domain=autocore.local
address=/autocore.local/192.168.10.1

# Configurações DHCP
dhcp-option=3,192.168.10.1
dhcp-option=6,192.168.10.1
server=8.8.8.8
server=8.8.4.4

# Não usar resolv.conf
no-resolv

# Logs
log-queries
log-dhcp
EOF

# 5. Configurar roteamento e NAT
echo -e "${GREEN}🔀 Configurando roteamento...${NC}"

# Habilitar IP forwarding
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-autocore-ap.conf
sysctl -p /etc/sysctl.d/99-autocore-ap.conf

# Configurar NAT (masquerade)
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
iptables -A FORWARD -i ap0 -o wlan0 -j ACCEPT
iptables -A FORWARD -i wlan0 -o ap0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Salvar regras
netfilter-persistent save

# 6. Criar script para criar interface virtual na inicialização
echo -e "${GREEN}📝 Criando script de inicialização...${NC}"
cat > /usr/local/bin/create-ap-interface.sh << 'EOF'
#!/bin/bash
# Criar interface virtual para AP

# Aguardar wlan0 estar pronta
sleep 10

# Criar interface virtual se não existir
if ! ip link show ap0 > /dev/null 2>&1; then
    iw dev wlan0 interface add ap0 type __ap
    ip link set ap0 address $(cat /sys/class/net/wlan0/address | awk -F: '{print $1":"$2":"$3":"$4":"$5":0"$(($6+1))}')
fi

# Subir interface
ip link set ap0 up
ip addr add 192.168.10.1/24 dev ap0 2>/dev/null || true
EOF

chmod +x /usr/local/bin/create-ap-interface.sh

# 7. Criar serviço systemd para criar interface
cat > /etc/systemd/system/create-ap-interface.service << EOF
[Unit]
Description=Create AP interface for AutoCore
After=network.target
Before=hostapd.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/create-ap-interface.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# 8. Script para conectar a rede WiFi cliente
echo -e "${GREEN}📝 Criando script para configurar WiFi cliente...${NC}"
cat > /usr/local/bin/autocore-wifi-connect.sh << 'EOF'
#!/bin/bash

# Script para conectar o AutoCore a uma rede WiFi

SSID="$1"
PASSWORD="$2"

if [ -z "$SSID" ]; then
    echo "Uso: $0 <SSID> <PASSWORD>"
    echo "Exemplo: $0 'MinhaRede' 'MinhaSenha'"
    exit 1
fi

# Configurar wpa_supplicant
cat > /etc/wpa_supplicant/wpa_supplicant.conf << EOL
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=BR

network={
    ssid="$SSID"
    psk="$PASSWORD"
    key_mgmt=WPA-PSK
}
EOL

# Reiniciar serviços
systemctl restart wpa_supplicant
systemctl restart dhcpcd

echo "✅ Configuração WiFi atualizada"
echo "   SSID: $SSID"
echo "   Aguarde alguns segundos para conectar..."
EOF

chmod +x /usr/local/bin/autocore-wifi-connect.sh

# 9. Habilitar serviços
echo -e "${GREEN}🚀 Habilitando serviços...${NC}"
systemctl unmask hostapd
systemctl enable create-ap-interface
systemctl enable hostapd
systemctl enable dnsmasq

# 10. Criar arquivo de informações
cat > /opt/autocore/wifi_info.txt << EOF
========================================
    INFORMAÇÕES DO ACCESS POINT
========================================

SSID: ${AP_SSID}
Senha: ${AP_PASSWORD}
IP do AP: 192.168.10.1

Para conectar dispositivos:
1. Procure a rede: ${AP_SSID}
2. Use a senha: ${AP_PASSWORD}
3. Acesse: http://192.168.10.1:3000

Para conectar o AutoCore a uma rede WiFi:
sudo autocore-wifi-connect.sh "NomeDaRede" "SenhaDaRede"

========================================
EOF

echo ""
echo -e "${GREEN}✅ Configuração concluída!${NC}"
echo ""
echo -e "${BLUE}📡 Access Point configurado:${NC}"
echo "   SSID: ${AP_SSID}"
echo "   Senha: ${AP_PASSWORD}"
echo "   IP: 192.168.10.1"
echo ""
echo -e "${YELLOW}⚠️ O sistema precisa ser reiniciado para aplicar as mudanças${NC}"
echo ""
read -p "Deseja reiniciar agora? (s/N): " REBOOT

if [ "$REBOOT" = "s" ] || [ "$REBOOT" = "S" ]; then
    echo "Reiniciando..."
    reboot
else
    echo "Reinicie manualmente com: sudo reboot"
fi