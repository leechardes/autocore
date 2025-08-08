#!/bin/bash

#############################################
# Script de Teste Completo para SD Card
# Para Raspberry Pi Zero 2W
# Detecta e diagnostica problemas comuns
#############################################

echo "========================================"
echo "   TESTE COMPLETO DE SD CARD"
echo "   Raspberry Pi Zero 2W"
echo "========================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para imprimir com cores
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 1. INFORMAÇÕES DO SISTEMA
echo "1. INFORMAÇÕES DO SISTEMA"
echo "------------------------"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "Arquitetura: $(uname -m)"
echo "Data/Hora: $(date)"
echo ""

# 2. VERIFICAR MONTAGEM DO SD CARD
echo "2. VERIFICAÇÃO DE MONTAGEM"
echo "------------------------"
if mount | grep -q "^/dev/mmcblk0p2"; then
    print_success "SD Card montado corretamente"
    mount | grep mmcblk0
else
    print_error "SD Card não está montado!"
    exit 1
fi
echo ""

# 3. INFORMAÇÕES DO SD CARD
echo "3. INFORMAÇÕES DO SD CARD"
echo "------------------------"
if [ -b /dev/mmcblk0 ]; then
    print_success "Dispositivo SD Card detectado"
    
    # Tamanho do cartão
    SIZE=$(sudo fdisk -l /dev/mmcblk0 2>/dev/null | grep "Disk /dev/mmcblk0" | awk '{print $3" "$4}')
    echo "Tamanho total: $SIZE"
    
    # Modelo do cartão (se disponível)
    if [ -f /sys/block/mmcblk0/device/name ]; then
        echo "Modelo: $(cat /sys/block/mmcblk0/device/name)"
    fi
    
    if [ -f /sys/block/mmcblk0/device/manfid ]; then
        echo "Fabricante ID: $(cat /sys/block/mmcblk0/device/manfid)"
    fi
    
    if [ -f /sys/block/mmcblk0/device/serial ]; then
        echo "Serial: $(cat /sys/block/mmcblk0/device/serial)"
    fi
else
    print_error "Dispositivo SD Card não encontrado!"
    exit 1
fi
echo ""

# 4. ESPAÇO EM DISCO
echo "4. ESPAÇO EM DISCO"
echo "------------------------"
df -h | grep -E "Filesystem|mmcblk0"
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $USAGE -gt 90 ]; then
    print_error "Espaço em disco crítico! Uso: $USAGE%"
elif [ $USAGE -gt 80 ]; then
    print_warning "Espaço em disco alto! Uso: $USAGE%"
else
    print_success "Espaço em disco OK. Uso: $USAGE%"
fi
echo ""

# 5. VERIFICAR SISTEMA DE ARQUIVOS
echo "5. VERIFICAÇÃO DO SISTEMA DE ARQUIVOS"
echo "------------------------"
# Verificar se há erros no dmesg
ERRORS=$(sudo dmesg | grep -i "mmcblk0" | grep -iE "error|fail|corrupt" | wc -l)
if [ $ERRORS -eq 0 ]; then
    print_success "Nenhum erro detectado no kernel"
else
    print_warning "Detectados $ERRORS erros/avisos no kernel"
    echo "Últimos erros:"
    sudo dmesg | grep -i "mmcblk0" | grep -iE "error|fail|corrupt" | tail -5
fi
echo ""

# 6. TESTE DE VELOCIDADE DE LEITURA
echo "6. TESTE DE VELOCIDADE DE LEITURA"
echo "------------------------"
echo "Testando velocidade de leitura..."
TEMP_FILE="/tmp/speedtest_read"
sudo dd if=/dev/mmcblk0p2 of=/dev/null bs=1M count=100 iflag=direct 2>&1 | grep -E "copied|copiados"
echo ""

# 7. TESTE DE VELOCIDADE DE ESCRITA
echo "7. TESTE DE VELOCIDADE DE ESCRITA"
echo "------------------------"
echo "Testando velocidade de escrita..."
sync
dd if=/dev/zero of=/tmp/speedtest_write bs=1M count=50 conv=fdatasync 2>&1 | grep -E "copied|copiados"
rm -f /tmp/speedtest_write
echo ""

# 8. TESTE DE LEITURA/ESCRITA PEQUENOS ARQUIVOS
echo "8. TESTE COM ARQUIVOS PEQUENOS"
echo "------------------------"
echo "Criando 100 arquivos pequenos..."
TEST_DIR="/tmp/sdcard_test_$$"
mkdir -p $TEST_DIR

START=$(date +%s)
for i in {1..100}; do
    echo "Test file $i" > $TEST_DIR/file_$i.txt
