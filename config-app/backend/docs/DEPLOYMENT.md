# 🚀 AutoCore Config App - Deployment Guide

<div align="center">

![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-A22846?style=for-the-badge&logo=raspberry-pi&logoColor=white)
![PM2](https://img.shields.io/badge/PM2-2B037A?style=for-the-badge&logo=pm2&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

**Guia Completo de Deploy para Raspberry Pi Zero 2W**

[Quick Deploy](#-quick-deploy) • [Manual Setup](#-setup-manual) • [PM2 Config](#-configuração-pm2) • [Troubleshooting](#-troubleshooting)

</div>

---

## 📋 Visão Geral

Este guia fornece instruções completas para deploy do AutoCore Config App Backend em um Raspberry Pi Zero 2W, otimizado para performance máxima em hardware limitado.

### Requisitos do Sistema

#### Hardware Mínimo
- **Raspberry Pi Zero 2W** (ou superior)
- **Cartão microSD**: 32GB Classe 10 (recomendado)
- **RAM**: 512MB (Pi Zero 2W)
- **CPU**: ARM Cortex-A53 quad-core 1GHz

#### Software
- **Raspbian OS**: Lite ou Desktop (64-bit recomendado)
- **Python**: 3.9+ (incluído no Raspbian)
- **Node.js**: 16+ (para PM2)
- **SQLite**: 3.35+

---

## ⚡ Quick Deploy

### Script de Deploy Automatizado

```bash
#!/bin/bash
# deploy.sh - Deploy automatizado para Raspberry Pi

set -e

echo "🚀 Iniciando deploy do AutoCore Config App..."

# Variáveis
APP_DIR="/opt/autocore"
USER="autocore"
SERVICE_NAME="autocore-api"

# Criar usuário e diretório
sudo useradd -m -s /bin/bash $USER 2>/dev/null || true
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR

# Copiar arquivos
echo "📁 Copiando arquivos..."
sudo rsync -av --exclude='.git' --exclude='__pycache__' --exclude='*.pyc' . $APP_DIR/

# Instalar dependências do sistema
echo "📦 Instalando dependências do sistema..."
sudo apt update
sudo apt install -y python3-pip python3-venv sqlite3 nginx mosquitto mosquitto-clients

# Configurar ambiente Python
echo "🐍 Configurando ambiente Python..."
cd $APP_DIR
sudo -u $USER python3 -m venv venv
sudo -u $USER venv/bin/pip install --upgrade pip
sudo -u $USER venv/bin/pip install -r requirements.txt

# Configurar banco de dados
echo "🗄️ Configurando banco de dados..."
sudo -u $USER mkdir -p database
sudo -u $USER venv/bin/python -m alembic upgrade head

# Configurar PM2
echo "⚙️ Configurando PM2..."
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pm2

# Configurar serviço
echo "🔧 Configurando serviço..."
sudo -u $USER pm2 start ecosystem.config.js
sudo -u $USER pm2 save
sudo pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER --hp /home/$USER

echo "✅ Deploy concluído com sucesso!"
echo "🌐 API disponível em: http://$(hostname).local:8000"
echo "📊 Status: pm2 status"
echo "📱 Logs: pm2 logs $SERVICE_NAME"
```

### Execução do Deploy

```bash
# No seu computador
chmod +x scripts/deploy.sh

# Copiar para Raspberry Pi
scp -r . pi@raspberrypi.local:/tmp/autocore/

# SSH no Raspberry Pi
ssh pi@raspberrypi.local

# Executar deploy
cd /tmp/autocore
sudo bash scripts/deploy.sh
```

---

## 🔧 Setup Manual

### 1. Preparação do Sistema

#### Atualizar Raspbian
```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências essenciais
sudo apt install -y \
    python3 python3-pip python3-venv \
    sqlite3 \
    git curl wget \
    nginx \
    mosquitto mosquitto-clients \
    htop rsync
```

#### Otimizações de Performance
```bash
# Configurar swap (importante para Pi Zero 2W)
sudo dphys-swapfile swapoff
sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=512/' /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# Otimizações de memória
echo 'gpu_mem=16' | sudo tee -a /boot/config.txt
echo 'disable_camera_led=1' | sudo tee -a /boot/config.txt

# Reiniciar para aplicar mudanças
sudo reboot
```

### 2. Configuração do Usuário

```bash
# Criar usuário dedicado para a aplicação
sudo useradd -m -s /bin/bash autocore
sudo usermod -aG sudo autocore

# Configurar SSH key (opcional)
sudo -u autocore mkdir -p /home/autocore/.ssh
sudo cp ~/.ssh/authorized_keys /home/autocore/.ssh/
sudo chown -R autocore:autocore /home/autocore/.ssh
sudo chmod 700 /home/autocore/.ssh
sudo chmod 600 /home/autocore/.ssh/authorized_keys
```

### 3. Instalação da Aplicação

```bash
# Criar diretório da aplicação
sudo mkdir -p /opt/autocore
sudo chown autocore:autocore /opt/autocore

# Mudar para usuário autocore
sudo su - autocore

# Clonar ou copiar arquivos
cd /opt/autocore
# (arquivos já devem estar aqui)

# Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate

# Instalar dependências
pip install --upgrade pip
pip install -r requirements.txt
```

### 4. Configuração do Banco de Dados

```bash
# Como usuário autocore
cd /opt/autocore

# Criar diretório do banco
mkdir -p database

# Configurar variáveis de ambiente
cp .env.example .env
nano .env

# Executar migrações
source venv/bin/activate
python -m alembic upgrade head

# Popular dados iniciais
python scripts/seed_database.py
```

#### Exemplo de .env para Produção
```env
# Aplicação
DEBUG=false
HOST=0.0.0.0
PORT=8000
LOG_LEVEL=INFO

# Banco de Dados
DATABASE_URL=sqlite:///./database/autocore.db
DATABASE_ECHO=false

# Segurança
SECRET_KEY=your-very-secure-secret-key-here
JWT_ALGORITHM=HS256
JWT_EXPIRE_HOURS=24
CORS_ORIGINS=["http://raspberrypi.local:3000","http://raspberrypi.local"]

# MQTT
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_USERNAME=autocore
MQTT_PASSWORD=secure-mqtt-password
MQTT_KEEPALIVE=60

# Performance (Otimizado para Pi Zero 2W)
UVICORN_WORKERS=1
UVICORN_THREADS=2
MAX_MEMORY_MB=80
REQUEST_TIMEOUT=30
RATE_LIMIT_PER_MINUTE=60

# Raspberry Pi Específico
ENABLE_HARDWARE_MONITORING=true
CPU_TEMP_ALERT=70
MEMORY_ALERT_PERCENT=90
```

---

## ⚙️ Configuração PM2

### 1. Instalação do Node.js e PM2

```bash
# Instalar Node.js 16 LTS
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Instalar PM2 globalmente
sudo npm install -g pm2

# Verificar instalação
node --version
npm --version
pm2 --version
```

### 2. Configuração do Ecosystem

```javascript
// /opt/autocore/ecosystem.config.js
module.exports = {
  apps: [
    {
      name: 'autocore-api',
      script: 'venv/bin/uvicorn',
      args: 'api.main:app --host 0.0.0.0 --port 8000 --workers 1',
      cwd: '/opt/autocore',
      interpreter: 'none',
      
      // Configurações de processo
      instances: 1,
      exec_mode: 'fork',
      
      // Monitoramento de recursos
      max_memory_restart: '80M',
      max_restarts: 10,
      min_uptime: '10s',
      
      // Logs
      log_file: '/opt/autocore/logs/combined.log',
      out_file: '/opt/autocore/logs/out.log',
      error_file: '/opt/autocore/logs/error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      
      // Variáveis de ambiente
      env: {
        NODE_ENV: 'production',
        PYTHONPATH: '/opt/autocore',
        PATH: '/opt/autocore/venv/bin:' + process.env.PATH
      },
      
      // Watch e restart
      watch: false,
      ignore_watch: ['node_modules', 'logs', 'database/*.db-wal', 'database/*.db-shm'],
      
      // Configurações avançadas
      kill_timeout: 5000,
      listen_timeout: 10000,
      
      // Autorestart em caso de falha
      autorestart: true,
      
      // Configurações específicas do Pi
      node_args: '--max-old-space-size=128'
    }
  ],
  
  // Configuração de deploy (opcional)
  deploy: {
    production: {
      user: 'autocore',
      host: 'raspberrypi.local',
      ref: 'origin/main',
      repo: 'git@github.com:leechardes/autocore-config.git',
      path: '/opt/autocore',
      'pre-deploy-local': '',
      'post-deploy': 'pip install -r requirements.txt && pm2 reload ecosystem.config.js --env production',
      'pre-setup': ''
    }
  }
};
```

### 3. Comandos PM2 Essenciais

```bash
# Como usuário autocore
cd /opt/autocore

# Iniciar aplicação
pm2 start ecosystem.config.js --env production

# Verificar status
pm2 status
pm2 info autocore-api

# Logs
pm2 logs autocore-api
pm2 logs --lines 100

# Monitoramento
pm2 monit

# Restart/reload
pm2 restart autocore-api
pm2 reload autocore-api

# Parar aplicação
pm2 stop autocore-api
pm2 delete autocore-api

# Salvar configuração atual
pm2 save

# Configurar startup automático
pm2 startup systemd
# Executar o comando sugerido pelo PM2

# Listar processos salvos
pm2 list
```

### 4. Configuração de Startup Automático

```bash
# Como root
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u autocore --hp /home/autocore

# Como usuário autocore
pm2 start ecosystem.config.js --env production
pm2 save

# Testar reinicialização
sudo reboot

# Após reboot, verificar se serviço está ativo
pm2 status
```

---

## 🔒 Configuração de Segurança

### 1. Firewall (UFW)

```bash
# Habilitar firewall
sudo ufw enable

# Permitir SSH
sudo ufw allow ssh

# Permitir API (apenas rede local)
sudo ufw allow from 192.168.0.0/16 to any port 8000

# Permitir MQTT (apenas localhost)
sudo ufw allow from 127.0.0.1 to any port 1883

# Verificar regras
sudo ufw status verbose
```

### 2. SSL/TLS com Nginx

#### Configuração do Nginx
```nginx
# /etc/nginx/sites-available/autocore
server {
    listen 80;
    listen [::]:80;
    server_name raspberrypi.local *.local;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name raspberrypi.local *.local;

    # SSL Configuration
    ssl_certificate /etc/ssl/certs/autocore.crt;
    ssl_certificate_key /etc/ssl/private/autocore.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";

    # API Proxy
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }

    # WebSocket Proxy
    location /ws/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files (se aplicável)
    location / {
        try_files $uri $uri/ =404;
    }
}
```

#### Gerar Certificado SSL Auto-assinado
```bash
# Criar certificado para desenvolvimento local
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/autocore.key \
    -out /etc/ssl/certs/autocore.crt \
    -subj "/C=BR/ST=State/L=City/O=AutoCore/CN=raspberrypi.local"

# Ativar site
sudo ln -s /etc/nginx/sites-available/autocore /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 3. MQTT Seguro

```bash
# Configurar usuário MQTT
sudo mosquitto_passwd -c /etc/mosquitto/passwd autocore

# Configurar mosquitto
sudo tee /etc/mosquitto/mosquitto.conf << EOF
# Configuração básica
pid_file /var/run/mosquitto.pid
persistence true
persistence_location /var/lib/mosquitto/
log_dest file /var/log/mosquitto/mosquitto.log

# Segurança
allow_anonymous false
password_file /etc/mosquitto/passwd

# Rede
bind_address localhost
port 1883

# Performance
max_connections 50
max_inflight_messages 20
max_queued_messages 100
EOF

# Reiniciar mosquitto
sudo systemctl restart mosquitto
sudo systemctl enable mosquitto
```

---

## 📊 Monitoramento e Logs

### 1. Sistema de Logs

#### Configuração do Logrotate
```bash
# /etc/logrotate.d/autocore
/opt/autocore/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 autocore autocore
    postrotate
        pm2 reloadLogs
    endscript
}
```

### 2. Monitoramento de Recursos

#### Script de Monitoramento
```bash
#!/bin/bash
# /opt/autocore/scripts/monitor.sh

LOG_FILE="/opt/autocore/logs/system_monitor.log"

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # CPU Temperature
    CPU_TEMP=$(vcgencmd measure_temp | cut -d'=' -f2 | cut -d"'" -f1)
    
    # Memory Usage
    MEM_USAGE=$(free -m | awk 'NR==2{printf "%.1f", $3*100/$2}')
    
    # CPU Usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    # Disk Usage
    DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | cut -d'%' -f1)
    
    # PM2 Status
    PM2_STATUS=$(pm2 jlist | jq -r '.[0].pm2_env.status' 2>/dev/null || echo "unknown")
    
    echo "$TIMESTAMP CPU_TEMP:${CPU_TEMP}°C MEM:${MEM_USAGE}% CPU:${CPU_USAGE}% DISK:${DISK_USAGE}% PM2:${PM2_STATUS}" >> $LOG_FILE
    
    # Alerta se temperatura muito alta
    if (( $(echo "$CPU_TEMP > 70" | bc -l) )); then
        echo "$(date) ALERT: CPU temperature high: ${CPU_TEMP}°C" >> $LOG_FILE
    fi
    
    sleep 300  # 5 minutos
