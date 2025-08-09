# 🚀 Deploy do AutoCore no Raspberry Pi

## 📋 Estrutura dos Scripts

```
deploy/
├── deploy_to_raspberry.sh    # Deploy interativo (pergunta o que fazer)
├── deploy_auto.sh            # Deploy totalmente automático
├── raspberry_setup.sh         # Setup inicial no Pi (executado remotamente)
├── deploy.sh                  # Gerenciamento contínuo (no Pi)
├── systemd/                   # Arquivos de serviço
│   ├── autocore-gateway.service
│   └── autocore-config-app.service
└── storage-config-64gb.sh     # Config para SD Card 64GB
```

## 🔧 Instalação Inicial

> **Pré-requisito**: O usuário `autocore` já deve estar criado na imagem do Raspberry Pi.

### Descobrir IP do Raspberry Pi

```bash
# Descobrir automaticamente o IP
cd /Users/leechardes/Projetos/AutoCore
make find-pi

# Ou usar hostname (se mDNS estiver configurado)
ping autocore.local
```

### Deploy com Makefile (Recomendado)

```bash
# Deploy completo
make deploy

# Ou especificar IP manualmente
RASPBERRY_IP=192.168.1.100 make deploy
```

### Deploy com Script

```bash
cd /Users/leechardes/Projetos/AutoCore/deploy
./deploy_to_raspberry.sh
```

Este script:
- Descobre o IP automaticamente ou pergunta
- Solicita credenciais (não armazena)
- Detecta se usa chave SSH ou senha
- Copia arquivos para o Pi
- Pergunta se quer executar o setup
- Permite escolher o que fazer

### Configurar Chave SSH (Recomendado)

Para evitar digitar senha a cada deploy:

```bash
# Gerar chave SSH se não tiver
ssh-keygen -t rsa -b 4096

# Copiar chave para o Raspberry Pi
ssh-copy-id autocore@<IP_DO_RASPBERRY>
```

## 🔄 Uso Contínuo (Atualizações)

### Deploy Rápido (do Mac)

```bash
# Deploy completo
./deploy_to_raspberry.sh

# Depois no Pi:
ssh leechardes@10.0.10.119
cd /opt/autocore
./deploy.sh all deploy
```

### Gerenciamento de Serviços (no Pi)

```bash
# Ver status de todos os serviços
./deploy.sh all status

# Deploy individual
./deploy.sh gateway deploy
./deploy.sh config-app deploy
./deploy.sh database deploy

# Apenas reiniciar
./deploy.sh gateway restart
./deploy.sh config-app restart

# Apenas atualizar código (sem reiniciar)
./deploy.sh gateway update
```

## 🌐 URLs de Acesso

- **Config App**: http://10.0.10.119:3000 ou http://autocore.local:3000
- **Backend API**: http://10.0.10.119:5000 ou http://autocore.local:5000
- **MQTT Broker**: 10.0.10.119:1883 ou autocore.local:1883

## 📊 Comandos Úteis

### 🔍 Scripts de Diagnóstico e Manutenção

#### Verificação Rápida de Status
```bash
# No Raspberry Pi
cd /opt/autocore/deploy
./check_status.sh          # Status resumido
./check_status.sh --verbose # Status detalhado com logs
```

#### Recuperação Automática
```bash
# Tenta corrigir problemas comuns automaticamente
sudo ./auto_recovery.sh

# Agendar verificação automática a cada 30 minutos
sudo crontab -e
# Adicionar: */30 * * * * /opt/autocore/deploy/auto_recovery.sh --cron
```

### 📜 Logs e Relatórios

#### Relatórios de Instalação
```bash
# Ver último relatório
cat /opt/autocore/last_installation_report.log

# Listar todos os relatórios
ls -la /opt/autocore/installation_report_*.log
```

#### Logs em Tempo Real
```bash
# Gateway
sudo journalctl -u autocore-gateway -f

# Config App Backend
sudo journalctl -u autocore-config-app -f

# Config App Frontend
sudo journalctl -u autocore-config-frontend -f

# Mosquitto
sudo journalctl -u mosquitto -f
```

### ⚙️ Gerenciamento de Serviços

#### Status dos Serviços
```bash
sudo systemctl status autocore-gateway
sudo systemctl status autocore-config-app
sudo systemctl status autocore-config-frontend
sudo systemctl status mosquitto
```

#### Reiniciar Serviços
```bash
# Reiniciar todos os serviços AutoCore
sudo systemctl restart autocore-*

# Reiniciar serviços individuais
sudo systemctl restart autocore-gateway
sudo systemctl restart autocore-config-app
sudo systemctl restart autocore-config-frontend
sudo systemctl restart mosquitto
```

## 🔐 Configuração de Acesso

### SSH Raspberry Pi
- **Usuário padrão**: autocore
- **Hostname**: autocore.local
- **IP**: Descobrir com `make find-pi`

### MQTT
- **Usuário**: autocore
- **Senha**: autocore123

> **Nota**: As credenciais SSH devem ser fornecidas durante o deploy ou configuradas via chave SSH.

## 📁 Estrutura no Raspberry Pi

```
/opt/autocore/
├── database/          # Banco de dados SQLite
│   └── autocore.db
├── gateway/          # Gateway MQTT
│   ├── src/
│   ├── .venv/
│   └── requirements.txt
├── config-app/       # Aplicação de configuração
│   ├── backend/     # API FastAPI
│   │   ├── .venv/
│   │   └── main.py
│   └── frontend/    # Interface React
│       └── node_modules/
├── logs/            # Logs da aplicação
└── .env            # Configurações
```

## 🐛 Troubleshooting

### Serviço não inicia

```bash
# Ver logs detalhados
sudo journalctl -u nome-do-serviço -n 100 --no-pager

# Testar manualmente
cd /opt/autocore/gateway
source .venv/bin/activate
python src/main.py
```

### MQTT não conecta

```bash
# Testar conexão
mosquitto_sub -h localhost -u autocore -P autocore123 -t test

# Verificar se está rodando
sudo netstat -tlnp | grep 1883
```

### Permissões

```bash
# Corrigir permissões
sudo chown -R leechardes:leechardes /opt/autocore
```

### Porta em uso

```bash
# Ver portas
sudo lsof -i :3000
sudo lsof -i :5000
sudo lsof -i :1883

# Matar processo
sudo kill -9 <PID>
```

## 📝 Notas Importantes

1. **Sempre** use `/opt/autocore` como diretório base
2. **Nunca** rode serviços como root
3. **Sempre** use ambientes virtuais Python (.venv)
4. **Logs** são gerenciados pelo systemd/journald
5. **Backup** regular do banco de dados em `/opt/autocore/database/autocore.db`

## 🆘 Suporte

Em caso de problemas:
1. Verifique os logs com `journalctl`
2. Confirme que o Mosquitto está rodando
3. Verifique as permissões dos arquivos
4. Teste cada serviço manualmente