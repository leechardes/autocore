#!/bin/bash

# Verificar integridade do arquivo copiado
echo "========================================"
echo "   VERIFICAÇÃO DE INTEGRIDADE"
echo "========================================"
echo ""

# Pedir o arquivo
read -p "Caminho do arquivo original: " ORIGINAL
read -p "Caminho do arquivo no SD Card: " COPIA

if [ ! -f "$ORIGINAL" ]; then
    echo "❌ Arquivo original não encontrado!"
    exit 1
fi

if [ ! -f "$COPIA" ]; then
    echo "❌ Arquivo copiado não encontrado!"
    exit 1
fi

echo ""
echo "Calculando checksums (pode demorar para arquivos grandes)..."
echo ""

# Calcular MD5
echo -n "MD5 Original:  "
MD5_ORIG=$(md5 -q "$ORIGINAL")
echo "$MD5_ORIG"

echo -n "MD5 Cópia:     "
MD5_COPY=$(md5 -q "$COPIA")
echo "$MD5_COPY"

echo ""
if [ "$MD5_ORIG" == "$MD5_COPY" ]; then
    echo "✅ SUCESSO! Arquivos são idênticos!"
    echo ""
    
    # Mostrar velocidade média
    SIZE=$(du -m "$ORIGINAL" | cut -f1)
    echo "Tamanho do arquivo: ${SIZE} MB"
    
    # Se souber o tempo de cópia
    read -p "Quanto tempo levou a cópia (em segundos)? " TEMPO
    if [[ "$TEMPO" =~ ^[0-9]+$ ]]; then
        SPEED=$(echo "scale=2; $SIZE / $TEMPO" | bc)
        echo "Velocidade média: ${SPEED} MB/s"
        
        if (( $(echo "$SPEED > 10" | bc -l) )); then
            echo "🚀 Velocidade excelente!"
        elif (( $(echo "$SPEED > 5" | bc -l) )); then
            echo "✅ Velocidade boa!"
        else
            echo "⚠️ Velocidade baixa - pode indicar problema no cartão"
        fi
    fi
else
    echo "❌ ERRO! Arquivos são diferentes!"
    echo "O SD Card pode ter problemas de integridade!"
    echo ""
    echo "Recomendações:"
    echo "1. Tente copiar novamente"
    echo "2. Execute o teste completo: sudo ./test_sdcard.sh"
    echo "3. Considere trocar o SD Card"
fi

echo ""
echo "========================================"