done
```

#### Criar serviço de monitoramento
```bash
# /etc/systemd/system/autocore-monitor.service
[Unit]
Description=AutoCore System Monitor
After=network.target

[Service]
Type=simple
User=autocore
ExecStart=/opt/autocore/scripts/monitor.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Ativar serviço
sudo systemctl enable autocore-monitor.service
sudo systemctl start autocore-monitor.service
```

### 3. Health Check Endpoint

O backend já inclui endpoints de health check, mas você pode criar scripts para monitoramento externo:

```bash
#!/bin/bash
# /opt/autocore/scripts/health_check.sh

API_URL="http://localhost:8000"
HEALTH_ENDPOINT="$API_URL/health"
ALERT_EMAIL="admin@autocore.com"

# Verificar se API está respondendo
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_ENDPOINT)

if [ $HTTP_CODE -eq 200 ]; then
    echo "$(date): API Health OK"
else
    echo "$(date): API Health FAILED (HTTP $HTTP_CODE)"
    
    # Tentar restart automático
    echo "$(date): Attempting automatic restart..."
    pm2 restart autocore-api
    
    # Enviar alerta (se configurado)
    # echo "AutoCore API down on $(hostname)" | mail -s "AutoCore Alert" $ALERT_EMAIL
fi
```

---

## 🚨 Troubleshooting

### Problemas Comuns

#### 1. API não inicia

**Sintomas:**
- PM2 mostra status "errored"
- Erro de importação Python
- Banco de dados não encontrado

**Soluções:**
```bash
# Verificar logs detalhados
pm2 logs autocore-api --lines 50

