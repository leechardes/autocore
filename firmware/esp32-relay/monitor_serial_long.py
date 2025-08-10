#!/usr/bin/env python3
import serial
import time
import sys

PORT = '/dev/cu.usbserial-0001'
BAUD = 115200

try:
    # Abrir porta serial
    ser = serial.Serial(PORT, BAUD, timeout=1)
    print(f"Monitorando {PORT} em {BAUD} baud...")
    print("=" * 60)
    print("Pressione Ctrl+C para parar")
    print("=" * 60)
    
    # Ler continuamente
    while True:
        if ser.in_waiting > 0:
            line = ser.readline()
            try:
                print(line.decode('utf-8').rstrip())
            except:
                print(line)
    
except serial.SerialException as e:
    print(f"Erro ao abrir porta serial: {e}")
    sys.exit(1)
except KeyboardInterrupt:
    print("\nInterrompido pelo usuário")
    if 'ser' in locals():
        ser.close()