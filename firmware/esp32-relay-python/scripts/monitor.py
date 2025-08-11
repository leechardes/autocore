#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Monitor ESP32 - Script Simples
Monitor serial com logs em tempo real
"""

import serial
import sys
import time
import datetime

# Configurações
PORT = "/dev/cu.usbserial-0001"
BAUD_RATE = 115200

def connect_serial():
    """Conecta ao ESP32 via serial"""
    try:
        ser = serial.Serial(PORT, BAUD_RATE, timeout=1)
        print(f"✅ Conectado a {PORT} @ {BAUD_RATE}")
        return ser
    except serial.SerialException as e:
        print(f"❌ Erro conectando: {e}")
        print("💡 Verifique se a porta está correta e ESP32 conectado")
        return None

def format_timestamp():
    """Gera timestamp formatado"""
    return datetime.datetime.now().strftime("%H:%M:%S")

def monitor_serial(ser):
    """Monitor com logs formatados"""
    print("🔍 Monitor ESP32 ativo - Pressione Ctrl+C para sair")
    print("-" * 60)
    
    try:
        while True:
            if ser.in_waiting > 0:
                # Ler linha
                line = ser.readline().decode('utf-8', errors='ignore').strip()
                
                if line:
                    # Timestamp
                    timestamp = format_timestamp()
                    
                    # Colorir por tipo de mensagem
                    if "❌" in line or "ERROR" in line.upper():
                        color = "\033[0;31m"  # Vermelho
                    elif "✅" in line or "SUCCESS" in line.upper():
                        color = "\033[0;32m"  # Verde
                    elif "⚠️" in line or "WARNING" in line.upper():
                        color = "\033[1;33m"  # Amarelo
                    elif "📡" in line or "📱" in line:
                        color = "\033[0;34m"  # Azul
                    else:
                        color = "\033[0m"     # Normal
                    
                    # Imprimir com timestamp
                    print(f"[{timestamp}] {color}{line}\033[0m")
            
            time.sleep(0.1)
            
    except KeyboardInterrupt:
        print("\n🛑 Monitor interrompido pelo usuário")
    except Exception as e:
        print(f"\n❌ Erro no monitor: {e}")

def send_command(ser):
    """Envia comando para ESP32 (futuro)"""
    # Funcionalidade para enviar comandos
    pass

def main():
    """Função principal"""
    print("=" * 40)
    print("📺 ESP32 Monitor")
    print("=" * 40)
    
    # Conectar
    ser = connect_serial()
    if not ser:
        sys.exit(1)
    
    try:
        # Enviar soft reset para iniciar logs
        print("🔄 Enviando soft reset...")
        ser.write(b'\x03\x04')  # Ctrl+C + Ctrl+D
        time.sleep(1)
        
        # Monitor
        monitor_serial(ser)
        
    finally:
        if ser:
            ser.close()
            print("🔌 Conexão serial fechada")

if __name__ == "__main__":
    main()