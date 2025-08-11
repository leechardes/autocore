#!/usr/bin/env python3
"""
Reset o ESP32 via DTR/RTS
"""

import sys
import serial
import time

class Colors:
    YELLOW = '\033[1;33m'
    GREEN = '\033[0;32m'
    RED = '\033[0;31m'
    NC = '\033[0m'

def reset_device(port, baudrate=115200):
    """Envia sinal de reset para o ESP32"""
    try:
        ser = serial.Serial(port, baudrate)
        
        print(f"{Colors.YELLOW}🔄 Enviando reset...{Colors.NC}")
        
        # Sequência de reset do ESP32
        ser.setDTR(False)  # IO0 = HIGH
        ser.setRTS(True)   # EN = LOW (reset)
        time.sleep(0.1)
        ser.setRTS(False)  # EN = HIGH (run)
        
        ser.close()
        
        print(f"{Colors.GREEN}✅ Reset enviado!{Colors.NC}")
        return True
        
    except Exception as e:
        print(f"{Colors.RED}❌ Erro: {e}{Colors.NC}")
        return False

def main():
    if len(sys.argv) < 2:
        print(f"Uso: {sys.argv[0]} <porta>")
        sys.exit(1)
    
    port = sys.argv[1]
    
    if reset_device(port):
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()