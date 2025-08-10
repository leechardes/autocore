#!/bin/bash

# Setup Bluetooth para AutoCore
# Configura o Raspberry Pi para aceitar conexões Bluetooth do app

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📱 Configuração Bluetooth para AutoCore${NC}"
echo "=========================================="

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Este script precisa ser executado como root${NC}"
    echo "Use: sudo $0"
    exit 1
fi

# Obter MAC address Bluetooth
BT_MAC=$(hciconfig hci0 | grep "BD Address" | awk '{print $3}' | tr ':' '')
if [ -z "$BT_MAC" ]; then
    echo -e "${YELLOW}⚠️ Bluetooth não detectado, usando nome padrão${NC}"
    BT_NAME="AutoCore"
else
    BT_NAME="AutoCore_${BT_MAC}"
fi

echo -e "${BLUE}📡 Configurando Bluetooth${NC}"
echo "  Nome: ${BT_NAME}"
echo ""

# 1. Instalar pacotes necessários
echo -e "${GREEN}📦 Instalando pacotes necessários...${NC}"
apt-get update
apt-get install -y bluetooth bluez bluez-tools python3-bluetooth python3-pip rfkill

# Instalar bibliotecas Python
pip3 install pybluez pyserial

# 2. Habilitar Bluetooth
echo -e "${GREEN}🔧 Habilitando Bluetooth...${NC}"
rfkill unblock bluetooth
systemctl enable bluetooth
systemctl start bluetooth

# 3. Configurar Bluetooth para ser descobrível
echo -e "${GREEN}📡 Configurando Bluetooth...${NC}"

# Configurar nome do dispositivo
cat > /etc/machine-info << EOF
PRETTY_HOSTNAME=${BT_NAME}
EOF

# Configurar bluetoothd para modo descobrível
cat > /etc/bluetooth/main.conf << EOF
[General]
Name = ${BT_NAME}
Class = 0x000100
DiscoverableTimeout = 0
AlwaysPairable = true
PairableTimeout = 0

[Policy]
AutoEnable=true
EOF

# 4. Criar serviço Bluetooth para AutoCore
echo -e "${GREEN}📝 Criando serviço Bluetooth...${NC}"

cat > /opt/autocore/bluetooth_service.py << 'EOF'
#!/usr/bin/env python3
"""
AutoCore Bluetooth Service
Permite comunicação com o app Flutter via Bluetooth
"""

import bluetooth
import json
import threading
import time
import logging
import sys
import os
from datetime import datetime

# Adicionar path para importar do projeto
sys.path.append('/opt/autocore/config-app/backend')
sys.path.append('/opt/autocore/database')

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('AutoCoreBT')

