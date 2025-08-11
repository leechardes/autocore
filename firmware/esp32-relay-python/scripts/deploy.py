#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Deploy ESP32 - Script Simples
Deploy main.py usando ampy oficial
"""

import os
import sys
import subprocess
import time

# Configurações
PORT = "/dev/cu.usbserial-0001"
BAUD_RATE = 115200

def check_file_exists():
    """Verifica se main.py existe"""
    if not os.path.exists("main.py"):
        print("❌ Erro: main.py não encontrado!")
        return False
    return True

def check_ampy():
    """Verifica se ampy está instalado"""
    try:
        subprocess.run(['ampy', '--version'], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Erro: ampy não está instalado!")
        print("Execute: pip3 install adafruit-ampy")
        return False

def deploy_main():
    """Faz deploy do main.py"""
    print("🚀 Iniciando deploy...")
    
    try:
        # Upload main.py
        cmd = ['ampy', '--port', PORT, '--baud', str(BAUD_RATE), 'put', 'main.py']
        print(f"📤 Executando: {' '.join(cmd)}")
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Deploy concluído com sucesso!")
            return True
        else:
            print("❌ Erro no deploy:")
            print(result.stderr)
            return False
            
    except Exception as e:
        print(f"❌ Erro: {e}")
        return False

def main():
    """Função principal"""
    print("=" * 40)
    print("📡 ESP32 Deploy Script")
    print("=" * 40)
    
    # Verificações
    if not check_ampy():
        sys.exit(1)
    
    if not check_file_exists():
        sys.exit(1)
    
    # Deploy
    if deploy_main():
        print("🎉 Deploy finalizado!")
        print("💡 Execute 'make monitor' para ver os logs")
    else:
        print("💥 Deploy falhou!")
        sys.exit(1)

if __name__ == "__main__":
    main()