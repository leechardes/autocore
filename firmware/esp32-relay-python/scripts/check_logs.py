#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Check ESP32 Logs - Script simples para ver output inicial
"""

import serial
import time
import sys

PORT = "/dev/cu.usbserial-0001"
BAUD_RATE = 115200

def check_logs():
    """Verifica logs iniciais do ESP32"""
    try:
        print("📡 Conectando ao ESP32...")
        ser = serial.Serial(PORT, BAUD_RATE, timeout=2)
        
        print("📝 Lendo logs (15 segundos)...")
        print("=" * 50)
        
        start_time = time.time()
        while time.time() - start_time < 15:
            if ser.in_waiting:
                try:
                    line = ser.readline().decode('utf-8', errors='ignore').strip()
                    if line:
                        print(f"[{time.strftime('%H:%M:%S')}] {line}")
                except:
                    pass
        
        print("=" * 50)
        print("✅ Verificação concluída!")
        ser.close()
        
    except Exception as e:
        print(f"❌ Erro: {e}")
        sys.exit(1)

if __name__ == "__main__":
    check_logs()