class AutoCoreBluetoothService:
    def __init__(self):
        self.server_sock = None
        self.client_sock = None
        self.client_info = None
        self.running = False
        self.uuid = "00001101-0000-1000-8000-00805F9B34FB"  # Serial Port Profile
        
    def start_server(self):
        """Inicia servidor Bluetooth"""
        try:
            # Criar socket Bluetooth
            self.server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
            self.server_sock.bind(("", bluetooth.PORT_ANY))
            self.server_sock.listen(1)
            
            port = self.server_sock.getsockname()[1]
            
            # Anunciar serviço
            bluetooth.advertise_service(
                self.server_sock,
                "AutoCore Control",
                service_id=self.uuid,
                service_classes=[self.uuid, bluetooth.SERIAL_PORT_CLASS],
                profiles=[bluetooth.SERIAL_PORT_PROFILE],
                description="AutoCore Vehicle Gateway Control"
            )
            
            logger.info(f"📱 Servidor Bluetooth iniciado na porta {port}")
            logger.info("⏳ Aguardando conexões...")
            
            self.running = True
            
            while self.running:
                try:
                    # Aguardar conexão
                    self.client_sock, self.client_info = self.server_sock.accept()
                    logger.info(f"✅ Conexão aceita de {self.client_info}")
                    
                    # Processar comandos do cliente
                    self.handle_client()
                    
                except Exception as e:
                    if self.running:
                        logger.error(f"Erro na conexão: {e}")
                    
        except Exception as e:
            logger.error(f"Erro iniciando servidor: {e}")
        finally:
            self.cleanup()
    
    def handle_client(self):
        """Processa comandos do cliente"""
        try:
            while self.running and self.client_sock:
                # Receber dados
                data = self.client_sock.recv(1024)
                if not data:
                    break
                
                # Decodificar comando JSON
                try:
                    command = json.loads(data.decode('utf-8'))
                    logger.info(f"📥 Comando recebido: {command.get('cmd')}")
                    
                    # Processar comando
                    response = self.process_command(command)
                    
                    # Enviar resposta
                    self.send_response(response)
                    
                except json.JSONDecodeError:
                    logger.error("Comando inválido (não é JSON)")
                    self.send_response({"error": "Invalid JSON"})
                    
        except bluetooth.BluetoothError as e:
            logger.error(f"Erro Bluetooth: {e}")
        except Exception as e:
            logger.error(f"Erro processando cliente: {e}")
        finally:
            if self.client_sock:
                self.client_sock.close()
                self.client_sock = None
                logger.info("📴 Cliente desconectado")
    
    def process_command(self, command):
        """Processa comando e retorna resposta"""
        cmd = command.get('cmd')
        params = command.get('params', {})
        
        try:
            if cmd == 'ping':
                return {"status": "ok", "message": "pong", "timestamp": datetime.now().isoformat()}
            
            elif cmd == 'get_status':
                return self.get_system_status()
            
            elif cmd == 'get_devices':
                return self.get_devices_list()
            
            elif cmd == 'relay_control':
                channel = params.get('channel')
                state = params.get('state')
                return self.control_relay(channel, state)
            
            elif cmd == 'get_telemetry':
                return self.get_telemetry_data()
            
            elif cmd == 'execute_macro':
                macro_id = params.get('macro_id')
                return self.execute_macro(macro_id)
            
            elif cmd == 'get_config':
                return self.get_configuration()
            
            else:
                return {"status": "error", "message": f"Unknown command: {cmd}"}
                
        except Exception as e:
            logger.error(f"Erro processando comando {cmd}: {e}")
            return {"status": "error", "message": str(e)}
    
    def send_response(self, response):
        """Envia resposta para o cliente"""
        try:
            if self.client_sock:
                data = json.dumps(response).encode('utf-8')
                self.client_sock.send(data + b'\n')
                logger.info(f"📤 Resposta enviada: {response.get('status')}")
        except Exception as e:
            logger.error(f"Erro enviando resposta: {e}")
    
    def get_system_status(self):
        """Retorna status do sistema"""
        try:
            # Aqui você pode integrar com o backend real
            return {
                "status": "ok",
                "system": {
                    "uptime": os.popen('uptime -p').read().strip(),
                    "temperature": self.get_cpu_temp(),
                    "memory": self.get_memory_usage(),
                    "disk": self.get_disk_usage()
                },
                "services": {
                    "mqtt": self.check_service('mosquitto'),
                    "backend": self.check_service('autocore-config-app'),
                    "gateway": self.check_service('autocore-gateway')
                }
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}
    
    def get_devices_list(self):
        """Retorna lista de dispositivos ESP32"""
        try:
            # Integrar com o banco de dados real
            from shared.repositories import devices
            
            with devices as repo:
                all_devices = repo.get_all()
                return {
                    "status": "ok",
                    "devices": [
                        {
                            "id": d.id,
                            "uuid": d.uuid,
                            "name": d.name,
                            "type": d.type,
                            "status": d.status
                        } for d in all_devices
                    ]
                }
        except Exception as e:
            return {"status": "error", "message": str(e)}
    
    def control_relay(self, channel, state):
        """Controla um relé"""
        try:
            # Publicar comando MQTT
            import paho.mqtt.client as mqtt
            
            client = mqtt.Client()
            client.connect("localhost", 1883, 60)
            
            payload = json.dumps({
                "channel": channel,
                "state": state,
                "source": "bluetooth"
            })
            
            client.publish(f"autocore/relay/{channel}/command", payload)
            client.disconnect()
            
            return {
                "status": "ok",
                "message": f"Relay {channel} set to {state}"
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}
    
    def get_telemetry_data(self):
        """Retorna dados de telemetria"""
        # Implementar integração com telemetria CAN
        return {
            "status": "ok",
            "telemetry": {
                "rpm": 0,
                "speed": 0,
                "temperature": 0,
                "voltage": 12.5
            }
        }
    
    def execute_macro(self, macro_id):
        """Executa uma macro"""
        try:
            # Integrar com executor de macros
            return {
                "status": "ok",
                "message": f"Macro {macro_id} executed"
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}
    
    def get_configuration(self):
        """Retorna configuração do sistema"""
        return {
            "status": "ok",
            "config": {
                "version": "1.0.0",
                "bluetooth_name": bluetooth.read_local_name(),
                "ip_address": os.popen('hostname -I').read().strip()
            }
        }
    
    def get_cpu_temp(self):
        """Obtém temperatura da CPU"""
        try:
            temp = os.popen('vcgencmd measure_temp').read()
            return float(temp.replace('temp=', '').replace("'C\n", ''))
        except:
            return 0
    
    def get_memory_usage(self):
        """Obtém uso de memória"""
        try:
            total = os.popen("free -m | grep Mem | awk '{print $2}'").read().strip()
            used = os.popen("free -m | grep Mem | awk '{print $3}'").read().strip()
            return f"{used}/{total} MB"
        except:
            return "N/A"
    
    def get_disk_usage(self):
        """Obtém uso de disco"""
        try:
            usage = os.popen("df -h / | tail -1 | awk '{print $5}'").read().strip()
            return usage
        except:
            return "N/A"
    
    def check_service(self, service_name):
        """Verifica se um serviço está rodando"""
        try:
            result = os.system(f'systemctl is-active --quiet {service_name}')
            return "running" if result == 0 else "stopped"
        except:
            return "unknown"
    
    def cleanup(self):
        """Limpa recursos"""
        self.running = False
        
        if self.client_sock:
            self.client_sock.close()
        
        if self.server_sock:
            self.server_sock.close()
        
        logger.info("🔚 Servidor Bluetooth encerrado")
    
    def stop(self):
        """Para o servidor"""
        self.running = False

