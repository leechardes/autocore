#!/bin/bash

# Monitor de velocidade de cópia para macOS
echo "Monitorando velocidade de transferência do SD Card..."
echo "Pressione Ctrl+C para parar"
echo ""

# Identificar o SD Card (geralmente disk4)
DISK_NUM=$(diskutil list | grep "external, physical" | tail -1 | awk '{print $1}' | sed 's/\/dev\/disk//')

if [ -z "$DISK_NUM" ]; then
    echo "SD Card não detectado. Listando discos:"
    diskutil list
    echo ""
    read -p "Digite o número do disco (ex: 4): " DISK_NUM
fi

echo "Monitorando disco: /dev/disk${DISK_NUM}"
echo "========================================="
echo ""

# Loop de monitoramento
while true; do
    # Pegar estatísticas de I/O
    iostat -d -w 1 -c 1 disk${DISK_NUM} | tail -1 | while read disk kb_t tps mb_s; do
        if [[ $mb_s =~ ^[0-9]+\.?[0-9]*$ ]]; then
            # Converter KB/s para MB/s se necessário
            mb_per_sec=$(echo "scale=2; $mb_s" | bc 2>/dev/null || echo "0")
            
            # Mostrar com indicador visual
            printf "\r📊 Velocidade de escrita: %6.2f MB/s " "$mb_per_sec"
            
            # Indicador visual de velocidade
            if (( $(echo "$mb_per_sec > 20" | bc -l) )); then
                echo -n "🚀 Excelente!"
            elif (( $(echo "$mb_per_sec > 10" | bc -l) )); then
                echo -n "✅ Bom      "
            elif (( $(echo "$mb_per_sec > 5" | bc -l) )); then
                echo -n "⚠️  Regular  "
            elif (( $(echo "$mb_per_sec > 0" | bc -l) )); then
                echo -n "🐌 Lento    "
            else
                echo -n "⏸️  Idle     "
            fi
        fi
    done
done