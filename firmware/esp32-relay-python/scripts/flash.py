#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Flash ESP32 - Script Simples
Instala firmware MicroPython usando esptool
"""

import os
import sys
import subprocess
import time

# Configurações
PORT = "/dev/cu.usbserial-0001"
BAUD_RATE = 115200
FIRMWARE_PATH = "firmware/esp32-micropython.bin"

def check_esptool():
    """Verifica se esptool está instalado"""
    try:
        subprocess.run(['esptool.py', '--help'], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Erro: esptool não está instalado!")
        print("Execute: pip3 install esptool")
        return False

def check_firmware():
    """Verifica se firmware existe"""
    if not os.path.exists(FIRMWARE_PATH):
        print(f"❌ Erro: Firmware não encontrado em {FIRMWARE_PATH}")
        print("💡 Baixe o firmware MicroPython para ESP32")
        return False
    
    # Verificar tamanho
    size = os.path.getsize(FIRMWARE_PATH)
    print(f"📦 Firmware encontrado: {size:,} bytes")
    return True

def erase_flash():
    """Apaga flash do ESP32"""
    print("🗑️ Apagando flash...")
    
    try:
        cmd = ['esptool.py', '--chip', 'esp32', '--port', PORT, 'erase_flash']
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Flash apagado!")
            return True
        else:
            print("❌ Erro apagando flash:")
            print(result.stderr)
            return False
            
    except Exception as e:
        print(f"❌ Erro: {e}")
        return False

def flash_firmware():
    """Instala firmware MicroPython"""
    print("📤 Instalando firmware...")
    
    try:
        cmd = [
            'esptool.py', 
            '--chip', 'esp32', 
            '--port', PORT, 
            '--baud', str(BAUD_RATE),
            'write_flash', 
            '-z', 
            '0x1000', 
            FIRMWARE_PATH
        ]
        
        print(f"🔧 Executando: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Firmware instalado com sucesso!")
            return True
        else:
            print("❌ Erro instalando firmware:")
            print(result.stderr)
            return False
            
    except Exception as e:
        print(f"❌ Erro: {e}")
        return False

def wait_boot():
    """Aguarda boot do ESP32"""
    print("⏱️ Aguardando boot do ESP32...")
    for i in range(10, 0, -1):
        print(f"   {i} segundos...", end='\r')
        time.sleep(1)
    print("   Boot completo!    ")

def main():
    """Função principal"""
    print("=" * 40)
    print("⚡ ESP32 Flash Script")
    print("=" * 40)
    
    # Verificações
    if not check_esptool():
        sys.exit(1)
    
    if not check_firmware():
        sys.exit(1)
    
    # Confirmação
    print("⚠️  Isso apagará todo o conteúdo do ESP32!")
    confirm = input("Continuar? (s/N): ").lower()
    if confirm != 's':
        print("🛑 Operação cancelada")
        sys.exit(0)
    
    # Flash process
    print("🚀 Iniciando flash...")
    
    if erase_flash():
        if flash_firmware():
            wait_boot()
            print("🎉 Flash concluído com sucesso!")
            print("💡 Execute 'make deploy' para enviar o código")
        else:
            print("💥 Falha no flash!")
            sys.exit(1)
    else:
        print("💥 Falha apagando flash!")
        sys.exit(1)

if __name__ == "__main__":
    main()