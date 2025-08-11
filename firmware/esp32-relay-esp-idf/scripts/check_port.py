#!/usr/bin/env python3
"""
Verifica se a porta serial está disponível
"""

import sys
import os
import serial.tools.list_ports

class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'

def check_port(port):
    """Verifica se a porta existe e está acessível"""
    
    # Lista todas as portas disponíveis
    ports = list(serial.tools.list_ports.comports())
    
    if not ports:
        print(f"{Colors.RED}❌ Nenhuma porta serial encontrada{Colors.NC}")
        print(f"{Colors.YELLOW}Verifique se o ESP32 está conectado{Colors.NC}")
        return False
    
    # Verifica se a porta especificada existe
    port_found = False
    for p in ports:
        if p.device == port:
            port_found = True
            print(f"{Colors.GREEN}✅ Porta {port} encontrada{Colors.NC}")
            print(f"   Descrição: {p.description}")
            if p.manufacturer:
                print(f"   Fabricante: {p.manufacturer}")
            break
    
    if not port_found:
        print(f"{Colors.RED}❌ Porta {port} não encontrada{Colors.NC}")
        print(f"{Colors.YELLOW}Portas disponíveis:{Colors.NC}")
        for p in ports:
            print(f"  - {p.device}: {p.description}")
        return False
    
    # Verifica permissões
    if not os.access(port, os.R_OK | os.W_OK):
        print(f"{Colors.RED}❌ Sem permissão para acessar {port}{Colors.NC}")
        print(f"{Colors.YELLOW}Tente: sudo chmod 666 {port}{Colors.NC}")
        return False
    
    return True

def main():
    if len(sys.argv) < 2:
        print(f"{Colors.RED}Uso: {sys.argv[0]} <porta>{Colors.NC}")
        sys.exit(1)
    
    port = sys.argv[1]
    
    if check_port(port):
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()