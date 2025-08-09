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

echo "🔧 AutoCore - Setup do Raspberry Pi"
echo "======================================"

# Verificar se está rodando no Raspberry Pi
if [ ! -d "${AUTOCORE_DIR}" ]; then
    echo "❌ Erro: Diretório ${AUTOCORE_DIR} não encontrado!"
    echo "Execute primeiro o deploy_to_raspberry.sh no seu computador"
    exit 1
fi

cd ${AUTOCORE_DIR}

# 1. Atualizar Node.js se necessário
echo "🔄 Verificando versão do Node.js..."
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
# Pegar senha do arquivo de credenciais se existir
if [ -f "${AUTOCORE_DIR}/deploy/.credentials" ]; then
    source ${AUTOCORE_DIR}/deploy/.credentials
    MQTT_PASSWORD="${MQTT_PASS:-kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr}"
else
    MQTT_PASSWORD="kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr"
fi

echo "autocore:${MQTT_PASSWORD}" > /tmp/mqtt_passwords.txt
sudo mosquitto_passwd -U /tmp/mqtt_passwords.txt
sudo mv /tmp/mqtt_passwords.txt /etc/mosquitto/passwd
sudo chown mosquitto:mosquitto /etc/mosquitto/passwd
sudo chmod 600 /etc/mosquitto/passwd

# Reiniciar Mosquitto
sudo systemctl restart mosquitto
sudo systemctl enable mosquitto

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

# 7. Iniciar serviços
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

# 8. Verificar status
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