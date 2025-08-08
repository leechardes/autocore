# Raspberry Pi Setup - AutoCore Gateway

## Visão Geral

Este diretório contém scripts e ferramentas para configurar o Raspberry Pi Zero 2W como gateway central do sistema AutoCore.

## Requisitos

- **Hardware**: Raspberry Pi Zero 2W
- **SD Card**: Mínimo 16GB (recomendado 32GB ou 64GB)
- **Fonte**: 5V/2.5A (importante para estabilidade)
- **Sistema**: Raspberry Pi OS 64-bit Desktop (recomendado)

## Scripts Disponíveis

### setup_raspberry_pi.sh
Script completo de setup automatizado que:
- Baixa a imagem do Raspberry Pi OS
- Verifica integridade com SHA256
- Grava no SD Card usando dd
- Configura WiFi e SSH automaticamente
- Ejeta o cartão com segurança

**Uso:**
```bash
sudo ./setup_raspberry_pi.sh
```

### monitor_boot.sh
Monitora continuamente a rede até encontrar o Raspberry Pi:
- Verifica a cada 10 segundos
- Notifica quando encontrar (som no macOS)
- Mostra IP e instruções de conexão

**Uso:**
```bash
./monitor_boot.sh
```

### find_raspberry.sh
Busca o Raspberry Pi na rede local:
- Tenta por hostname (raspberrypi.local)
- Varre a rede procurando por SSH
- Identifica por MAC address da Raspberry Pi Foundation

**Uso:**
```bash
./find_raspberry.sh
```

### download_64bit_desktop.sh
Baixa e prepara a versão recomendada (64-bit Desktop):
- Download da imagem oficial
- Verificação de integridade
- Preparação para gravação

**Uso:**
```bash
./download_64bit_desktop.sh
```

## Processo de Setup Recomendado

### Opção 1: Raspberry Pi Imager (Mais Fácil)

1. **Instale o Raspberry Pi Imager:**
   ```bash
   brew install --cask raspberry-pi-imager
   ```

2. **Configure no Imager:**
   - Device: Raspberry Pi Zero 2W
   - OS: Raspberry Pi OS (64-bit) - Desktop recomendado
   - Storage: Seu SD Card

3. **Configurações (engrenagem):**
   - Hostname: raspberrypi
   - Enable SSH: Yes
   - Username: pi
   - Password: sua escolha
   - Configure WiFi: Sua rede e senha
   - Locale: America/Sao_Paulo

### Opção 2: Script Automatizado

1. **Execute o setup completo:**
   ```bash
   sudo ./setup_raspberry_pi.sh
   ```

2. **Escolha opção 1** para setup completo

3. **Insira credenciais** quando solicitado

## Primeiro Boot

### Indicadores LED

- **Verde PISCANDO**: Boot normal, sistema carregando
- **Verde FIXO**: Problema com SD Card ou boot
- **Sem LED**: Problema de alimentação

### Tempo de Boot

- **Primeiro boot**: 3-5 minutos (expansão do filesystem)
- **Boots seguintes**: 1-2 minutos

### Conexão SSH

Após o boot completo:

```bash
# Por hostname
ssh pi@raspberrypi.local

# Por IP (descubra com find_raspberry.sh)
ssh pi@10.0.10.XXX

# Senha padrão
raspberry
```

## Troubleshooting

### Raspberry Pi não aparece na rede

1. **Verifique o LED verde** - Deve piscar durante boot
2. **Aguarde mais tempo** - Primeiro boot demora mais
3. **Verifique WiFi** - Nome e senha corretos?
4. **Use cabo Ethernet** - Para teste inicial

### Erro de verificação ao gravar

- Normal no macOS com verificação em 99%
- Se a gravação completou, pode ignorar
- Teste o cartão no Raspberry Pi

### LED verde fixo (não pisca)

1. **SD Card mal inserido** - Reinsira firmemente
2. **Imagem corrompida** - Regrave o SD Card
3. **SD Card incompatível** - Use outro cartão

### Sem LED aceso

1. **Cabo USB errado** - Use a porta PWR (canto)
2. **Fonte fraca** - Mínimo 5V/1A, ideal 5V/2.5A
3. **Cabo defeituoso** - Teste outro cabo

## Configuração Pós-Boot

Após conectar via SSH:

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências do AutoCore
sudo apt install -y python3-pip mosquitto mosquitto-clients git

# Expandir filesystem (se necessário)
sudo raspi-config --expand-rootfs

# Configurar hostname personalizado
sudo hostnamectl set-hostname autocore-gateway

# Reiniciar
sudo reboot
```

## Versões Testadas

- **Recomendada**: Raspberry Pi OS (64-bit) Desktop - 2024-07-04
- **Alternativa**: Raspberry Pi OS Lite (32-bit) - 2024-07-04
- **Evitar**: Versões 2025 (podem ser experimentais)

## Notas de Segurança

1. **Mude a senha padrão** após primeiro login
2. **Configure firewall** se exposto à internet
3. **Desabilite serviços** desnecessários
4. **Mantenha atualizado** com apt update/upgrade

## Suporte

- Documentação oficial: https://www.raspberrypi.com/documentation/
- AutoCore docs: /docs/gateway/
- Issues: https://github.com/leechardes/autocore/issues