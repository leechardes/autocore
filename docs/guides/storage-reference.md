# 💾 Referência de Armazenamento - AutoCore

## 📊 Visão Geral

Este documento é a referência definitiva para configuração de armazenamento e ambientes virtuais Python no sistema AutoCore rodando em Raspberry Pi Zero 2W.

## 🎯 Decisões de Arquitetura

### 1. Ambientes Virtuais Python (.venv)

**Decisão:** Um ambiente virtual isolado por subprojeto

```
AutoCore/
├── database/.venv       # ~50MB - SQLAlchemy, Alembic
├── gateway/.venv        # ~40MB - paho-mqtt, asyncio  
└── config-app/backend/.venv  # ~60MB - FastAPI, uvicorn
Total: ~150MB
```

**Justificativa:**
- Deploy independente de cada serviço
- Isolamento de falhas
- Rollback granular
- Sem conflitos de dependências
- Alinhamento com arquitetura de microserviços

### 2. Estratégia de Armazenamento

**Hardware:** Raspberry Pi Zero 2W (sem armazenamento interno)
**Storage:** Cartão microSD (slot único)

## 🔧 Especificações Técnicas

### Raspberry Pi Zero 2W

| Especificação | Valor |
|--------------|-------|
| CPU | Quad-core ARM Cortex-A53 @ 1GHz |
| RAM | 512MB LPDDR2 |
| Storage | microSD card slot |
| USB | 1x micro USB OTG |
| Consumo | ~0.4W idle, ~1W load |

### Cartões SD Compatíveis

| Classe | Velocidade Mín | Uso Recomendado | Performance SQLite |
|--------|----------------|-----------------|--------------------|
| Class 4 | 4MB/s | Não recomendado | Muito lenta |
| Class 10 | 10MB/s | Mínimo aceitável | Adequada |
| UHS-I U1 | 10MB/s | **Recomendado** | Boa |
| UHS-I U3/A1 | 30MB/s | Ideal | Ótima |
| A2 | 4000 IOPS | Overkill | Excelente (mas cara) |

## 📦 Configurações por Tamanho de SD

### 8GB - Configuração Mínima

```yaml
Uso de Espaço:
  OS: 2GB
  AutoCore: 300MB
  Swap: 512MB
  Livre: ~5GB

Otimizações:
  cache_sqlite: 5MB
  telemetria_dias: 3
  logs_dias: 7
  backups_manter: 3
  limpeza: diária agressiva
```

```bash
# Configuração para 8GB
cat > /home/pi/autocore/config/storage_8gb.conf << EOF
MAX_DB_SIZE_MB=10
TELEMETRY_RETENTION_DAYS=3
LOG_RETENTION_DAYS=7
CACHE_SIZE_KB=5000
SWAP_SIZE_MB=512
EOF
```

### 16GB - Configuração Padrão

```yaml
Uso de Espaço:
  OS: 2GB
  AutoCore: 500MB
  Swap: 1GB
  Livre: ~12GB

Otimizações:
  cache_sqlite: 10MB
  telemetria_dias: 7
  logs_dias: 14
  backups_manter: 7
  limpeza: semanal
```

```bash
# Configuração para 16GB
cat > /home/pi/autocore/config/storage_16gb.conf << EOF
MAX_DB_SIZE_MB=50
TELEMETRY_RETENTION_DAYS=7
LOG_RETENTION_DAYS=14
CACHE_SIZE_KB=10000
SWAP_SIZE_MB=1024
EOF
```

### 32GB - Configuração Confortável

```yaml
Uso de Espaço:
  OS: 2GB
  AutoCore: 1GB
  Swap: 2GB
  Livre: ~27GB

Otimizações:
  cache_sqlite: 25MB
  telemetria_dias: 30
  logs_dias: 30
  backups_manter: 14
  limpeza: mensal
```

```bash
# Configuração para 32GB
cat > /home/pi/autocore/config/storage_32gb.conf << EOF
MAX_DB_SIZE_MB=200
TELEMETRY_RETENTION_DAYS=30
LOG_RETENTION_DAYS=30
CACHE_SIZE_KB=25000
SWAP_SIZE_MB=2048
EOF
```

### 64GB - Configuração Premium (SanDisk Ultra)

```yaml
Uso de Espaço:
  OS: 2GB
  AutoCore: 2GB
  Swap: 2GB
  Livre: ~58GB

Otimizações:
  cache_sqlite: 50MB
  telemetria_dias: 60
  logs_dias: 90
  backups_manter: 30
  limpeza: apenas se > 80%
```

