# 💾 Guia de Otimização por Tamanho de Cartão SD

## 🎯 Visão Geral

Este guia fornece configurações otimizadas para diferentes tamanhos de cartão SD no Raspberry Pi Zero 2W rodando AutoCore.

## 📏 Cartão SD de 8GB - Configuração Mínima

### Características
- **Espaço total:** 7.4GB real
- **Espaço após OS:** ~5GB
- **Margem segura:** Mínima
- **Requer:** Manutenção frequente

### Configuração Otimizada

```bash
#!/bin/bash
# setup_8gb.sh - Configuração para SD 8GB

# 1. Swap reduzido
sudo dphys-swapfile swapoff
sudo sed -i 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=256/' /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# 2. Journald limitado
sudo sed -i 's/#SystemMaxUse=/SystemMaxUse=50M/' /etc/systemd/journald.conf
sudo sed -i 's/#RuntimeMaxUse=/RuntimeMaxUse=50M/' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald

# 3. Limpeza agressiva
crontab -l | { cat; echo "0 */6 * * * /home/pi/autocore/scripts/aggressive_cleanup.sh"; } | crontab -

# 4. SQLite mínimo
cat > /home/pi/autocore/database/config/storage.conf << EOF
MAX_DB_SIZE_MB=10
TELEMETRY_RETENTION_DAYS=2
LOG_RETENTION_DAYS=3
BACKUP_RETENTION_COUNT=1
CACHE_SIZE_KB=2048
EOF
```

### Script de Limpeza Agressiva

```bash
#!/bin/bash
# aggressive_cleanup.sh

# Limpar logs antigos
sudo journalctl --vacuum-time=1d
sudo find /var/log -type f -name "*.gz" -delete
sudo find /var/log -type f -name "*.1" -delete

# Limpar cache Python
find /home/pi -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
find /home/pi -name "*.pyc" -delete 2>/dev/null

# Limpar apt
sudo apt clean
sudo apt autoremove -y

# Limpar pip
/home/pi/autocore/*/.venv/bin/pip cache purge 2>/dev/null

# Limpar telemetria antiga
cd /home/pi/autocore/database
.venv/bin/python -c "
import sqlite3
conn = sqlite3.connect('autocore.db')
conn.execute('DELETE FROM telemetry_data WHERE timestamp < datetime(\'now\', \'-2 days\')')
conn.execute('DELETE FROM event_logs WHERE timestamp < datetime(\'now\', \'-3 days\')')
conn.execute('VACUUM')
conn.commit()
conn.close()
"

echo "Cleanup completed: $(date)"
df -h /
```

### Monitoramento Contínuo

```bash
# Alerta quando > 90% usado
*/30 * * * * [ $(df / | tail -1 | awk '{print $5}' | sed 's/%//') -gt 90 ] && echo "DISK CRITICAL" | wall
```

## 📦 Cartão SD de 16GB - Configuração Balanceada

### Características
- **Espaço total:** 14.9GB real
- **Espaço após OS:** ~12GB
- **Margem segura:** Adequada
- **Requer:** Manutenção semanal

### Configuração Otimizada

```bash
#!/bin/bash
# setup_16gb.sh - Configuração para SD 16GB

# 1. Swap padrão
sudo dphys-swapfile swapoff
sudo sed -i 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=1024/' /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# 2. Journald moderado
sudo sed -i 's/#SystemMaxUse=/SystemMaxUse=200M/' /etc/systemd/journald.conf
sudo sed -i 's/#MaxRetentionSec=/MaxRetentionSec=1week/' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald

# 3. Limpeza semanal
crontab -l | { cat; echo "0 3 * * 0 /home/pi/autocore/scripts/weekly_cleanup.sh"; } | crontab -

# 4. SQLite balanceado
cat > /home/pi/autocore/database/config/storage.conf << EOF
MAX_DB_SIZE_MB=50
TELEMETRY_RETENTION_DAYS=7
LOG_RETENTION_DAYS=14
BACKUP_RETENTION_COUNT=7
CACHE_SIZE_KB=10240
MMAP_SIZE_MB=128
EOF

# 5. tmpfs para /tmp
echo "tmpfs /tmp tmpfs defaults,noatime,size=128M 0 0" | sudo tee -a /etc/fstab
```

### Script de Manutenção Semanal

```bash
#!/bin/bash
# weekly_cleanup.sh

echo "Starting weekly maintenance: $(date)"

# Backup antes da limpeza
/home/pi/autocore/database/.venv/bin/python /home/pi/autocore/database/src/cli/manage.py backup

# Limpeza moderada
sudo journalctl --vacuum-time=7d
sudo apt clean

# Limpar telemetria
cd /home/pi/autocore/database
.venv/bin/python src/cli/manage.py clean --days 7

# Otimizar banco
sqlite3 autocore.db "PRAGMA optimize"

# Relatório
echo "Storage after cleanup:"
df -h /
du -sh /home/pi/autocore/* | sort -h
```

