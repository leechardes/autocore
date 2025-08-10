#!/usr/bin/env python3
import serial
import time
import sys

PORT = '/dev/cu.usbserial-0001'
BAUD = 115200

try:
    # Abrir porta serial
    ser = serial.Serial(PORT, BAUD, timeout=0.1)
    print(f"Monitorando {PORT} em {BAUD} baud...")
    print("=" * 60)
    print("Tente acessar http://192.168.4.1 agora")
    print("=" * 60)
    
    buffer = ""
    while True:
        if ser.in_waiting > 0:
            data = ser.read(ser.in_waiting)
            try:
                text = data.decode('utf-8', errors='ignore')
                buffer += text
                
                # Procurar por linhas completas
                while '\n' in buffer:
                    line, buffer = buffer.split('\n', 1)
                    line = line.strip()
                    if line and not line == "4.1":  # Ignorar o bug do 4.1
                        print(line)
            except:
                pass
        time.sleep(0.01)
    
except serial.SerialException as e:
    print(f"Erro ao abrir porta serial: {e}")
    sys.exit(1)
except KeyboardInterrupt:
    print("\nInterrompido pelo usuário")
    if 'ser' in locals():
        ser.close()