# Verificar ambiente Python
cd /opt/autocore
source venv/bin/activate
python -c "import api.main"

# Verificar permissões
ls -la database/
sudo chown -R autocore:autocore /opt/autocore

# Testar manualmente
venv/bin/uvicorn api.main:app --host 0.0.0.0 --port 8000
```

#### 2. Performance Ruim

**Sintomas:**
- API lenta (>500ms)
- Alto uso de memória
- CPU sempre alto

**Soluções:**
```bash
# Verificar recursos
htop
free -h
df -h

# Otimizar banco de dados
sqlite3 database/autocore.db "VACUUM; ANALYZE;"

# Verificar swap
sudo swapon --show

# Reiniciar com configuração otimizada
pm2 restart autocore-api
```

#### 3. Conexão MQTT Falhando

**Sintomas:**
- Dispositivos não recebem comandos
- Logs mostram erro de conexão MQTT

**Soluções:**
```bash
# Verificar serviço MQTT
sudo systemctl status mosquitto

# Testar conexão
mosquitto_pub -h localhost -t test/topic -m "hello"
mosquitto_sub -h localhost -t test/topic

# Verificar logs
sudo tail -f /var/log/mosquitto/mosquitto.log

# Reiniciar se necessário
sudo systemctl restart mosquitto
```

#### 4. Problemas de Memória

**Sintomas:**
- OOM killer mata processos
- Sistema lento
- PM2 restart por memória

**Soluções:**
```bash
# Verificar swap
sudo dphys-swapfile swapoff
sudo sed -i 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=1024/' /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# Otimizar configuração PM2
# Reduzir max_memory_restart para 60M

