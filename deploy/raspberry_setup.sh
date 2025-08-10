#!/bin/bash

# Setup e inicialização dos serviços AutoCore no Raspberry Pi
# Este script deve ser executado NO Raspberry Pi

AUTOCORE_DIR="/opt/autocore"
USER="autocore"

# Configurar pip para Raspberry Pi
export PIP_DEFAULT_TIMEOUT=100
export PIP_RETRIES=5
export PIP_DISABLE_PIP_VERSION_CHECK=1
export PYTHONUNBUFFERED=1

# Variáveis de tempo
SETUP_START_TIME=$(date +%s)
declare -A PROCESS_TIMES
declare -A PROCESS_STATUS

# Função para registrar tempo de processo
start_timer() {
    local process_name="$1"
    echo "  ⏱️  Iniciando: $process_name"
    PROCESS_TIMES["${process_name}_start"]=$(date +%s)
}

end_timer() {
    local process_name="$1"
    local status="${2:-success}"
    local start_time=${PROCESS_TIMES["${process_name}_start"]}
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    PROCESS_TIMES["${process_name}_duration"]=$duration
    PROCESS_STATUS["${process_name}"]=$status
    
    if [ "$status" = "success" ]; then
        echo "  ✅ Concluído em ${duration}s"
    else
        echo "  ⚠️ Finalizado com avisos em ${duration}s"
    fi
}

echo "🔧 AutoCore - Setup do Raspberry Pi"
echo "======================================"
echo "⏰ Início: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Verificar se está rodando no Raspberry Pi
if [ ! -d "${AUTOCORE_DIR}" ]; then
    echo "❌ Erro: Diretório ${AUTOCORE_DIR} não encontrado!"
    echo "Execute primeiro o deploy_to_raspberry.sh no seu computador"
    exit 1
fi

cd ${AUTOCORE_DIR}

# 1. Atualizar Node.js se necessário
echo "🔄 Verificando versão do Node.js..."
start_timer "nodejs_check"
NODE_VERSION=$(node -v 2>/dev/null | sed 's/v//' | cut -d. -f1)
if [ -z "$NODE_VERSION" ] || [ "$NODE_VERSION" -lt 16 ]; then
    echo "  Node.js desatualizado ou não instalado. Instalando v18..."
    
    # Remover versão antiga se existir
    sudo apt-get remove -y nodejs npm
    
    # Instalar Node.js 18.x via NodeSource
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    echo "  Node.js atualizado para: $(node -v)"
    echo "  NPM: $(npm -v)"
else
    echo "  Node.js v$NODE_VERSION já está instalado"
fi

# 2. Instalar Mosquitto MQTT Broker e dependências
echo "📦 Instalando dependências do sistema..."
sudo apt-get update
sudo apt-get install -y python3-pip python3-venv python3-dev build-essential

# Instalar Mosquitto se não estiver instalado
echo "🦟 Verificando Mosquitto MQTT Broker..."
if ! command -v mosquitto &> /dev/null; then
    echo "📥 Instalando Mosquitto..."
    sudo apt-get install -y mosquitto mosquitto-clients
else
    echo "✅ Mosquitto já instalado"
fi

# Configurar Mosquitto
echo "⚙️ Configurando Mosquitto..."
sudo tee /etc/mosquitto/conf.d/autocore.conf > /dev/null << 'EOF'
listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwd
EOF

# Criar usuário MQTT
# Gerar senha aleatória para MQTT se não existir
if [ -f "${AUTOCORE_DIR}/deploy/.credentials" ] && grep -q "MQTT_PASS=" "${AUTOCORE_DIR}/deploy/.credentials"; then
    source ${AUTOCORE_DIR}/deploy/.credentials
    MQTT_PASSWORD="${MQTT_PASS}"
    echo "  📋 Usando senha MQTT existente das credenciais"
else
    # Gerar nova senha aleatória
    MQTT_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    echo "  🔐 Gerando nova senha MQTT aleatória"
    
    # Salvar nas credenciais
    if [ -f "${AUTOCORE_DIR}/deploy/.credentials" ]; then
        # Adicionar ou atualizar senha
        grep -v "MQTT_PASS=" "${AUTOCORE_DIR}/deploy/.credentials" > /tmp/creds.tmp
        mv /tmp/creds.tmp "${AUTOCORE_DIR}/deploy/.credentials"
    fi
    echo "MQTT_PASS=${MQTT_PASSWORD}" >> "${AUTOCORE_DIR}/deploy/.credentials"
    chmod 600 "${AUTOCORE_DIR}/deploy/.credentials"
