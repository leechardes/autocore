#!/bin/bash
#
# Script para agendar manutenção automática do banco de dados
# Adiciona tarefas ao crontab do Raspberry Pi
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PYTHON_PATH="/home/pi/autocore/venv/bin/python"
MAINTENANCE_SCRIPT="$SCRIPT_DIR/maintenance.py"

echo "📅 Configurando manutenção automática do banco de dados AutoCore"
echo "=================================================="

# Função para adicionar linha ao crontab
add_to_crontab() {
    local schedule="$1"
    local command="$2"
    local comment="$3"
    
    # Verifica se já existe
    if crontab -l 2>/dev/null | grep -q "$command"; then
        echo "⚠️  Já existe: $comment"
    else
        # Adiciona ao crontab
        (crontab -l 2>/dev/null; echo "# $comment"; echo "$schedule $command") | crontab -
        echo "✅ Adicionado: $comment"
    fi
}

# 1. Limpeza diária às 3:00 AM - Remove telemetria > 7 dias
add_to_crontab \
    "0 3 * * *" \
    "$PYTHON_PATH $MAINTENANCE_SCRIPT clean --telemetry-days 7 --log-days 30 >> /home/pi/autocore/logs/maintenance.log 2>&1" \
    "AutoCore: Limpeza diária de dados antigos"

# 2. Vacuum semanal - Domingos às 4:00 AM
add_to_crontab \
    "0 4 * * 0" \
    "$PYTHON_PATH $MAINTENANCE_SCRIPT vacuum >> /home/pi/autocore/logs/maintenance.log 2>&1" \
    "AutoCore: Vacuum semanal do banco de dados"

# 3. Manutenção completa mensal - Dia 1 às 2:00 AM
add_to_crontab \
    "0 2 1 * *" \
    "$PYTHON_PATH $MAINTENANCE_SCRIPT full --telemetry-days 7 --log-days 30 >> /home/pi/autocore/logs/maintenance.log 2>&1" \
    "AutoCore: Manutenção completa mensal"

# 4. Rotação de logs - Diariamente às 2:30 AM
add_to_crontab \
    "30 2 * * *" \
    "find /home/pi/autocore/logs -name '*.log' -size +10M -exec gzip {} \; && find /home/pi/autocore/logs -name '*.gz' -mtime +30 -delete" \
    "AutoCore: Rotação de logs do sistema"

echo ""
echo "📋 Tarefas agendadas no crontab:"
echo "================================"
crontab -l | grep "AutoCore:"

echo ""
echo "✅ Configuração completa!"
echo ""
echo "📊 Para verificar estatísticas do banco:"
echo "   python $MAINTENANCE_SCRIPT stats"
echo ""
echo "🧹 Para executar limpeza manual:"
echo "   python $MAINTENANCE_SCRIPT full"
echo ""
echo "📈 Logs de manutenção em:"
echo "   /home/pi/autocore/logs/maintenance.log"