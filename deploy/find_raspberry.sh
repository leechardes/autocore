#!/bin/bash

# Script avançado para descobrir automaticamente o IP do Raspberry Pi na rede
# Usa múltiplos métodos: mDNS, ARP scan, nmap, SSH probe e mais

# Diretório do projeto
PROJECT_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
IP_FILE="${PROJECT_DIR}/deploy/.last_raspberry_ip"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Procurando Raspberry Pi na rede...${NC}"
echo "===================================="

# Variáveis
RASPBERRY_IP=""
RASPBERRY_HOSTNAME="autocore.local"
FOUND_IPS=()

# Função para detectar a rede local
detect_local_network() {
    local network=""
    
    # macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        network=$(route -n get default 2>/dev/null | grep interface | awk '{print $2}')
        if [ ! -z "$network" ]; then
            network=$(ifconfig $network 2>/dev/null | grep inet | grep -v inet6 | awk '{print $2}' | head -1)
            if [ ! -z "$network" ]; then
                network=$(echo $network | sed 's/\.[0-9]*$/\.0\/24/')
            fi
        fi
    # Linux
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        network=$(ip route | grep default | head -1 | awk '{print $3}' | sed 's/\.[0-9]*$/\.0\/24/')
    fi
    
    # Fallback networks
    if [ -z "$network" ]; then
        echo "192.168.1.0/24 192.168.0.0/24 10.0.0.0/24 10.0.10.0/24"
    else
        echo "$network 192.168.1.0/24 192.168.0.0/24 10.0.0.0/24"
    fi
}

# Função otimizada para verificar se um IP é o AutoCore
verify_autocore() {
    local ip=$1
    
    # Método 1: Teste rápido de porta SSH
    if ! timeout 2 bash -c "</dev/tcp/$ip/22" 2>/dev/null; then
        return 1
    fi
    
    # Método 2: SSH probe direto com usuário autocore
    local result=$(timeout 4 ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=publickey,password autocore@$ip "echo 'autocore-verified' 2>/dev/null || echo 'ssh-ok'" 2>/dev/null)
    
    # Se conseguiu conectar com usuário autocore, é muito provável que seja o AutoCore
    if [[ "$result" == *"autocore-verified"* ]] || [[ "$result" == *"ssh-ok"* ]]; then
        return 0
    fi
    
    # Método 3: Tentar identificar pela porta 22 se é Linux/Raspberry
    local banner=$(timeout 2 ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no $ip "exit" 2>&1 | head -1)
    if [[ "$banner" == *"Linux"* ]] || [[ "$banner" == *"Debian"* ]] || [[ "$banner" == *"Raspberry"* ]] || [[ "$banner" == *"autocore"* ]]; then
        return 0
    fi
    
    return 1
}

echo -e "${PURPLE}🌐 Detectando rede local...${NC}"
LOCAL_NETWORKS=$(detect_local_network)
echo -e "   Redes a verificar: ${YELLOW}$LOCAL_NETWORKS${NC}"
echo ""

# Método 0: Verificar IP conhecido primeiro
if [ -f "$IP_FILE" ]; then
    LAST_IP=$(cat "$IP_FILE")
    echo -e "${BLUE}📡 Método 0: Verificando último IP conhecido ($LAST_IP)...${NC}"
    if verify_autocore "$LAST_IP"; then
        echo -e "   ${GREEN}✅ AutoCore encontrado no IP conhecido!${NC}"
        FOUND_IPS+=("$LAST_IP")
        echo -e "${YELLOW}⚡ Pulando outros métodos (encontrado rapidamente)${NC}"
        # Pular para processamento de resultados
        SKIP_SLOW_METHODS=true
    else
        echo -e "   ${RED}❌ IP conhecido não responde${NC}"
    fi
    echo ""
fi