fi

# Configurar senha no Mosquitto
echo "  🔧 Configurando senha no Mosquitto..."
echo "autocore:${MQTT_PASSWORD}" > /tmp/mqtt_passwords.txt
sudo mosquitto_passwd -U /tmp/mqtt_passwords.txt
sudo mv /tmp/mqtt_passwords.txt /etc/mosquitto/passwd
sudo chown mosquitto:mosquitto /etc/mosquitto/passwd
sudo chmod 600 /etc/mosquitto/passwd

# Reiniciar Mosquitto
sudo systemctl restart mosquitto
sudo systemctl enable mosquitto

# Configurar .env para backend e gateway com a senha MQTT
echo "  📝 Configurando arquivos .env..."

# Obter IP do Raspberry Pi para CORS e acesso externo
RASPBERRY_IP=$(hostname -I | awk '{print $1}')

# Configurar .env do backend
if [ -d "${AUTOCORE_DIR}/config-app/backend" ]; then
    cat > ${AUTOCORE_DIR}/config-app/backend/.env << EOF
# Config App Backend Configuration
# Server
CONFIG_APP_PORT=8081
CONFIG_APP_HOST=0.0.0.0
ENV=production

# MQTT (conexão local - backend roda no mesmo servidor)
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_USERNAME=autocore
MQTT_PASSWORD=${MQTT_PASSWORD}
MQTT_HOST=localhost

# Database
DATABASE_PATH=../../database/autocore.db

# Security
SECRET_KEY=$(openssl rand -hex 32)
JWT_SECRET_KEY=$(openssl rand -hex 32)
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRES=3600

# Logging
LOG_LEVEL=INFO
LOG_FILE=../../logs/config-app.log

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:5000,http://${RASPBERRY_IP}:3000
EOF
    chmod 600 ${AUTOCORE_DIR}/config-app/backend/.env
    echo "    ✅ Backend .env configurado"
fi

# Configurar .env do gateway
if [ -d "${AUTOCORE_DIR}/gateway" ]; then
    cat > ${AUTOCORE_DIR}/gateway/.env << EOF
# AutoCore Gateway Configuration
# MQTT (conexão local - gateway roda no mesmo servidor)
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_USERNAME=autocore
MQTT_PASSWORD=${MQTT_PASSWORD}
MQTT_HOST=localhost

# Gateway
GATEWAY_PORT=5001
GATEWAY_HOST=0.0.0.0

# Security
SECRET_KEY=$(openssl rand -hex 32)

# Database
DATABASE_PATH=../database/autocore.db

# Logging
LOG_LEVEL=INFO
LOG_FILE=../logs/gateway.log
EOF
    chmod 600 ${AUTOCORE_DIR}/gateway/.env
    echo "    ✅ Gateway .env configurado"
fi

# Configurar .env do frontend
if [ -d "${AUTOCORE_DIR}/config-app/frontend" ]; then
    cat > ${AUTOCORE_DIR}/config-app/frontend/.env << EOF
# Config App Frontend Configuration

# Frontend port
VITE_PORT=3000

# Backend API - Usar IP dinâmico (o frontend detecta automaticamente)
# Quando acessar de outro PC na rede, ele usará o IP correto
VITE_API_URL=
VITE_API_PORT=8081
VITE_API_BASE_URL=
VITE_WS_URL=

# Environment
VITE_ENV=production
EOF
    chmod 600 ${AUTOCORE_DIR}/config-app/frontend/.env
    echo "    ✅ Frontend .env configurado (detecção automática de IP)"
fi

# Verificar conexão MQTT
echo "  🔍 Verificando conexão MQTT..."
if timeout 2 mosquitto_sub -h localhost -u autocore -P "${MQTT_PASSWORD}" -t test -C 1 >/dev/null 2>&1; then
    echo "    ✅ MQTT funcionando com autenticação"
else
    echo "    ⚠️ MQTT não está respondendo corretamente"
fi

# 2. Setup Database
echo "💾 Configurando Database..."
cd ${AUTOCORE_DIR}/database

# Criar venv se não existir
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi

source .venv/bin/activate