done
sync
END=$(date +%s)
DURATION=$((END - START))

if [ $DURATION -lt 5 ]; then
    print_success "Performance OK: 100 arquivos em ${DURATION}s"
else
    print_warning "Performance lenta: 100 arquivos em ${DURATION}s"
fi

# Limpar
rm -rf $TEST_DIR
echo ""

# 9. VERIFICAR BADBLOCKS (OPCIONAL - DEMORA MUITO)
echo "9. VERIFICAÇÃO DE BAD BLOCKS"
echo "------------------------"
echo "Deseja fazer verificação completa de bad blocks? (DEMORA ~30min)"
echo "Isso pode identificar setores defeituosos no SD Card."
read -p "Continuar? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo "Iniciando verificação de bad blocks..."
    sudo badblocks -sv /dev/mmcblk0p2 2>&1 | tail -10
else
    echo "Verificação de bad blocks pulada"
fi
echo ""

# 10. VERIFICAR LOGS DO SISTEMA
echo "10. VERIFICAÇÃO DE LOGS"
echo "------------------------"
echo "Verificando logs de erro recentes..."
JOURNAL_ERRORS=$(sudo journalctl -p err -b | grep -i "mmc\|sdcard" | wc -l)
if [ $JOURNAL_ERRORS -eq 0 ]; then
    print_success "Nenhum erro no journal"
else
    print_warning "Encontrados $JOURNAL_ERRORS erros no journal"
    echo "Últimos erros:"
    sudo journalctl -p err -b | grep -i "mmc\|sdcard" | tail -5
fi
echo ""

# 11. TESTE DE STRESS (OPCIONAL)
echo "11. TESTE DE STRESS"
echo "------------------------"
echo "Deseja fazer teste de stress? (escreve/lê 500MB)"
read -p "Continuar? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo "Iniciando teste de stress..."
    STRESS_FILE="/tmp/stress_test_$$.dat"
    
    # Escrever 500MB
    echo "Escrevendo 500MB..."
    dd if=/dev/urandom of=$STRESS_FILE bs=1M count=500 2>/dev/null
    sync
    
    # Calcular checksum
    echo "Calculando checksum..."
    CHECKSUM1=$(md5sum $STRESS_FILE | cut -d' ' -f1)
    
    # Limpar cache
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    
    # Ler e verificar
    echo "Verificando integridade..."
    CHECKSUM2=$(md5sum $STRESS_FILE | cut -d' ' -f1)
    
    if [ "$CHECKSUM1" == "$CHECKSUM2" ]; then
        print_success "Teste de integridade passou!"
    else
        print_error "FALHA na integridade dos dados!"
    fi
    
    rm -f $STRESS_FILE
else
    echo "Teste de stress pulado"
fi
echo ""

# RESUMO FINAL
echo "========================================"
echo "         RESUMO DO TESTE"
echo "========================================"

# Coletar informações para o resumo
PROBLEMS=0

# Verificar espaço
if [ $USAGE -gt 80 ]; then
    PROBLEMS=$((PROBLEMS + 1))
    print_warning "Espaço em disco: $USAGE% usado"
fi

# Verificar erros kernel
if [ $ERRORS -gt 0 ]; then
    PROBLEMS=$((PROBLEMS + 1))
    print_warning "Erros no kernel: $ERRORS"
fi

# Verificar erros journal  
if [ $JOURNAL_ERRORS -gt 0 ]; then
    PROBLEMS=$((PROBLEMS + 1))
    print_warning "Erros no journal: $JOURNAL_ERRORS"
fi

if [ $PROBLEMS -eq 0 ]; then
    echo ""
    print_success "SD CARD ESTÁ FUNCIONANDO CORRETAMENTE!"
    echo ""
    echo "Recomendações:"
    echo "- Use SD Cards classe 10 ou superior"
    echo "- Prefira marcas conhecidas (SanDisk, Samsung, Kingston)"
    echo "- Evite SD Cards falsificados (teste com h2testw no Windows)"
    echo "- Faça backup regularmente"
else
    echo ""
    print_error "FORAM DETECTADOS $PROBLEMS PROBLEMAS!"
    echo ""
    echo "Ações recomendadas:"
    echo "1. Faça backup dos dados importantes"
    echo "2. Execute: sudo fsck /dev/mmcblk0p2 (com o sistema em modo recovery)"
    echo "3. Considere trocar o SD Card"
    echo "4. Use o Raspberry Pi Imager para regravar a imagem"
fi

echo ""
echo "========================================"
echo "Teste concluído em: $(date)"
echo "========================================"