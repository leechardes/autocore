#!/usr/bin/env python3
"""
Script executado antes do build para preparar o ambiente
"""

import os
import json
import datetime
from pathlib import Path

class Colors:
    BLUE = '\033[0;34m'
    YELLOW = '\033[1;33m'
    NC = '\033[0m'

def update_version():
    """Atualiza versão e timestamp do build"""
    version_file = Path("main/version.h")
    
    # Lê versão atual ou cria nova
    if version_file.exists():
        with open(version_file, 'r') as f:
            content = f.read()
            # Extrai build number
            import re
            match = re.search(r'BUILD_NUMBER\s+(\d+)', content)
            build_num = int(match.group(1)) + 1 if match else 1
    else:
        build_num = 1
    
    # Gera novo arquivo de versão
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    version_content = f"""// Auto-generated version file
#ifndef VERSION_H
#define VERSION_H

#define FIRMWARE_VERSION "2.0.0"
#define BUILD_NUMBER {build_num}
#define BUILD_TIMESTAMP "{timestamp}"
#define BUILD_DATE __DATE__
#define BUILD_TIME __TIME__

#endif // VERSION_H
"""
    
    with open(version_file, 'w') as f:
        f.write(version_content)
    
    print(f"{Colors.BLUE}📝 Build #{build_num} - {timestamp}{Colors.NC}")

def check_config():
    """Verifica configurações do projeto"""
    sdkconfig = Path("sdkconfig")
    
    if not sdkconfig.exists():
        print(f"{Colors.YELLOW}⚠️  sdkconfig não encontrado, usando defaults{Colors.NC}")
        # Copia defaults se existir
        defaults = Path("sdkconfig.defaults")
        if defaults.exists():
            import shutil
            shutil.copy(defaults, sdkconfig)

def create_build_info():
    """Cria arquivo com informações do build"""
    build_info = {
        "timestamp": datetime.datetime.now().isoformat(),
        "user": os.environ.get("USER", "unknown"),
        "host": os.uname().nodename,
        "idf_version": os.environ.get("IDF_VERSION", "unknown")
    }
    
    build_dir = Path("build")
    build_dir.mkdir(exist_ok=True)
    
    with open(build_dir / "build_info.json", 'w') as f:
        json.dump(build_info, f, indent=2)

def main():
    print(f"{Colors.BLUE}🔧 Preparando build...{Colors.NC}")
    
    update_version()
    check_config()
    create_build_info()
    
    print(f"{Colors.BLUE}✅ Pre-build concluído{Colors.NC}")

if __name__ == "__main__":
    main()