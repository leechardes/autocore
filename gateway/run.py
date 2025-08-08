#!/usr/bin/env python3
"""
Ponto de entrada principal do AutoCore Gateway
"""
import sys
import asyncio
from pathlib import Path

# Adicionar src ao path
sys.path.insert(0, str(Path(__file__).parent / "src"))

if __name__ == "__main__":
    from main import main
    
    exit_code = asyncio.run(main())
    sys.exit(exit_code)