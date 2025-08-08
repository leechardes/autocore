#!/bin/bash
# Configuração otimizada para SanDisk Ultra 64GB no Pi Zero 2W
# Aproveita o espaço extra para melhor performance e histórico

set -e

echo "🔧 Configurando armazenamento para SD 64GB..."

# 1. Configurar Swap (2GB com 64GB disponível)
echo "📦 Configurando swap de 2GB..."
sudo dphys-swapfile swapoff
sudo sed -i 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# 2. Otimizar mount do SD
echo "⚡ Otimizando mount do SD..."
sudo sed -i 's/defaults/defaults,noatime,nodiratime/' /etc/fstab

# 3. Configurar tmpfs para /tmp e logs temporários
echo "💾 Configurando tmpfs..."
if ! grep -q "tmpfs /tmp" /etc/fstab; then
    echo "tmpfs /tmp tmpfs defaults,noatime,mode=1777,size=256M 0 0" | sudo tee -a /etc/fstab
    echo "tmpfs /var/log tmpfs defaults,noatime,mode=0755,size=128M 0 0" | sudo tee -a /etc/fstab
fi

# 4. Criar estrutura de diretórios para dados
echo "📁 Criando estrutura de diretórios..."
sudo mkdir -p /data/autocore/{database,backups,logs,telemetry}
sudo chown -R pi:pi /data/autocore

# 5. Configurar logrotate para aproveitar espaço
echo "📜 Configurando rotação de logs estendida..."
sudo tee /etc/logrotate.d/autocore > /dev/null << 'EOF'
/data/autocore/logs/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0644 pi pi
    maxsize 100M
}

/home/pi/autocore/*/logs/*.log {
    weekly
    rotate 8
    compress
    delaycompress
    missingok
    notifempty
    maxsize 50M
}
EOF

# 6. Configurar backup automático local
echo "💾 Configurando backup automático..."
crontab -l 2>/dev/null | { cat; echo "0 3 * * * /home/pi/autocore/database/.venv/bin/python /home/pi/autocore/database/src/cli/manage.py backup --output /data/autocore/backups"; } | crontab -

# 7. Ajustar parâmetros do SQLite para 64GB
echo "🗄️ Otimizando SQLite para 64GB..."
cat > /home/pi/autocore/database/config/storage_64gb.py << 'EOF'
# Configurações otimizadas para SD 64GB
STORAGE_CONFIG = {
    'cache_size': 50000,  # 50MB cache em RAM
    'mmap_size': 536870912,  # 512MB memory-mapped I/O
    'wal_autocheckpoint': 10000,  # Checkpoint a cada 10k páginas
    'telemetry_retention_days': 60,  # 2 meses de telemetria
    'log_retention_days': 90,  # 3 meses de logs
    'backup_retention_count': 30,  # 30 backups diários
    'max_db_size_mb': 1000,  # Limite de 1GB para o banco
}
EOF

# 8. Script de monitoramento de espaço
echo "📊 Criando script de monitoramento..."
cat > /home/pi/autocore/scripts/storage-monitor.sh << 'EOF'
#!/bin/bash
# Monitora uso do storage e envia alertas

USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
DETAILS=$(du -sh /home/pi/autocore/* /data/autocore/* 2>/dev/null | sort -h)

echo "=== Storage Report $(date) ==="
echo "Uso total: ${USAGE}%"
echo ""
echo "Detalhamento:"
echo "$DETAILS"

if [ $USAGE -gt 80 ]; then
    echo "⚠️ ALERTA: Uso acima de 80%!"
    # Executar limpeza de emergência
    /home/pi/autocore/database/.venv/bin/python /home/pi/autocore/database/src/cli/manage.py clean --days 1
fi
EOF
chmod +x /home/pi/autocore/scripts/storage-monitor.sh

# 9. Agendar monitoramento diário
crontab -l 2>/dev/null | { cat; echo "0 6 * * * /home/pi/autocore/scripts/storage-monitor.sh >> /data/autocore/logs/storage.log 2>&1"; } | crontab -

# 10. Criar script de benchmark
echo "⚡ Criando script de benchmark..."
cat > /home/pi/autocore/scripts/storage-benchmark.sh << 'EOF'
#!/bin/bash
echo "🏃 Testando performance do SD..."
echo ""
echo "Escrita sequencial:"
dd if=/dev/zero of=/tmp/testfile bs=1M count=100 conv=fdatasync 2>&1 | grep -E 'copied|copiado'
echo ""
echo "Leitura sequencial:"
dd if=/tmp/testfile of=/dev/null bs=1M 2>&1 | grep -E 'copied|copiado'
rm /tmp/testfile
echo ""
echo "4K random write (mais relevante para SQLite):"
fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=4k --size=32m --numjobs=1 --runtime=10 --group_reporting --filename=/tmp/testfile 2>/dev/null | grep -E 'IOPS|bw'
rm /tmp/testfile
EOF
chmod +x /home/pi/autocore/scripts/storage-benchmark.sh

echo ""
echo "✅ Configuração para 64GB completa!"
echo ""
echo "📊 Resumo das otimizações:"
echo "  • Swap: 2GB"
echo "  • Cache SQLite: 50MB"
echo "  • Retenção telemetria: 60 dias"
echo "  • Retenção logs: 90 dias"
echo "  • Backups mantidos: 30"
echo "  • tmpfs para /tmp: 256MB"
echo ""
echo "💡 Comandos úteis:"
echo "  • Ver uso: df -h"
echo "  • Monitorar: /home/pi/autocore/scripts/storage-monitor.sh"
echo "  • Benchmark: /home/pi/autocore/scripts/storage-benchmark.sh"
echo ""
echo "🔄 Reinicie o sistema para aplicar todas as mudanças:"
echo "  sudo reboot"