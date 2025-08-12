#!/usr/bin/env python3
"""
Monitor serial simples para ESP32
"""

import serial
import sys
import time

PORT = "/dev/cu.usbserial-10"
BAUD = 115200

def monitor():
    try:
        print(f"Conectando a {PORT} @ {BAUD} baud...")
        ser = serial.Serial(PORT, BAUD, timeout=1)
        
        print("Conectado! Pressione Ctrl+C para sair\n")
        print("-" * 60)
        
        # Limpar buffer
        ser.reset_input_buffer()
        
        while True:
            if ser.in_waiting:
                try:
                    line = ser.readline().decode('utf-8', errors='ignore').strip()
                    if line:
                        print(f"{time.strftime('%H:%M:%S')} > {line}")
                except Exception as e:
                    print(f"Erro decodificando: {e}")
            
            time.sleep(0.01)
            
    except serial.SerialException as e:
        print(f"Erro de serial: {e}")
    except KeyboardInterrupt:
        print("\n\nMonitor encerrado pelo usuário")
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()
            print("Porta serial fechada")

if __name__ == "__main__":
    monitor()