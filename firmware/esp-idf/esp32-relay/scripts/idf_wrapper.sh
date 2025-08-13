#!/bin/bash
# Wrapper para executar comandos ESP-IDF

# Verifica se IDF_PATH está configurado
if [ -z "$IDF_PATH" ]; then
    # Tenta carregar do local padrão
    if [ -f "$HOME/esp/esp-idf/export.sh" ]; then
        source $HOME/esp/esp-idf/export.sh
    else
        echo "❌ ESP-IDF não encontrado"
        echo "Execute: make install"
        exit 1
    fi
fi

# Executa o comando passado
exec "$@"