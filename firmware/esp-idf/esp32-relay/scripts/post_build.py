#!/usr/bin/env python3
"""
Script executado após o build para análise e relatórios
"""

import os
import json
from pathlib import Path

class Colors:
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'

def analyze_binary():
    """Analisa o binário gerado"""
    binary_path = Path("build/esp32-relay.bin")
    
    if not binary_path.exists():
        print(f"{Colors.YELLOW}⚠️  Binário não encontrado{Colors.NC}")
        return
    
    size = binary_path.stat().st_size
    size_kb = size / 1024
    size_mb = size_kb / 1024
    
    print(f"\n{Colors.CYAN}📊 Análise do Firmware:{Colors.NC}")
    print(f"  📦 Tamanho: {size:,} bytes ({size_kb:.1f} KB / {size_mb:.2f} MB)")
    
    # Verifica se cabe na partição
    max_size = 1310720  # 1.25MB default app partition
    usage = (size / max_size) * 100
    
    if usage < 70:
        color = Colors.GREEN
    elif usage < 90:
        color = Colors.YELLOW
    else:
        color = Colors.YELLOW
    
    print(f"  💾 Uso da partição: {color}{usage:.1f}%{Colors.NC}")
    
    # Mostra partições
    map_file = Path("build/esp32-relay.map")
    if map_file.exists():
        print(f"  🗺️  Map file: {map_file}")

def show_flash_args():
    """Mostra argumentos para flash manual"""
    flash_args = Path("build/flash_args")
    
    if flash_args.exists():
        print(f"\n{Colors.BLUE}📝 Comando de flash manual:{Colors.NC}")
        with open(flash_args, 'r') as f:
            args = f.read().strip()
            print(f"  esptool.py {args}")

def generate_summary():
    """Gera resumo do build"""
    build_info_path = Path("build/build_info.json")
    
    if build_info_path.exists():
        with open(build_info_path, 'r') as f:
            info = json.load(f)
        
        print(f"\n{Colors.GREEN}✅ Build Summary:{Colors.NC}")
        print(f"  📅 Timestamp: {info.get('timestamp', 'N/A')}")
        print(f"  👤 User: {info.get('user', 'N/A')}")
        print(f"  💻 Host: {info.get('host', 'N/A')}")

def check_warnings():
    """Verifica warnings do build"""
    log_file = Path("build/compile_commands.json")
    
    if log_file.exists():
        print(f"\n{Colors.YELLOW}⚠️  Para verificar warnings:{Colors.NC}")
        print(f"  grep -i warning build/build.log")

def main():
    print(f"\n{Colors.BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.NC}")
    
    analyze_binary()
    show_flash_args()
    generate_summary()
    check_warnings()
    
    print(f"\n{Colors.GREEN}🎉 Build concluído com sucesso!{Colors.NC}")
    print(f"{Colors.CYAN}Use 'make flash' para gravar no ESP32{Colors.NC}")

if __name__ == "__main__":
    main()