```bash
# Configuração para 64GB
cat > /home/pi/autocore/config/storage_64gb.conf << EOF
MAX_DB_SIZE_MB=1000
TELEMETRY_RETENTION_DAYS=60
LOG_RETENTION_DAYS=90
CACHE_SIZE_KB=50000
SWAP_SIZE_MB=2048
MMAP_SIZE_MB=512
EOF
```

## 🔄 Estrutura de Deploy com venvs Isolados

### 1. Hierarquia de Arquivos

```
/home/pi/autocore/
├── database/
│   ├── .venv/
│   │   ├── bin/
│   │   │   ├── python
│   │   │   ├── pip
│   │   │   └── alembic
│   │   └── lib/python3.9/
│   ├── requirements.txt
│   └── src/
├── gateway/
│   ├── .venv/
│   │   └── ...
│   ├── requirements.txt
│   └── main.py
└── config-app/
    └── backend/
        ├── .venv/
        │   └── ...
        ├── requirements.txt
        └── main.py
```

### 2. Systemd Services

Cada serviço usa seu próprio venv:

```ini
# /etc/systemd/system/autocore-gateway.service
[Service]
ExecStart=/home/pi/autocore/gateway/.venv/bin/python main.py

# /etc/systemd/system/autocore-config-app.service
[Service]
ExecStart=/home/pi/autocore/config-app/backend/.venv/bin/uvicorn main:app
```

### 3. Deploy Independente

```bash
# Deploy apenas do gateway
./deploy.sh gateway deploy

# Deploy apenas do config-app
./deploy.sh config-app deploy

# Deploy de todos
./deploy.sh all deploy
```

## 📊 Benchmarks e Performance

### Testes de Performance por Classe de SD

| Operação | Class 10 | UHS-I U1 | UHS-I U3/A1 |
|----------|----------|----------|-------------|
| Boot OS | ~35s | ~30s | ~25s |
| SQLite INSERT | 50/s | 75/s | 150/s |
| SQLite SELECT | 1000/s | 1500/s | 2500/s |
| Python import | ~2s | ~1.5s | ~1s |
| pip install | ~3min | ~2min | ~90s |

### Uso de Memória por Serviço

```
Processo           RAM (MB)  Swap (MB)
-----------------------------------------
gateway.py         35-45     0-10
uvicorn (config)   45-60     0-15
sqlite (shared)    5-10      0
systemd (todos)    2-3       0
-----------------------------------------
Total AutoCore:    87-118    0-25
OS + Sistema:      150-180   0-50
-----------------------------------------
Total Geral:       237-298   0-75
(Disponível: 512MB)
```

## ⚡ Otimizações de Performance

### 1. Mount Options

```bash
# /etc/fstab
/dev/mmcblk0p2 / ext4 defaults,noatime,nodiratime,commit=60 0 1
```

### 2. SQLite PRAGMA

```python
# shared/connection.py
connection.execute("PRAGMA journal_mode=WAL")
connection.execute("PRAGMA synchronous=NORMAL")
connection.execute("PRAGMA cache_size=-50000")  # 50MB
connection.execute("PRAGMA mmap_size=268435456")  # 256MB
connection.execute("PRAGMA temp_store=MEMORY")
```

### 3. Python Otimizações

```bash
# Criar venv com system packages
python3 -m venv .venv --system-site-packages

# Compilar bytecode
python3 -m compileall -b .

# Desabilitar assert em produção
python3 -O main.py
```

### 4. Swap Configuration

```bash
# Configurar swap baseado no tamanho do SD
SD_SIZE=$(df -BG / | tail -1 | awk '{print $2}' | sed 's/G//')

if [ $SD_SIZE -le 8 ]; then
    SWAP_SIZE=512
elif [ $SD_SIZE -le 16 ]; then
    SWAP_SIZE=1024
else
    SWAP_SIZE=2048
fi

sudo dphys-swapfile swapoff
sudo sed -i "s/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=$SWAP_SIZE/" /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

## 🔍 Monitoramento

### Scripts de Monitoramento

```bash
#!/bin/bash
# monitor.sh - Monitoramento completo

echo "=== AutoCore Storage Monitor ==="
echo "Timestamp: $(date)"
echo ""

# Espaço em disco
echo "[DISK USAGE]"
df -h / | tail -1
echo ""

# Tamanho dos venvs
echo "[VENV SIZES]"
du -sh /home/pi/autocore/*/.venv /home/pi/autocore/*/backend/.venv 2>/dev/null
echo ""

# Tamanho do banco
echo "[DATABASE SIZE]"
ls -lh /home/pi/autocore/database/autocore.db 2>/dev/null
echo ""

# Memória
echo "[MEMORY USAGE]"
free -h
echo ""

