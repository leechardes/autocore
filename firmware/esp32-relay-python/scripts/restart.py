#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Restart ESP32 - Script Simples
Reinicia ESP32 via software reset
"""

import serial
import time
import sys

# Configurações
PORT = "/dev/cu.usbserial-0001"
BAUD_RATE = 115200

def restart_esp32():
    """Reinicia ESP32 via software"""
    try:
        print("🔄 Conectando ao ESP32...")
        ser = serial.Serial(PORT, BAUD_RATE, timeout=2)
        
        print("📤 Enviando comando de reset...")
        
        # Enviar Ctrl+C para parar execução atual
        ser.write(b'\x03')
        time.sleep(0.5)
        
        # Enviar comando de reset
        ser.write(b'import machine\r\n')
        time.sleep(0.5)
        ser.write(b'machine.reset()\r\n')
        time.sleep(0.5)
        
        # Fechar conexão
        ser.close()
        
        print("✅ Comando de reset enviado!")
        print("⏱️ ESP32 reiniciando...")
        
        # Aguardar boot
        for i in range(5, 0, -1):
            print(f"   {i} segundos...", end='\r')
            time.sleep(1)
        
        print("   Boot completo!    ")
        return True
        
    except serial.SerialException as e:
        print(f"❌ Erro de conexão serial: {e}")
        print("💡 Verifique se ESP32 está conectado e porta correta")
        return False
    except Exception as e:
        print(f"❌ Erro: {e}")
        return False

def main():
    """Função principal"""
    print("=" * 30)
    print("🔄 ESP32 Restart")
    print("=" * 30)
    
    if restart_esp32():
        print("🎉 ESP32 reiniciado com sucesso!")
        print("💡 Execute 'make monitor' para ver os logs")
    else:
        print("💥 Falha no restart!")
        sys.exit(1)

if __name__ == "__main__":
    main()