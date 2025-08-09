#!/bin/bash

# Script para configurar Mosquitto com autenticação no macOS
# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🦟 Configurando Mosquitto com autenticação${NC}"
echo "========================================"

# Verificar se Mosquitto está instalado
if ! command -v mosquitto &> /dev/null; then
    echo -e "${RED}❌ Mosquitto não está instalado${NC}"
    echo "Instale com: brew install mosquitto"
    exit 1
fi

# Diretório de configuração do Mosquitto (Homebrew)
MOSQUITTO_DIR="/opt/homebrew/etc/mosquitto"

# Criar arquivo de senha temporário
echo -e "${YELLOW}📝 Criando arquivo de senhas...${NC}"
TEMP_PASSWD="/tmp/mosquitto_passwd.tmp"

# Criar entrada de senha (formato: username:password)
echo "autocore:kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr" > $TEMP_PASSWD

# Gerar arquivo de senha criptografado
mosquitto_passwd -U $TEMP_PASSWD

# Mover para o diretório do Mosquitto
echo -e "${YELLOW}🔐 Instalando arquivo de senhas...${NC}"
sudo mv $TEMP_PASSWD $MOSQUITTO_DIR/passwd
sudo chmod 600 $MOSQUITTO_DIR/passwd

# Criar arquivo de configuração customizado
echo -e "${YELLOW}⚙️  Configurando Mosquitto...${NC}"
cat > /tmp/autocore.conf << EOF
# AutoCore MQTT Configuration
listener 1883
allow_anonymous false
password_file $MOSQUITTO_DIR/passwd
EOF

# Instalar configuração
sudo mv /tmp/autocore.conf $MOSQUITTO_DIR/autocore.conf

# Atualizar mosquitto.conf principal para incluir nossa config
if ! grep -q "include_dir" $MOSQUITTO_DIR/mosquitto.conf; then
    echo -e "${YELLOW}📝 Atualizando mosquitto.conf...${NC}"
    echo "" | sudo tee -a $MOSQUITTO_DIR/mosquitto.conf
    echo "# Include AutoCore configuration" | sudo tee -a $MOSQUITTO_DIR/mosquitto.conf
    echo "include $MOSQUITTO_DIR/autocore.conf" | sudo tee -a $MOSQUITTO_DIR/mosquitto.conf
fi

# Reiniciar Mosquitto
echo -e "${YELLOW}🔄 Reiniciando Mosquitto...${NC}"
brew services restart mosquitto

sleep 2

# Testar conexão
echo -e "${YELLOW}🧪 Testando conexão...${NC}"
timeout 2 mosquitto_sub -h localhost -u autocore -P kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr -t test -C 1 2>&1

if [ $? -eq 124 ] || [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Mosquitto configurado com sucesso!${NC}"
    echo ""
    echo "Credenciais configuradas:"
    echo "  Usuário: autocore"
    echo "  Senha: kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr"
    echo ""
    echo "Teste com:"
    echo "  mosquitto_pub -h localhost -u autocore -P kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr -t test -m 'Hello'"
else
    echo -e "${RED}❌ Erro ao configurar Mosquitto${NC}"
    echo "Verifique os logs: brew services info mosquitto"
fi