if __name__ == "__main__":
    service = AutoCoreBluetoothService()
    
    try:
        service.start_server()
    except KeyboardInterrupt:
        logger.info("⛔ Interrompido pelo usuário")
    finally:
        service.cleanup()
EOF

chmod +x /opt/autocore/bluetooth_service.py

# 5. Criar serviço systemd
echo -e "${GREEN}🔧 Criando serviço systemd...${NC}"

cat > /etc/systemd/system/autocore-bluetooth.service << EOF
[Unit]
Description=AutoCore Bluetooth Service
After=bluetooth.target
Wants=bluetooth.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/autocore
ExecStart=/usr/bin/python3 /opt/autocore/bluetooth_service.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 6. Configurar para parear sem PIN
echo -e "${GREEN}🔓 Configurando pareamento simplificado...${NC}"

cat > /opt/autocore/bluetooth_agent.sh << 'EOF'
#!/bin/bash
# Agent para aceitar pareamento automaticamente

bluetoothctl << EOC
power on
discoverable on
pairable on
agent NoInputNoOutput
default-agent
EOC
EOF

chmod +x /opt/autocore/bluetooth_agent.sh

# 7. Executar agent na inicialização
cat > /etc/systemd/system/bluetooth-agent.service << EOF
[Unit]
Description=Bluetooth Agent for AutoCore
After=bluetooth.service
Requires=bluetooth.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/opt/autocore/bluetooth_agent.sh

[Install]
WantedBy=multi-user.target
EOF

# 8. Habilitar serviços
echo -e "${GREEN}🚀 Habilitando serviços...${NC}"
systemctl daemon-reload
systemctl enable bluetooth
systemctl enable autocore-bluetooth
systemctl enable bluetooth-agent

# Iniciar serviços
systemctl restart bluetooth
systemctl start bluetooth-agent
systemctl start autocore-bluetooth

# 9. Criar arquivo de informações
cat > /opt/autocore/bluetooth_info.txt << EOF
========================================
    INFORMAÇÕES BLUETOOTH
========================================

Nome Bluetooth: ${BT_NAME}
UUID Serviço: 00001101-0000-1000-8000-00805F9B34FB

Para conectar do app:
1. Ative o Bluetooth no celular
2. Procure por: ${BT_NAME}
3. Parear (sem senha necessária)
4. Conectar no app AutoCore

Comandos disponíveis via Bluetooth:
- ping: Teste de conexão
- get_status: Status do sistema
- get_devices: Lista dispositivos
- relay_control: Controlar relés
- get_telemetry: Dados de telemetria
- execute_macro: Executar macros

========================================
EOF

echo ""
echo -e "${GREEN}✅ Configuração Bluetooth concluída!${NC}"
echo ""
echo -e "${BLUE}📱 Bluetooth configurado:${NC}"
echo "   Nome: ${BT_NAME}"
echo "   Status: $(systemctl is-active autocore-bluetooth)"
echo ""
echo -e "${YELLOW}📱 Para testar do celular:${NC}"
echo "   1. Ative o Bluetooth"
echo "   2. Procure por: ${BT_NAME}"
echo "   3. Pareie e conecte"
echo ""
echo -e "${BLUE}🔍 Ver logs do serviço:${NC}"
echo "   sudo journalctl -u autocore-bluetooth -f"
echo ""