# Método 1: Resolver via ping (método que funcionou!)
echo -e "${BLUE}📡 Método 1: Resolvendo hostname $RASPBERRY_HOSTNAME...${NC}"
if ping -c 1 -W 2 $RASPBERRY_HOSTNAME &> /dev/null; then
    # Extrair IP do ping - exatamente como você fez!
    RASPBERRY_IP=$(ping -c 1 $RASPBERRY_HOSTNAME 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if [ ! -z "$RASPBERRY_IP" ]; then
        echo -e "   ${GREEN}✅ Encontrado via ping: $RASPBERRY_HOSTNAME -> $RASPBERRY_IP${NC}"
        # Se o hostname resolve, é muito provável que seja o AutoCore
        FOUND_IPS+=("$RASPBERRY_IP")
        echo -e "   ${GREEN}✅ AutoCore encontrado pelo hostname!${NC}"
        echo -e "${YELLOW}⚡ Pulando outros métodos (encontrado rapidamente)${NC}"
        # Pular outros métodos já que encontrou
        SKIP_SLOW_METHODS=true
    fi
else
    echo -e "   ${RED}❌ Não foi possível resolver $RASPBERRY_HOSTNAME${NC}"
fi

echo ""

# Continuar com outros métodos apenas se não encontrou via hostname
if [ "$SKIP_SLOW_METHODS" != "true" ]; then

# Método 2: ARP scan rápido para dispositivos Raspberry Pi
echo -e "${BLUE}📡 Método 2: Procurando MACs da Raspberry Pi Foundation...${NC}"
if command -v arp-scan &> /dev/null; then
    RASPBERRY_MACS="b8:27:eb dc:a6:32 e4:5f:01"
    
    # ARP scan rápido na interface padrão
    echo -e "   Executando ARP scan rápido..."
    arp_results=$(timeout 15 sudo arp-scan -l --timeout=500 --retry=1 2>/dev/null)
    
    for mac_prefix in $RASPBERRY_MACS; do
        ips=$(echo "$arp_results" | grep -i "$mac_prefix" | awk '{print $1}')
        for ip in $ips; do
            echo -ne "   Testando Raspberry Pi em ${YELLOW}$ip${NC} (MAC: $mac_prefix)... "
            if verify_autocore "$ip"; then
                echo -e "${GREEN}✅ AutoCore!${NC}"
                FOUND_IPS+=("$ip")
            else
                echo -e "${YELLOW}⚠️ Raspberry mas não AutoCore${NC}"
            fi
        done
    done
else
    echo -e "   ${YELLOW}⚠️ arp-scan não instalado, pulando este método${NC}"
fi

echo ""

# Método 3: nmap scan rápido para SSH
echo -e "${BLUE}📡 Método 3: Varredura nmap rápida...${NC}"
if command -v nmap &> /dev/null; then
    for network in $LOCAL_NETWORKS; do
        echo -e "   Verificando rede ${YELLOW}$network${NC}..."
        # Scan ultra-rápido: apenas hosts ativos com SSH
        ips=$(timeout 30 nmap -n -p 22 --open $network --max-retries=1 --host-timeout=1s --min-rate=1000 2>/dev/null | grep "Nmap scan report" | awk '{print $5}')
        
        for ip in $ips; do
            echo -ne "     Testando SSH em ${YELLOW}$ip${NC}... "
            if verify_autocore "$ip"; then
                echo -e "${GREEN}✅ AutoCore!${NC}"
                FOUND_IPS+=("$ip")
            else
                echo -e "${RED}❌${NC}"
            fi
        done
    done
else
    echo -e "   ${YELLOW}⚠️ nmap não instalado, pulando este método${NC}"
fi

echo ""

# Método 4: Tentar IPs conhecidos/comuns  
echo -e "${BLUE}📡 Método 4: Testando IPs conhecidos...${NC}"
KNOWN_IPS="10.0.10.118 10.0.10.119 192.168.1.100 192.168.0.100 192.168.1.10 192.168.1.50 192.168.0.50 10.0.0.100"

for ip in $KNOWN_IPS; do
    echo -ne "   Testando ${YELLOW}$ip${NC}... "
    if ping -c 1 -W 1 $ip &> /dev/null; then
        if verify_autocore "$ip"; then
            echo -e "${GREEN}✅ AutoCore encontrado!${NC}"
            FOUND_IPS+=("$ip")
        else
            echo -e "${RED}❌ Não é AutoCore${NC}"
        fi
    else
        echo -e "${RED}❌ Sem resposta${NC}"
    fi
done

echo ""

# Método 5: Ping sweep inteligente nas redes locais
echo -e "${BLUE}📡 Método 5: Ping sweep nas redes locais...${NC}"
for network_cidr in $LOCAL_NETWORKS; do
    echo -e "   Varrendo ${YELLOW}$network_cidr${NC}..."
    
    # Extrair base da rede
    network_base=$(echo $network_cidr | cut -d'/' -f1 | sed 's/\.[0-9]*$//')
    
    # Ping paralelo nos últimos octetos mais comuns
    common_hosts="1 10 50 100 118 119 200"
    for host in $common_hosts; do
        ip="$network_base.$host"
        (
            if ping -c 1 -W 1 $ip &> /dev/null; then
                if verify_autocore "$ip"; then
                    echo -e "   ${GREEN}✅ AutoCore encontrado: $ip${NC}"
                    echo "$ip" >> /tmp/found_autocore_ips_$$
                fi
            fi
        ) &
    done
    
    # Aguardar processos paralelos
    wait
    
    # Ler IPs encontrados
    if [ -f /tmp/found_autocore_ips_$$ ]; then
        while read ip; do
            FOUND_IPS+=("$ip")
        done < /tmp/found_autocore_ips_$$
        rm -f /tmp/found_autocore_ips_$$
    fi
done

# Fim do bloco condicional para métodos demorados
fi

echo ""

# Processar resultados
echo -e "${PURPLE}📋 Processando resultados...${NC}"

# Remover duplicatas
UNIQUE_IPS=($(printf '%s\n' "${FOUND_IPS[@]}" | sort -u))

# Mostrar resultados
if [ ${#UNIQUE_IPS[@]} -eq 0 ]; then
    echo -e "${RED}❌ Nenhum AutoCore encontrado automaticamente.${NC}"
    echo ""
    echo "Por favor, informe o IP manualmente:"
    read -p "IP do Raspberry Pi: " RASPBERRY_IP
    
    # Se usuário não digitou nada, usar IP padrão conhecido
    if [ -z "$RASPBERRY_IP" ]; then
        if [ -f "$IP_FILE" ]; then
            RASPBERRY_IP=$(cat "$IP_FILE")
            echo -e "${YELLOW}⚡ Usando último IP conhecido: $RASPBERRY_IP${NC}"
        else
            RASPBERRY_IP="10.0.10.119"
            echo -e "${YELLOW}⚡ Usando IP padrão: $RASPBERRY_IP${NC}"
        fi
    fi
elif [ ${#UNIQUE_IPS[@]} -eq 1 ]; then
    RASPBERRY_IP=${UNIQUE_IPS[0]}
    echo -e "${GREEN}✅ AutoCore encontrado: $RASPBERRY_IP${NC}"
else
    echo -e "${YELLOW}⚠️ Múltiplos dispositivos AutoCore encontrados:${NC}"
    for i in "${!UNIQUE_IPS[@]}"; do
        echo -e "   $((i+1)). ${UNIQUE_IPS[i]}"
    done
    echo ""
    echo "Escolha qual usar (1-${#UNIQUE_IPS[@]}):"
    read -p "Opção: " choice
    
    if [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 1 ] && [ $choice -le ${#UNIQUE_IPS[@]} ]; then
        RASPBERRY_IP=${UNIQUE_IPS[$((choice-1))]}
        echo -e "${GREEN}✅ Selecionado: $RASPBERRY_IP${NC}"
    else
        echo -e "${RED}❌ Opção inválida${NC}"
        exit 1
    fi
fi

# Validar IP
if [[ ! $RASPBERRY_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}❌ IP inválido: $RASPBERRY_IP${NC}"
    exit 1
fi

echo ""

# Teste final de conectividade e informações do sistema
echo -e "${BLUE}🔌 Teste final de conectividade...${NC}"
if ping -c 2 -W 3 $RASPBERRY_IP &> /dev/null; then
    echo -e "${GREEN}✅ Raspberry Pi acessível!${NC}"
    
    # Obter informações do sistema
    echo -e "${PURPLE}📊 Informações do sistema:${NC}"
    ssh_result=$(timeout 5 ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null autocore@$RASPBERRY_IP "
        echo '   Hostname:' \$(hostname)
        echo '   Uptime:' \$(uptime | cut -d',' -f1 | sed 's/.*up //')
        echo '   Kernel:' \$(uname -r)
        echo '   Memória:' \$(free -h | grep Mem | awk '{print \$3\"/\"\$2}')
        echo '   CPU:' \$(cat /proc/loadavg | cut -d' ' -f1)
        echo '   AutoCore:' \$([ -d /opt/autocore ] && echo 'Instalado' || echo 'Não instalado')
    " 2>/dev/null)
    
    if [ ! -z "$ssh_result" ]; then
        echo "$ssh_result"
    else
        echo -e "   ${YELLOW}⚠️ SSH conectando mas sem resposta de comandos${NC}"
    fi
    
    echo ""
    
    # Salvar IP descoberto
    echo "$RASPBERRY_IP" > "$IP_FILE"
    echo -e "${GREEN}💾 IP salvo${NC}"
    
    # Exportar variável
    export RASPBERRY_IP
    echo -e "${BLUE}📋 Variável exportada: RASPBERRY_IP=$RASPBERRY_IP${NC}"
    
    echo ""
    echo -e "${GREEN}🎉 AutoCore encontrado com sucesso!${NC}"
    echo -e "${BLUE}🚀 Para fazer deploy: make deploy${NC}"
    echo ""
    
    # Retornar IP para scripts que chamam este
    echo "$RASPBERRY_IP"
else
    echo -e "${RED}❌ Não foi possível conectar ao Raspberry Pi em $RASPBERRY_IP${NC}"
    echo -e "   Verifique se o dispositivo está ligado e na rede"
    exit 1
fi