# Limpar logs antigos
find /opt/autocore/logs -name "*.log" -mtime +7 -delete

# Otimizar SQLite
echo 'PRAGMA cache_size = 5000;' | sqlite3 database/autocore.db
```

### Scripts de Diagnóstico

#### 1. Script de Diagnóstico Completo
```bash
#!/bin/bash
# /opt/autocore/scripts/diagnose.sh

echo "=== AutoCore System Diagnostics ==="
echo "Timestamp: $(date)"
echo

echo "=== System Info ==="
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "Hardware: $(cat /proc/device-tree/model 2>/dev/null || echo 'Unknown')"
echo "Uptime: $(uptime -p)"
echo

echo "=== Resources ==="
echo "CPU Temperature: $(vcgencmd measure_temp 2>/dev/null || echo 'N/A')"
echo "Memory: $(free -h | grep Mem:)"
echo "Disk: $(df -h / | tail -1)"
echo "Load Average: $(cat /proc/loadavg)"
echo

echo "=== Services ==="
echo "PM2 Status:"
pm2 status
echo
echo "Nginx Status: $(sudo systemctl is-active nginx)"
echo "Mosquitto Status: $(sudo systemctl is-active mosquitto)"
echo

echo "=== Network ==="
echo "Interfaces:"
ip addr show | grep -E "^[0-9]+: |inet "
echo

