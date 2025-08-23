#!/bin/bash

# run_with_venv.sh - Executa scripts Python com o .venv do projeto
# Uso: ./run_with_venv.sh <script.py> [argumentos]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
VENV_PATH="$PROJECT_ROOT/.venv"

if [ ! -d "$VENV_PATH" ]; then
    echo "Erro: Virtual environment não encontrado em $VENV_PATH"
    echo "Execute primeiro: ./setup_env.sh"
    exit 1
fi

# Executa o script Python com o ambiente virtual
"$VENV_PATH/bin/python" "$@"