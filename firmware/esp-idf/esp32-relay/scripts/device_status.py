#!/usr/bin/env python3
"""
Mostra status do ESP32 conectado via serial
"""

import sys
import serial
import time
import json

class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'

def get_device_status(port, baudrate=115200):
    """Obtém status do dispositivo via serial"""
    try:
        # Conecta na serial
        ser = serial.Serial(port, baudrate, timeout=2)
        
        print(f"{Colors.CYAN}📡 Conectando em {port}...{Colors.NC}")
        
        # Envia comando de status (se implementado)
        ser.write(b'\r\n')
        time.sleep(0.5)
        ser.write(b'status\r\n')
        
        # Lê resposta
        response = ""
        start_time = time.time()
        while time.time() - start_time < 3:
            if ser.in_waiting:
                data = ser.readline().decode('utf-8', errors='ignore')
                response += data
                print(data.strip())
        
        ser.close()
        
        # Tenta parsear JSON se houver
        if '{' in response and '}' in response:
            start = response.find('{')
            end = response.rfind('}') + 1
            json_str = response[start:end]
            try:
                status = json.loads(json_str)
                print(f"\n{Colors.GREEN}📊 Status do Dispositivo:{Colors.NC}")
                for key, value in status.items():
                    print(f"  {key}: {value}")
            except:
                pass
        
        return True
        
    except serial.SerialException as e:
        print(f"{Colors.RED}❌ Erro ao conectar: {e}{Colors.NC}")
        return False
    except Exception as e:
        print(f"{Colors.RED}❌ Erro: {e}{Colors.NC}")
        return False

def main():
    if len(sys.argv) < 2:
        print(f"{Colors.RED}Uso: {sys.argv[0]} <porta>{Colors.NC}")
        sys.exit(1)
    
    port = sys.argv[1]
    
    print(f"{Colors.CYAN}╔══════════════════════════════════════╗{Colors.NC}")
    print(f"{Colors.CYAN}║       ESP32 Device Status           ║{Colors.NC}")
    print(f"{Colors.CYAN}╚══════════════════════════════════════╝{Colors.NC}\n")
    
    if get_device_status(port):
        print(f"\n{Colors.GREEN}✅ Status obtido com sucesso{Colors.NC}")
    else:
        print(f"\n{Colors.YELLOW}⚠️  Não foi possível obter status completo{Colors.NC}")
        print(f"{Colors.YELLOW}Verifique se o firmware está rodando{Colors.NC}")

if __name__ == "__main__":
    main()