# Processos Python
echo "[PYTHON PROCESSES]"
ps aux | grep python | grep -v grep
echo ""

# I/O Stats
echo "[I/O STATISTICS]"
iostat -x 1 2 | tail -n 20
```

### Alertas Automáticos

```bash
# Adicionar ao crontab
*/30 * * * * /home/pi/autocore/scripts/check_storage.sh

# check_storage.sh
#!/bin/bash
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ $USAGE -gt 90 ]; then
    echo "CRITICAL: Disk usage at ${USAGE}%" | logger -t autocore
    # Limpeza de emergência
    find /var/log -type f -name "*.gz" -delete
    journalctl --vacuum-time=1d
elif [ $USAGE -gt 80 ]; then
    echo "WARNING: Disk usage at ${USAGE}%" | logger -t autocore
fi
```

## 🔥 Troubleshooting

### Problema: "No space left on device"

```bash
# 1. Verificar uso
df -h
du -sh /* | sort -h

# 2. Limpar logs
sudo journalctl --vacuum-time=2d
sudo apt clean
sudo apt autoremove

# 3. Limpar Python
find . -name "__pycache__" -exec rm -rf {} +
find . -name "*.pyc" -delete
pip cache purge

# 4. Limpar Docker (se usado)
docker system prune -a

# 5. Limpar telemetria antiga
cd /home/pi/autocore/database
.venv/bin/python src/cli/manage.py clean --days 1
```

### Problema: "ImportError" após deploy

```bash
# Verificar venv ativo
which python
# Deve mostrar: /home/pi/autocore/[projeto]/.venv/bin/python

# Reinstalar dependências
source .venv/bin/activate
pip install -r requirements.txt --force-reinstall
```

### Problema: SD Card lento

```bash
# Testar velocidade
dd if=/dev/zero of=test bs=1M count=100 conv=fdatasync
dd if=test of=/dev/null bs=1M
rm test

# Se < 5MB/s, considerar:
# 1. Trocar SD card
# 2. Verificar counterfeit (SD falso)
# 3. Fazer backup e reformatar
```

### Problema: Venv corrompido

```bash
# Recriar venv do zero
cd /home/pi/autocore/[projeto]
rm -rf .venv
python3 -m venv .venv --system-site-packages
source .venv/bin/activate
pip install --upgrade pip wheel setuptools
pip install -r requirements.txt
```

## 📋 Checklist de Implantação

### Preparação do SD Card

- [ ] Verificar classe do SD (mínimo Class 10)
- [ ] Formatar com Raspberry Pi Imager
- [ ] Instalar Raspberry Pi OS Lite (64-bit se possível)
- [ ] Habilitar SSH antes do primeiro boot
- [ ] Configurar WiFi se necessário

### Configuração Inicial

- [ ] Boot e atualizar sistema: `sudo apt update && sudo apt upgrade`
- [ ] Instalar dependências: `sudo apt install python3-pip python3-venv git`
- [ ] Clonar repositório AutoCore
- [ ] Executar `setup_environments.sh`
- [ ] Configurar storage baseado no tamanho do SD

### Deploy dos Serviços

- [ ] Inicializar banco: `make init-db`
- [ ] Instalar systemd services: `make install-services`
- [ ] Iniciar serviços: `sudo systemctl start autocore-*`
- [ ] Verificar status: `make status`
- [ ] Configurar backups automáticos

### Validação

- [ ] Testar interface web: `http://[IP]:8000`
- [ ] Verificar logs: `journalctl -u autocore-*`
- [ ] Monitorar uso de recursos: `htop`
- [ ] Testar comunicação MQTT
- [ ] Executar benchmark de storage

## 📖 Referências

- [Raspberry Pi SD Card Speed Test](https://www.raspberrypi.org/documentation/installation/sd-cards.md)
- [SQLite Performance Tuning](https://www.sqlite.org/pragma.html)
- [Python venv Documentation](https://docs.python.org/3/library/venv.html)
- [Systemd Service Management](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [Linux Storage Optimization](https://wiki.archlinux.org/title/Improving_performance)

## 📊 Métricas de Sucesso

| Métrica | Alvo | Crítico |
|---------|------|----------|
| Uso de disco | < 60% | > 80% |
| Tempo de boot | < 40s | > 60s |
| Latência SQLite | < 10ms | > 50ms |
| Memória livre | > 100MB | < 50MB |
| Uptime | > 30 dias | < 1 dia |

---

**Última Atualização:** 07 de agosto de 2025  
**Versão:** 1.0.0  
**Autor:** Lee Chardes  
**Revisão:** Documentação de Referência