## 📦 Cartão SD de 32GB - Configuração Confortável

### Características
- **Espaço total:** 29.8GB real
- **Espaço após OS:** ~27GB
- **Margem segura:** Confortável
- **Requer:** Manutenção mensal

### Configuração Otimizada

```bash
#!/bin/bash
# setup_32gb.sh - Configuração para SD 32GB

# 1. Swap generoso
sudo dphys-swapfile swapoff
sudo sed -i 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# 2. Journald expandido
sudo sed -i 's/#SystemMaxUse=/SystemMaxUse=500M/' /etc/systemd/journald.conf
sudo sed -i 's/#MaxRetentionSec=/MaxRetentionSec=1month/' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald

# 3. Limpeza mensal
crontab -l | { cat; echo "0 3 1 * * /home/pi/autocore/scripts/monthly_maintenance.sh"; } | crontab -

# 4. SQLite otimizado
cat > /home/pi/autocore/database/config/storage.conf << EOF
MAX_DB_SIZE_MB=200
TELEMETRY_RETENTION_DAYS=30
LOG_RETENTION_DAYS=30
BACKUP_RETENTION_COUNT=14
CACHE_SIZE_KB=25600
MMAP_SIZE_MB=256
WAL_SIZE_MB=100
EOF

# 5. tmpfs expandido
echo "tmpfs /tmp tmpfs defaults,noatime,size=256M 0 0" | sudo tee -a /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,noatime,size=128M 0 0" | sudo tee -a /etc/fstab

# 6. Habilitar ZRAM
sudo apt install zram-tools
echo -e "ALGO=lz4\nPERCENT=50" | sudo tee /etc/default/zramswap
sudo service zramswap restart
```

### Recursos Avançados

```bash
# Habilitar compressão de logs
sudo sed -i 's/#Compress=/Compress=yes/' /etc/systemd/journald.conf

# Cache de leitura expandido
echo 256 | sudo tee /sys/block/mmcblk0/queue/read_ahead_kb

# Scheduler otimizado para SD
echo deadline | sudo tee /sys/block/mmcblk0/queue/scheduler
```

## 💎 Cartão SD de 64GB - Configuração Premium

### Características
- **Espaço total:** 59.6GB real
- **Espaço após OS:** ~57GB
- **Margem segura:** Excelente
- **Requer:** Manutenção trimestral

### Configuração Otimizada (SanDisk Ultra)

```bash
#!/bin/bash
# setup_64gb.sh - Configuração Premium para SD 64GB

# 1. Swap otimizado
sudo dphys-swapfile swapoff
sudo sed -i 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile
sudo sed -i 's/#CONF_SWAPFACTOR=/CONF_SWAPFACTOR=2/' /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# 2. Journald sem limites
sudo sed -i 's/#SystemMaxUse=/SystemMaxUse=1G/' /etc/systemd/journald.conf
sudo sed -i 's/#MaxRetentionSec=/MaxRetentionSec=3month/' /etc/systemd/journald.conf
sudo sed -i 's/#Compress=/Compress=yes/' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald

# 3. Manutenção trimestral
crontab -l | { cat; echo "0 3 1 */3 * /home/pi/autocore/scripts/quarterly_optimization.sh"; } | crontab -

# 4. SQLite máxima performance
cat > /home/pi/autocore/database/config/storage.conf << EOF
MAX_DB_SIZE_MB=1000
TELEMETRY_RETENTION_DAYS=90
LOG_RETENTION_DAYS=180
BACKUP_RETENTION_COUNT=30
CACHE_SIZE_KB=51200  # 50MB cache
MMAP_SIZE_MB=512     # 512MB memory-mapped
WAL_SIZE_MB=200      # 200MB WAL
PAGE_SIZE=4096       # 4KB pages
JOURNAL_SIZE_LIMIT=1073741824  # 1GB journal
EOF

# 5. tmpfs generoso
echo "tmpfs /tmp tmpfs defaults,noatime,size=512M 0 0" | sudo tee -a /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,noatime,size=256M 0 0" | sudo tee -a /etc/fstab
echo "tmpfs /var/log tmpfs defaults,noatime,size=256M 0 0" | sudo tee -a /etc/fstab

# 6. ZRAM máximo
sudo apt install zram-tools
echo -e "ALGO=lz4\nPERCENT=100\nPRIORITY=100" | sudo tee /etc/default/zramswap
sudo service zramswap restart

# 7. Partição separada para dados (opcional)
# Criar partição de dados de 40GB
# sudo fdisk /dev/mmcblk0
# mkfs.ext4 /dev/mmcblk0p3
# mount /dev/mmcblk0p3 /data

# 8. Preload de bibliotecas
sudo apt install preload
sudo systemctl enable preload

# 9. Cache de escrita expandido
echo 512 | sudo tee /sys/block/mmcblk0/queue/write_cache

# 10. Otimizações de kernel
cat | sudo tee -a /etc/sysctl.conf << EOF
# Otimizações para 64GB SD
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_background_ratio=5
vm.dirty_ratio=10
vm.dirty_expire_centisecs=3000
vm.dirty_writeback_centisecs=1500
EOF
sudo sysctl -p
```

