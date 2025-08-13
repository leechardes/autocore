#!/usr/bin/env python3
"""
Lista portas seriais disponíveis com informações detalhadas
"""

import sys
import os

try:
    import serial.tools.list_ports
except ImportError:
    print("❌ Módulo pyserial não instalado!")
    print("   Instale com: pip install pyserial")
    sys.exit(1)

def get_port_info(port):
    """Retorna informações detalhadas da porta"""
    info = {
        'device': port.device,
        'description': port.description,
        'hwid': port.hwid,
        'manufacturer': port.manufacturer,
        'product': port.product,
        'serial': port.serial_number
    }
    
    # Identifica chips ESP32
    if 'CP210' in str(port.description) or 'Silicon Labs' in str(port.manufacturer):
        info['chip'] = 'ESP32 (provável - CP2102/CP2104)'
    elif 'CH340' in str(port.description):
        info['chip'] = 'ESP32/ESP8266 (provável - CH340)'
    elif 'FTDI' in str(port.description) or 'FT232' in str(port.description):
        info['chip'] = 'ESP32 (provável - FTDI)'
    else:
        info['chip'] = ''
    
    return info

def list_ports():
    """Lista todas as portas seriais disponíveis"""
    ports = serial.tools.list_ports.comports()
    
    if not ports:
        print("❌ Nenhuma porta serial encontrada")
        return []
    
    print("\n🔌 Portas Seriais Disponíveis:")
    print("=" * 80)
    
    port_list = []
    for i, port in enumerate(ports, 1):
        info = get_port_info(port)
        port_list.append(info)
        
        print(f"\n{i}. {info['device']}")
        print(f"   📝 Descrição: {info['description']}")
        
        if info['manufacturer']:
            print(f"   🏭 Fabricante: {info['manufacturer']}")
        
        if info['product']:
            print(f"   📦 Produto: {info['product']}")
        
        if info['serial']:
            print(f"   🔢 Serial: {info['serial']}")
        
        if info['chip']:
            print(f"   🎯 {info['chip']}")
    
    print("\n" + "=" * 80)
    
    # Detecta ESP32 automaticamente
    esp_ports = [p for p in port_list if p['chip']]
    if esp_ports:
        print("\n✨ ESP32 detectado provavelmente em:")
        for port in esp_ports:
            print(f"   ➡️  {port['device']}")
    
    return port_list

def select_port():
    """Permite seleção interativa de porta"""
    ports = list_ports()
    
    if not ports:
        return None
    
    print("\n" + "=" * 80)
    try:
        choice = input("Digite o número da porta desejada (ou Enter para cancelar): ").strip()
        
        if not choice:
            return None
        
        port_num = int(choice) - 1
        if 0 <= port_num < len(ports):
            selected = ports[port_num]['device']
            print(f"\n✅ Porta selecionada: {selected}")
            
            print("\n📋 Para usar esta porta:")
            print(f"   export PORT={selected}")
            print(f"   make flash")
            print("\nOu diretamente:")
            print(f"   make PORT={selected} flash")
            
            return selected
        else:
            print("❌ Seleção inválida")
            return None
            
    except (ValueError, KeyboardInterrupt):
        print("\n❌ Operação cancelada")
        return None

def main():
    """Função principal"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Lista e seleciona portas seriais')
    parser.add_argument('-s', '--select', action='store_true', 
                       help='Modo de seleção interativa')
    parser.add_argument('-j', '--json', action='store_true',
                       help='Saída em formato JSON')
    
    args = parser.parse_args()
    
    if args.json:
        import json
        ports = serial.tools.list_ports.comports()
        port_list = [get_port_info(port) for port in ports]
        print(json.dumps(port_list, indent=2))
    elif args.select:
        select_port()
    else:
        list_ports()

if __name__ == "__main__":
    main()