echo "=== Application ==="
echo "API Health Check:"
curl -s http://localhost:8000/health | jq . 2>/dev/null || echo "API not responding"
echo

echo "=== Recent Errors ==="
echo "PM2 Errors (last 10):"
pm2 logs autocore-api --lines 10 --raw | grep -i error | tail -10 || echo "No errors found"
echo

echo "=== Database ==="
echo "Database file: $(ls -lah /opt/autocore/database/autocore.db 2>/dev/null || echo 'Database not found')"
echo "Database integrity: $(echo 'PRAGMA integrity_check;' | sqlite3 /opt/autocore/database/autocore.db 2>/dev/null || echo 'Cannot check')"
```

#### 2. Script de Reset Completo
```bash
#!/bin/bash
# /opt/autocore/scripts/reset.sh
# CUIDADO: Este script apaga todos os dados!

read -p "This will reset ALL data. Are you sure? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Reset cancelled."
    exit 1
fi

echo "Stopping services..."
pm2 stop autocore-api
sudo systemctl stop mosquitto

echo "Backing up current database..."
cp database/autocore.db database/autocore_backup_$(date +%Y%m%d_%H%M%S).db 2>/dev/null || true

echo "Resetting database..."
rm -f database/autocore.db database/autocore.db-wal database/autocore.db-shm
source venv/bin/activate
python -m alembic upgrade head
python scripts/seed_database.py