# Atualizar pip primeiro
pip install --upgrade pip wheel setuptools

# Instalar requirements com retry e timeout maior
echo "  Instalando dependências (pode demorar)..."
pip install --no-cache-dir --timeout 120 --retries 5 -r requirements.txt || {
    echo "  Tentando instalar uma por uma..."
    while IFS= read -r package; do
        [[ "$package" =~ ^#.*$ || -z "$package" ]] && continue
        echo "    - $package"
        pip install --no-cache-dir --timeout 120 "$package" || echo "    ⚠️ Falhou: $package"
    done < requirements.txt
}

# Inicializar database
if [ -f "src/cli/init_database.py" ]; then
    python src/cli/init_database.py
else
    echo "  ⚠️ Script init_database.py não encontrado"
fi

deactivate

# 3. Setup Gateway
echo "🌐 Configurando Gateway..."
cd ${AUTOCORE_DIR}/gateway

if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi

source .venv/bin/activate
pip install --upgrade pip wheel setuptools

echo "  Instalando dependências (pode demorar)..."
pip install --no-cache-dir --timeout 120 --retries 5 -r requirements.txt || {
    echo "  Tentando instalar uma por uma..."
    while IFS= read -r package; do
        [[ "$package" =~ ^#.*$ || -z "$package" ]] && continue
        echo "    - $package"
        pip install --no-cache-dir --timeout 120 "$package" || echo "    ⚠️ Falhou: $package"
    done < requirements.txt
}

deactivate

# 4. Setup Config App Backend
echo "⚙️ Configurando Config App Backend..."
cd ${AUTOCORE_DIR}/config-app/backend

if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi

source .venv/bin/activate
pip install --upgrade pip wheel setuptools

echo "  Instalando dependências (pode demorar)..."
pip install --no-cache-dir --timeout 120 --retries 5 -r requirements.txt || {
    echo "  Tentando instalar uma por uma..."
    while IFS= read -r package; do
        [[ "$package" =~ ^#.*$ || -z "$package" ]] && continue
        echo "    - $package"
        pip install --no-cache-dir --timeout 120 "$package" || echo "    ⚠️ Falhou: $package"
    done < requirements.txt
}

deactivate

# 5. Setup Config App Frontend
echo "🎨 Configurando Config App Frontend..."
cd ${AUTOCORE_DIR}/config-app/frontend

# Limpar cache do npm se existir
npm cache clean --force 2>/dev/null || true

# Instalar com timeout maior
npm install --loglevel=error --prefer-offline --no-audit --progress=false || {
    echo "  ⚠️ Instalação do frontend pode ter falhado parcialmente"
}

# 6. Copiar serviços systemd
echo "🔧 Instalando serviços systemd..."

# Verificar se os arquivos existem
if [ ! -d "${AUTOCORE_DIR}/deploy/systemd" ] || [ -z "$(ls -A ${AUTOCORE_DIR}/deploy/systemd/*.service 2>/dev/null)" ]; then
    echo "⚠️ Arquivos systemd não encontrados em ${AUTOCORE_DIR}/deploy/systemd/"
    echo "Pulando instalação de serviços systemd..."
    return 1
fi

# Copiar arquivos de serviço
sudo cp ${AUTOCORE_DIR}/deploy/systemd/*.service /etc/systemd/system/

# Ajustar permissões
sudo chmod 644 /etc/systemd/system/autocore-*.service

# Recarregar systemd
sudo systemctl daemon-reload

# 7. Configurar WiFi Access Point (opcional)
echo ""
echo "📡 Configurar Access Point WiFi?"
echo "   Permite conectar dispositivos diretamente no AutoCore"
echo "   SSID será: AutoCore_XXXXXXXXXXXX (baseado no MAC)"
read -p "   Configurar AP? (s/N): " SETUP_AP

if [ "$SETUP_AP" = "s" ] || [ "$SETUP_AP" = "S" ]; then
    if [ -f "${AUTOCORE_DIR}/deploy/setup_wifi_ap.sh" ]; then
        echo "  Configurando Access Point..."
        sudo bash ${AUTOCORE_DIR}/deploy/setup_wifi_ap.sh
    else
        echo "  ⚠️ Script setup_wifi_ap.sh não encontrado"
    fi
fi

# 7.2 Configurar Bluetooth
echo ""
echo "📱 Configurar Bluetooth para comunicação com app?"
echo "   Permite controlar o AutoCore sem perder internet no celular"
read -p "   Configurar Bluetooth? (S/n): " SETUP_BT

if [ "$SETUP_BT" != "n" ] && [ "$SETUP_BT" != "N" ]; then
    if [ -f "${AUTOCORE_DIR}/deploy/setup_bluetooth.sh" ]; then
        echo "  Configurando Bluetooth..."
        start_timer "bluetooth_setup"
        sudo bash ${AUTOCORE_DIR}/deploy/setup_bluetooth.sh
        end_timer "bluetooth_setup"
    else
        echo "  ⚠️ Script setup_bluetooth.sh não encontrado"
    fi
fi

# 7.3 Configurar medição de tempo de boot
echo ""
echo "⏱️ Configurar medição de tempo de boot?"
echo "   Registra quanto tempo o Pi leva para iniciar completamente"
read -p "   Configurar timer de boot? (S/n): " SETUP_BOOT_TIMER

if [ "$SETUP_BOOT_TIMER" != "n" ] && [ "$SETUP_BOOT_TIMER" != "N" ]; then
    if [ -f "${AUTOCORE_DIR}/deploy/setup_boot_timer.sh" ]; then
        echo "  Configurando timer de boot..."
        start_timer "boot_timer_setup"
        sudo bash ${AUTOCORE_DIR}/deploy/setup_boot_timer.sh
        end_timer "boot_timer_setup"
    else
        echo "  ⚠️ Script setup_boot_timer.sh não encontrado"
    fi
fi

# 8. Iniciar serviços
echo "🚀 Iniciando serviços..."

# Habilitar serviços
sudo systemctl enable autocore-gateway autocore-config-app autocore-config-frontend 2>/dev/null || true

# Iniciar serviços um por um com verificação
for service in autocore-gateway autocore-config-app autocore-config-frontend; do
    echo "  Iniciando $service..."
    sudo systemctl start $service
    sleep 2
    if sudo systemctl is-active --quiet $service; then
        echo "    ✅ $service rodando"
    else
        echo "    ⚠️ $service falhou ao iniciar"
        sudo systemctl status $service --no-pager | head -n 5
    fi
done

# 9. Verificar status e gerar resumo
SETUP_END_TIME=$(date +%s)
TOTAL_DURATION=$((SETUP_END_TIME - SETUP_START_TIME))

echo ""
echo "✅ Setup concluído!"
echo ""
echo "📊 Status dos serviços:"
echo "========================"

for service in autocore-gateway autocore-config-app autocore-config-frontend mosquitto; do
    if sudo systemctl is-active --quiet $service; then
        echo "  ✅ $service: ativo"
    else
        echo "  ❌ $service: inativo"
    fi
done

echo ""
echo "🌐 Acesse o sistema em:"
echo "  - Config App: http://${HOSTNAME}.local:3000"
echo "  - Backend API: http://${HOSTNAME}.local:5000"
echo "  - MQTT Broker: ${HOSTNAME}.local:1883"
echo ""
echo "📝 Comandos úteis:"
echo "  - Ver logs: sudo journalctl -u autocore-gateway -f"
echo "  - Reiniciar: sudo systemctl restart autocore-gateway"
echo "  - Parar: sudo systemctl stop autocore-gateway"
echo ""

# Resumo de tempos de execução
echo ""
echo "⏱️ TEMPOS DE EXECUÇÃO"
echo "========================"

# Converter duração total para formato legível
TOTAL_MINUTES=$((TOTAL_DURATION / 60))
TOTAL_SECONDS=$((TOTAL_DURATION % 60))

echo "Tempo total: ${TOTAL_MINUTES}m ${TOTAL_SECONDS}s"
echo ""

echo "Detalhamento por processo:"
for process in "${!PROCESS_TIMES[@]}"; do
    if [[ $process == *"_duration" ]]; then
        process_name=${process%_duration}
        duration=${PROCESS_TIMES[$process]}
        status=${PROCESS_STATUS[$process_name]:-"success"}
        
        # Formatar tempo
        if [ $duration -ge 60 ]; then
            minutes=$((duration / 60))
            seconds=$((duration % 60))
            time_str="${minutes}m ${seconds}s"
        else
            time_str="${duration}s"
        fi
        
        # Ícone baseado no status
        if [ "$status" = "success" ]; then
            icon="✅"
        else
            icon="⚠️"
        fi
        
        printf "  %s %-30s %10s\n" "$icon" "$process_name:" "$time_str"
    fi
done | sort

echo ""
echo "========================"
echo "⏰ Finalizado: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Gerar relatório de instalação
REPORT_FILE="${AUTOCORE_DIR}/installation_report_$(date +%Y%m%d_%H%M%S).log"
echo "🔍 Gerando relatório de instalação..."

{
    echo "=========================================="
    echo "     RELATÓRIO DE INSTALAÇÃO AUTOCORE"
    echo "=========================================="
    echo ""
    echo "📅 Data/Hora: $(date)"
    echo "🖥️ Hostname: $(hostname)"
    echo "📍 IP: $(hostname -I | awk '{print $1}')"
    echo "👤 Usuário: $USER"
    echo "📂 Diretório: $AUTOCORE_DIR"
    echo ""
    echo "=========================================="
    echo "     VERSÕES DOS COMPONENTES"
    echo "=========================================="
    echo ""
    echo "🐍 Python: $(python3 --version)"
    echo "📦 Pip: $(pip3 --version | cut -d' ' -f2)"
    echo "🟢 Node.js: $(node -v)"
    echo "📦 NPM: $(npm -v)"
    echo "🦟 Mosquitto: $(mosquitto -h | head -1)"
    echo ""
    echo "=========================================="
    echo "     ESPAÇO EM DISCO"
    echo "=========================================="
    echo ""
    df -h / | tail -1 | awk '{print "📊 Usado: "$3" de "$2" ("$5" ocupado)"}'
    echo ""
    echo "=========================================="
    echo "     TAMANHO DOS DIRETÓRIOS"
    echo "=========================================="
    echo ""
    du -sh ${AUTOCORE_DIR}/database 2>/dev/null | awk '{print "💾 Database: "$1}'
    du -sh ${AUTOCORE_DIR}/gateway 2>/dev/null | awk '{print "🌐 Gateway: "$1}'
    du -sh ${AUTOCORE_DIR}/config-app 2>/dev/null | awk '{print "⚙️ Config-app: "$1}'
    echo ""
    echo "=========================================="
    echo "     STATUS DOS SERVIÇOS"
    echo "=========================================="
    echo ""
    for service in autocore-gateway autocore-config-app autocore-config-frontend mosquitto; do
        if sudo systemctl is-active --quiet $service; then
            status="✅ ATIVO"
            uptime=$(sudo systemctl show $service --property=ActiveEnterTimestamp --value 2>/dev/null)
            echo "  $service: $status (desde $uptime)"
        else
            status="❌ INATIVO"
            echo "  $service: $status"
            # Pegar últimas linhas de erro se houver
            echo "    Últimos logs:"
            sudo journalctl -u $service -n 3 --no-pager 2>/dev/null | sed 's/^/      /'
        fi
    done
    echo ""
    echo "=========================================="
    echo "     PACOTES PYTHON INSTALADOS"
    echo "=========================================="
    echo ""
    echo "📦 Gateway:"
    if [ -f "${AUTOCORE_DIR}/gateway/.venv/bin/pip" ]; then
        ${AUTOCORE_DIR}/gateway/.venv/bin/pip list --format=freeze | head -10
        echo "  ... ($(${AUTOCORE_DIR}/gateway/.venv/bin/pip list --format=freeze | wc -l) pacotes no total)"
    fi
    echo ""
    echo "📦 Config-app Backend:"
    if [ -f "${AUTOCORE_DIR}/config-app/backend/.venv/bin/pip" ]; then
        ${AUTOCORE_DIR}/config-app/backend/.venv/bin/pip list --format=freeze | head -10
        echo "  ... ($(${AUTOCORE_DIR}/config-app/backend/.venv/bin/pip list --format=freeze | wc -l) pacotes no total)"
    fi
    echo ""
    echo "📦 Database:"
    if [ -f "${AUTOCORE_DIR}/database/.venv/bin/pip" ]; then
        ${AUTOCORE_DIR}/database/.venv/bin/pip list --format=freeze | head -10
        echo "  ... ($(${AUTOCORE_DIR}/database/.venv/bin/pip list --format=freeze | wc -l) pacotes no total)"
    fi
    echo ""
    echo "=========================================="
    echo "     VERIFICAÇÕES DE CONECTIVIDADE"
    echo "=========================================="
    echo ""
    # Testar MQTT
    timeout 2 mosquitto_sub -h localhost -u autocore -P autocore123 -t test -C 1 2>/dev/null && echo "🦟 MQTT: ✅ Conectado" || echo "🦟 MQTT: ❌ Falha na conexão"
    
    # Testar APIs
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 http://localhost:8081/health 2>/dev/null || echo "000")
    if [ "$response" = "200" ]; then
        echo "🔌 Backend API (porta 8081): ✅ OK"
    else
        echo "🔌 Backend API (porta 8081): ❌ Não respondendo (código: $response)"
    fi
    
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 http://localhost:8080 2>/dev/null || echo "000")
    if [ "$response" = "200" ] || [ "$response" = "304" ]; then
        echo "📱 Frontend (porta 8080): ✅ OK"
    else
        echo "📱 Frontend (porta 8080): ❌ Não respondendo (código: $response)"
    fi
    
    echo ""
    echo "=========================================="
    echo "     CONFIGURAÇÃO DE REDE"
    echo "=========================================="
    echo ""
    echo "🌐 Interfaces de rede:"
    ip -br addr show | grep UP
    echo ""
    echo "🔗 Portas abertas:"
    sudo netstat -tlnp 2>/dev/null | grep -E ':(1883|8080|8081)' | awk '{print "  "$4" - "$7}' || echo "  Erro ao listar portas"
    echo ""
    echo "=========================================="
    echo "     LOGS DE ERROS RECENTES"
    echo "=========================================="
    echo ""
    echo "⚠️ Últimos erros do sistema (se houver):"
    sudo journalctl -p err -n 10 --no-pager 2>/dev/null | head -20 2>/dev/null || echo "Nenhum erro encontrado"
    echo ""
    echo "=========================================="
    echo "     INFORMAÇÕES DO SISTEMA"
    echo "=========================================="
    echo ""
    echo "🖥️ Sistema: $(uname -a)"
    echo "⏰ Uptime: $(uptime -p)"
    echo "🧠 Memória: $(free -h | grep Mem | awk '{print "Total: "$2", Usado: "$3", Livre: "$4}')"
    echo "🌡️ Temperatura: $(vcgencmd measure_temp 2>/dev/null || echo 'N/A')"
    echo ""
    echo "=========================================="
    echo "     FIM DO RELATÓRIO"
    echo "=========================================="
    echo ""
    echo "📝 Relatório salvo em: $REPORT_FILE"
    echo "📅 Gerado em: $(date)"
} | tee "$REPORT_FILE"

echo ""
echo "📊 Relatório de instalação salvo em:"
echo "   $REPORT_FILE"
echo ""

# Criar link para o último relatório
ln -sf "$REPORT_FILE" "${AUTOCORE_DIR}/last_installation_report.log"

# Criar flag de instalação completa
touch ${AUTOCORE_DIR}/.installed

# Análise final e resumo
echo ""
echo "=========================================="
echo "           RESUMO EXECUTIVO"
echo "=========================================="
echo ""

# Contar serviços ativos
SERVICES_OK=0
SERVICES_FAIL=0
for service in autocore-gateway autocore-config-app autocore-config-frontend mosquitto; do
    if sudo systemctl is-active --quiet $service; then
        ((SERVICES_OK++))
    else
        ((SERVICES_FAIL++))
    fi
done

# Verificar instalação
if [ $SERVICES_FAIL -eq 0 ]; then
    echo "✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
    echo ""
    echo "📊 Todos os $SERVICES_OK serviços estão rodando"
    echo "🌐 Sistema acessível em: http://$(hostname -I | awk '{print $1}'):3000"
    echo ""
    echo "🎉 AutoCore está pronto para uso!"
else
    echo "⚠️ INSTALAÇÃO CONCLUÍDA COM AVISOS"
    echo ""
    echo "📊 $SERVICES_OK serviços rodando, $SERVICES_FAIL com problemas"
    echo ""
    echo "⚙️ Execute os seguintes comandos para diagnosticar:"
    for service in autocore-gateway autocore-config-app autocore-config-frontend; do
        if ! sudo systemctl is-active --quiet $service; then
            echo "  sudo journalctl -u $service -n 50"
        fi
    done
    echo ""
    echo "📝 Consulte: $REPORT_FILE"
fi

echo ""
echo "=========================================="