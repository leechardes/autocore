#!/usr/bin/env python3
"""
Verifica se o ambiente ESP-IDF está configurado corretamente
"""

import os
import sys
import subprocess
from pathlib import Path

class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'

def check_esp_idf():
    """Verifica se ESP-IDF está configurado"""
    idf_path = os.environ.get('IDF_PATH')
    
    if not idf_path:
        print(f"{Colors.RED}❌ IDF_PATH não configurado{Colors.NC}")
        print(f"{Colors.YELLOW}Execute: source $HOME/esp/esp-idf/export.sh{Colors.NC}")
        return False
    
    if not Path(idf_path).exists():
        print(f"{Colors.RED}❌ ESP-IDF não encontrado em {idf_path}{Colors.NC}")
        return False
    
    print(f"{Colors.GREEN}✅ ESP-IDF encontrado: {idf_path}{Colors.NC}")
    return True

def check_tools():
    """Verifica ferramentas necessárias"""
    tools = ['idf.py', 'esptool.py', 'cmake', 'ninja']
    missing = []
    
    for tool in tools:
        try:
            subprocess.run(['which', tool], check=True, capture_output=True)
            print(f"{Colors.GREEN}✅ {tool} instalado{Colors.NC}")
        except:
            print(f"{Colors.RED}❌ {tool} não encontrado{Colors.NC}")
            missing.append(tool)
    
    return len(missing) == 0

def check_python_packages():
    """Verifica pacotes Python necessários"""
    # Mapear nomes de importação para nomes de pacote
    package_map = {
        'serial': 'pyserial',
        'cryptography': 'cryptography', 
        'pyparsing': 'pyparsing'
    }
    
    missing = []
    
    for import_name, package_name in package_map.items():
        try:
            __import__(import_name)
            print(f"{Colors.GREEN}✅ {package_name} instalado{Colors.NC}")
        except ImportError:
            print(f"{Colors.RED}❌ {package_name} não instalado{Colors.NC}")
            missing.append(package_name)
    
    if missing:
        print(f"{Colors.YELLOW}Instale com: pip install {' '.join(missing)}{Colors.NC}")
        return False
    
    return True

def main():
    print(f"{Colors.BLUE}🔍 Verificando ambiente ESP-IDF...{Colors.NC}\n")
    
    checks = [
        ("ESP-IDF", check_esp_idf()),
        ("Ferramentas", check_tools()),
        ("Pacotes Python", check_python_packages())
    ]
    
    all_ok = all(check[1] for check in checks)
    
    print(f"\n{Colors.BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.NC}")
    
    if all_ok:
        print(f"{Colors.GREEN}✅ Ambiente configurado corretamente!{Colors.NC}")
        sys.exit(0)
    else:
        print(f"{Colors.RED}❌ Ambiente precisa de configuração{Colors.NC}")
        print(f"{Colors.YELLOW}Execute 'make setup' para configurar{Colors.NC}")
        sys.exit(1)

if __name__ == "__main__":
    main()