echo "Clearing logs..."
rm -f logs/*.log

echo "Restarting services..."
sudo systemctl start mosquitto
pm2 start ecosystem.config.js --env production

echo "Reset complete!"
```

### Comandos de Emergência

```bash
# Parar tudo imediatamente
sudo pkill -f uvicorn
pm2 kill

# Restart completo do sistema
sudo reboot

# Liberar memória
sudo sync
echo 3 | sudo tee /proc/sys/vm/drop_caches

# Verificar processos que consomem memória
ps aux --sort=-%mem | head -10

# Verificar logs do sistema
sudo journalctl -f
sudo dmesg | tail -20
```

---

## 📋 Checklist de Deploy

### Pré-Deploy
- [ ] Raspberry Pi configurado com Raspbian atualizado
- [ ] Usuário `autocore` criado
- [ ] Dependências do sistema instaladas
- [ ] Node.js e PM2 instalados
- [ ] Nginx e Mosquitto configurados

### Deploy
- [ ] Código copiado para `/opt/autocore`
- [ ] Ambiente virtual Python criado
- [ ] Dependências Python instaladas
- [ ] Arquivo `.env` configurado
- [ ] Banco de dados migrado
- [ ] Dados iniciais inseridos

### Pós-Deploy
- [ ] PM2 configurado e funcionando
- [ ] Serviço de startup habilitado
- [ ] Nginx configurado (se aplicável)
- [ ] Firewall configurado
- [ ] Logs funcionando
- [ ] Monitoramento ativo
- [ ] Health check respondendo
- [ ] Backup automático configurado

### Testes
- [ ] API respondendo em http://raspberrypi.local:8000
- [ ] Endpoints principais funcionando
- [ ] WebSocket conectando
- [ ] MQTT funcionando
- [ ] CAN Bus integrado (se disponível)
- [ ] Performance dentro dos limites
- [ ] Logs sendo escritos
- [ ] Restart automático funcionando

---

## 🔄 Atualizações e Manutenção

### Deploy de Atualizações

```bash
#!/bin/bash
# /opt/autocore/scripts/update.sh

echo "Starting AutoCore update..."

# Backup atual
BACKUP_DIR="/opt/autocore/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR
cp -r database $BACKUP_DIR/
cp .env $BACKUP_DIR/

# Parar aplicação
pm2 stop autocore-api

# Atualizar código
git pull origin main
# ou: rsync dos novos arquivos

# Atualizar dependências
source venv/bin/activate
pip install --upgrade -r requirements.txt

# Migrar banco se necessário
python -m alembic upgrade head

# Testar configuração
python -c "import api.main; print('Import OK')"

# Reiniciar aplicação
pm2 start autocore-api

echo "Update complete!"
```

### Manutenção Periódica

```bash
#!/bin/bash
# /opt/autocore/scripts/maintenance.sh
# Execute semanalmente via cron

echo "Starting maintenance tasks..."

# Limpar logs antigos
find logs/ -name "*.log" -mtime +30 -delete

# Otimizar banco de dados
sqlite3 database/autocore.db "VACUUM; ANALYZE;"

# Limpar dados de telemetria antigos
sqlite3 database/autocore.db "DELETE FROM telemetry_data WHERE timestamp < datetime('now', '-30 days');"
sqlite3 database/autocore.db "DELETE FROM event_logs WHERE timestamp < datetime('now', '-90 days');"

# Backup
mkdir -p backups
sqlite3 database/autocore.db ".backup backups/autocore_$(date +%Y%m%d).db"
gzip backups/autocore_$(date +%Y%m%d).db

# Limpar backups antigos
find backups/ -name "*.db.gz" -mtime +30 -delete

# Restart para liberar memória
pm2 restart autocore-api

echo "Maintenance complete!"
```

### Configurar Cron para Manutenção

```bash
# Adicionar ao crontab do usuário autocore
crontab -e

# Adicionar linhas:
# Manutenção semanal (domingo 2h)
0 2 * * 0 /opt/autocore/scripts/maintenance.sh >> /opt/autocore/logs/maintenance.log 2>&1

# Verificação de saúde a cada hora
0 * * * * /opt/autocore/scripts/health_check.sh >> /opt/autocore/logs/health.log 2>&1

# Monitoramento de recursos a cada 5 minutos
*/5 * * * * /opt/autocore/scripts/resource_monitor.sh >> /opt/autocore/logs/resources.log 2>&1
```

---

<div align="center">

**Deploy guide desenvolvido com ❤️ para máxima confiabilidade em produção**

[↑ Voltar ao topo](#-autocore-config-app---deployment-guide)

</div>