#!/usr/bin/env python3
"""
Instalador automático do ESP-IDF
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
    CYAN = '\033[0;36m'
    NC = '\033[0m'

def check_prerequisites():
    """Verifica pré-requisitos"""
    print(f"{Colors.BLUE}🔍 Verificando pré-requisitos...{Colors.NC}")
    
    required = ['git', 'python3', 'cmake']
    missing = []
    
    for tool in required:
        try:
            subprocess.run(['which', tool], check=True, capture_output=True)
            print(f"  ✅ {tool}")
        except:
            print(f"  ❌ {tool}")
            missing.append(tool)
    
    if missing:
        print(f"\n{Colors.RED}❌ Instale os seguintes programas:{Colors.NC}")
        print(f"  {', '.join(missing)}")
        
        if sys.platform == "darwin":  # macOS
            print(f"\n{Colors.YELLOW}No macOS, use Homebrew:{Colors.NC}")
            print(f"  brew install {' '.join(missing)}")
        elif sys.platform == "linux":
            print(f"\n{Colors.YELLOW}No Linux, use apt/yum:{Colors.NC}")
            print(f"  sudo apt install {' '.join(missing)}")
        
        return False
    
    return True

def install_esp_idf():
    """Instala ESP-IDF"""
    esp_path = Path.home() / "esp"
    idf_path = esp_path / "esp-idf"
    
    print(f"\n{Colors.BLUE}📦 Instalando ESP-IDF...{Colors.NC}")
    print(f"  Diretório: {idf_path}")
    
    # Cria diretório
    esp_path.mkdir(exist_ok=True)
    
    if idf_path.exists():
        print(f"{Colors.YELLOW}⚠️  ESP-IDF já existe em {idf_path}{Colors.NC}")
        response = input("Atualizar? (s/N): ")
        if response.lower() != 's':
            return True
        
        # Atualiza
        os.chdir(idf_path)
        subprocess.run(['git', 'pull'], check=True)
    else:
        # Clona repositório
        os.chdir(esp_path)
        print(f"{Colors.BLUE}📥 Clonando ESP-IDF v5.0...{Colors.NC}")
        subprocess.run([
            'git', 'clone', '-b', 'v5.0',
            'https://github.com/espressif/esp-idf.git'
        ], check=True)
    
    # Instala ferramentas
    os.chdir(idf_path)
    print(f"\n{Colors.BLUE}🔧 Instalando ferramentas ESP-IDF...{Colors.NC}")
    subprocess.run(['./install.sh', 'esp32'], check=True)
    
    print(f"\n{Colors.GREEN}✅ ESP-IDF instalado com sucesso!{Colors.NC}")
    print(f"\n{Colors.YELLOW}Para usar, execute em cada terminal:{Colors.NC}")
    print(f"  source {idf_path}/export.sh")
    
    return True

def setup_vscode():
    """Configura VS Code (opcional)"""
    print(f"\n{Colors.BLUE}📝 Configurar VS Code?{Colors.NC}")
    response = input("(s/N): ")
    
    if response.lower() == 's':
        vscode_dir = Path(".vscode")
        vscode_dir.mkdir(exist_ok=True)
        
        # c_cpp_properties.json
        config = {
            "configurations": [{
                "name": "ESP-IDF",
                "includePath": [
                    "${workspaceFolder}/**",
                    "${env:IDF_PATH}/components/**"
                ],
                "defines": [],
                "compilerPath": "${env:IDF_PATH}/tools/xtensa-esp32-elf/bin/xtensa-esp32-elf-gcc",
                "cStandard": "c11",
                "intelliSenseMode": "gcc-x64"
            }],
            "version": 4
        }
        
        import json
        with open(vscode_dir / "c_cpp_properties.json", 'w') as f:
            json.dump(config, f, indent=2)
        
        print(f"{Colors.GREEN}✅ VS Code configurado{Colors.NC}")

def main():
    print(f"{Colors.CYAN}╔══════════════════════════════════════╗{Colors.NC}")
    print(f"{Colors.CYAN}║      ESP-IDF Installation Setup      ║{Colors.NC}")
    print(f"{Colors.CYAN}╚══════════════════════════════════════╝{Colors.NC}\n")
    
    if not check_prerequisites():
        sys.exit(1)
    
    if install_esp_idf():
        setup_vscode()
        print(f"\n{Colors.GREEN}🎉 Instalação concluída!{Colors.NC}")
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()