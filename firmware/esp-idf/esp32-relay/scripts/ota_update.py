#!/usr/bin/env python3
"""
Script para atualização OTA do ESP32
"""

import os
import sys
import requests
import json
from pathlib import Path

class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'

def find_device_ip():
    """Encontra o IP do ESP32 na rede"""
    print(f"{Colors.BLUE}🔍 Procurando ESP32 na rede...{Colors.NC}")
    
    # Tenta ler do arquivo de configuração
    config_file = Path("ota_config.json")
    if config_file.exists():
        with open(config_file, 'r') as f:
            config = json.load(f)
            return config.get("device_ip")
    
    # Solicita ao usuário
    ip = input("Digite o IP do ESP32: ")
    
    # Salva para próxima vez
    with open(config_file, 'w') as f:
        json.dump({"device_ip": ip}, f)
    
    return ip

def upload_firmware(ip, firmware_path):
    """Faz upload do firmware via OTA"""
    url = f"http://{ip}/ota"
    
    if not Path(firmware_path).exists():
        print(f"{Colors.RED}❌ Firmware não encontrado: {firmware_path}{Colors.NC}")
        return False
    
    print(f"{Colors.BLUE}📤 Enviando firmware para {ip}...{Colors.NC}")
    
    try:
        with open(firmware_path, 'rb') as f:
            files = {'firmware': f}
            response = requests.post(url, files=files, timeout=60)
        
        if response.status_code == 200:
            print(f"{Colors.GREEN}✅ OTA concluído com sucesso!{Colors.NC}")
            print(f"{Colors.YELLOW}O ESP32 está reiniciando...{Colors.NC}")
            return True
        else:
            print(f"{Colors.RED}❌ Erro OTA: {response.status_code}{Colors.NC}")
            return False
            
    except requests.exceptions.ConnectionError:
        print(f"{Colors.RED}❌ Não foi possível conectar em {ip}{Colors.NC}")
        print(f"{Colors.YELLOW}Verifique se o ESP32 está na rede{Colors.NC}")
        return False
    except Exception as e:
        print(f"{Colors.RED}❌ Erro: {e}{Colors.NC}")
        return False

def main():
    print(f"{Colors.CYAN}╔══════════════════════════════════════╗{Colors.NC}")
    print(f"{Colors.CYAN}║         ESP32 OTA Update             ║{Colors.NC}")
    print(f"{Colors.CYAN}╚══════════════════════════════════════╝{Colors.NC}\n")
    
    # Verifica se firmware existe
    firmware = "build/esp32-relay.bin"
    if not Path(firmware).exists():
        print(f"{Colors.RED}❌ Execute 'make build' primeiro{Colors.NC}")
        sys.exit(1)
    
    # Encontra dispositivo
    ip = find_device_ip()
    if not ip:
        print(f"{Colors.RED}❌ IP do dispositivo não configurado{Colors.NC}")
        sys.exit(1)
    
    # Faz upload
    if upload_firmware(ip, firmware):
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()