### Recursos Premium

```bash
# Backup em partição separada
sudo mkdir -p /backup
echo "/dev/mmcblk0p3 /backup ext4 defaults,noatime 0 2" | sudo tee -a /etc/fstab

# Logs persistentes com rotação
sudo mkdir -p /data/logs
sudo systemctl edit systemd-journald
# Adicionar:
[Journal]
Storage=persistent
SystemMaxFileSize=100M
SystemMaxFiles=10

# Análise de performance
sudo apt install iotop sysstat
echo "*/5 * * * * /usr/lib/sysstat/sa1 1 1" | sudo crontab -
```

## 📊 Comparação de Configurações

| Parâmetro | 8GB | 16GB | 32GB | 64GB |
|-----------|-----|------|------|------|
| Swap (MB) | 256 | 1024 | 2048 | 2048 |
| Cache SQLite (MB) | 2 | 10 | 25 | 50 |
| MMAP SQLite (MB) | - | 128 | 256 | 512 |
| Telemetria (dias) | 2 | 7 | 30 | 90 |
| Logs (dias) | 3 | 14 | 30 | 180 |
| Backups mantidos | 1 | 7 | 14 | 30 |
| tmpfs /tmp (MB) | - | 128 | 256 | 512 |
| Journald (MB) | 50 | 200 | 500 | 1024 |
| Limpeza | 6h | Semanal | Mensal | Trimestral |
| ZRAM | Não | Não | Sim | Sim |

## 🔧 Scripts Universais

### Detecção Automática de Tamanho

```bash
#!/bin/bash
# auto_configure.sh - Detecta tamanho e configura automaticamente

# Detectar tamanho do SD
SD_SIZE_GB=$(df -BG / | tail -1 | awk '{print $2}' | sed 's/G//')

echo "Detected SD card size: ${SD_SIZE_GB}GB"

# Aplicar configuração apropriada
if [ $SD_SIZE_GB -le 8 ]; then
    echo "Applying 8GB configuration..."
    ./setup_8gb.sh
elif [ $SD_SIZE_GB -le 16 ]; then
    echo "Applying 16GB configuration..."
    ./setup_16gb.sh
elif [ $SD_SIZE_GB -le 32 ]; then
    echo "Applying 32GB configuration..."
    ./setup_32gb.sh
else
    echo "Applying 64GB+ configuration..."
    ./setup_64gb.sh
fi

echo "Configuration complete. Please reboot."
```

### Monitor de Saúde do SD

```bash
#!/bin/bash
# sd_health_check.sh - Verifica saúde do cartão SD

echo "=== SD Card Health Check ==="
echo "Date: $(date)"
echo ""

# Espaço usado
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
echo "Disk usage: ${USAGE}%"

if [ $USAGE -gt 90 ]; then
    echo "WARNING: Critical disk usage!"
elif [ $USAGE -gt 80 ]; then
    echo "WARNING: High disk usage"
else
    echo "OK: Disk usage normal"
fi

# Teste de velocidade
echo ""
echo "Write speed test:"
dd if=/dev/zero of=/tmp/test bs=1M count=50 conv=fdatasync 2>&1 | tail -1

echo "Read speed test:"
dd if=/tmp/test of=/dev/null bs=1M 2>&1 | tail -1
rm /tmp/test

# Erros do sistema de arquivos
echo ""
echo "Filesystem errors:"
dmesg | grep -i "mmcblk0" | grep -i "error" | tail -5

# Tempo de vida estimado (baseado em writes)
WRITES=$(awk '/mmcblk0/ {print $10}' /proc/diskstats)
echo ""
echo "Total writes: $WRITES sectors"
echo "Estimated wear: $(($WRITES / 1000000))GB written"
```

## 🎯 Recomendações Finais

### Para Produção
- **Mínimo:** 16GB Class 10
- **Recomendado:** 32GB UHS-I U1
- **Ideal:** 64GB UHS-I U1/A1

### Marcas Confiáveis
1. **SanDisk** (Ultra, Extreme)
2. **Samsung** (EVO, PRO)
3. **Kingston** (Canvas)
4. **Lexar** (Professional)

### Sinais de Desgaste do SD
- Lentidão progressiva
- Erros de I/O frequentes
- Arquivos corrompidos
- Boot failures
- Velocidade < 5MB/s

### Quando Substituir
- Após 2-3 anos de uso contínuo
- Quando velocidade cai < 50% original
- Após erros de filesystem
- Preventivamente em sistemas críticos

---

**Última Atualização:** 07 de agosto de 2025  
**Autor:** Lee Chardes  
**Versão:** 1.0.0