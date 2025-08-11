#!/usr/bin/env python3
"""
Valida estrutura e configuração do projeto ESP-IDF
"""

import os
from pathlib import Path

class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'

def validate_structure():
    """Valida estrutura de diretórios"""
    print(f"{Colors.BLUE}📁 Validando estrutura do projeto...{Colors.NC}")
    
    required_files = [
        "CMakeLists.txt",
        "sdkconfig.defaults",
        "partitions.csv",
        "main/CMakeLists.txt",
        "main/main.c"
    ]
    
    missing = []
    for file in required_files:
        if Path(file).exists():
            print(f"  ✅ {file}")
        else:
            print(f"  ❌ {file}")
            missing.append(file)
    
    return len(missing) == 0

def validate_config():
    """Valida configuração do projeto"""
    print(f"\n{Colors.BLUE}⚙️  Validando configuração...{Colors.NC}")
    
    # Verifica CMakeLists.txt principal
    cmake = Path("CMakeLists.txt")
    if cmake.exists():
        content = cmake.read_text()
        if "project(esp32-relay)" in content:
            print(f"  ✅ Nome do projeto correto")
        else:
            print(f"  ❌ Nome do projeto incorreto")
            return False
    
    # Verifica partições
    partitions = Path("partitions.csv")
    if partitions.exists():
        content = partitions.read_text()
        if "app0" in content and "app1" in content:
            print(f"  ✅ Partições OTA configuradas")
        else:
            print(f"  ⚠️  OTA não configurado")
    
    return True

def validate_code():
    """Valida código fonte"""
    print(f"\n{Colors.BLUE}📝 Validando código...{Colors.NC}")
    
    main_file = Path("main/main.c")
    if main_file.exists():
        content = main_file.read_text()
        
        # Verifica funções essenciais
        functions = ["app_main", "wifi_init", "http_server_init", "mqtt_init"]
        for func in functions:
            if func in content:
                print(f"  ✅ {func}() encontrada")
            else:
                print(f"  ⚠️  {func}() não encontrada")
    
    return True

def check_dependencies():
    """Verifica dependências do projeto"""
    print(f"\n{Colors.BLUE}📦 Verificando dependências...{Colors.NC}")
    
    # Verifica componentes IDF necessários
    components = [
        "esp_wifi",
        "esp_http_server",
        "mqtt",
        "nvs_flash"
    ]
    
    cmake = Path("main/CMakeLists.txt")
    if cmake.exists():
        content = cmake.read_text()
        for comp in components:
            if comp in content:
                print(f"  ✅ {comp}")
            else:
                print(f"  ⚠️  {comp} não incluído")
    
    return True

def main():
    print(f"{Colors.CYAN}╔══════════════════════════════════════╗{Colors.NC}")
    print(f"{Colors.CYAN}║      Project Validation Check        ║{Colors.NC}")
    print(f"{Colors.CYAN}╚══════════════════════════════════════╝{Colors.NC}\n")
    
    checks = [
        validate_structure(),
        validate_config(),
        validate_code(),
        check_dependencies()
    ]
    
    print(f"\n{Colors.BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.NC}")
    
    if all(checks):
        print(f"{Colors.GREEN}✅ Projeto válido e pronto para build!{Colors.NC}")
        return 0
    else:
        print(f"{Colors.YELLOW}⚠️  Projeto precisa de ajustes{Colors.NC}")
        return 1

if __name__ == "__main__":
    exit(main())