# 🚀 Guia de Deploy - AutoCore

## 📊 Configuração de Portas

### Serviços e Portas

| Serviço | Porta | Arquivo Systemd | Status |
|---------|-------|-----------------|--------|
| **Frontend** | 8080 | autocore-config-frontend.service | ✅ Configurado |
| **Backend API** | 8081 | autocore-config-app.service | ✅ Configurado |
| **Gateway** | - | autocore-gateway.service | ✅ Sem porta HTTP |
| **MQTT Broker** | 1883 | mosquitto.service | ✅ Sistema |

## 🧹 Comandos de Limpeza

### Makefile - Comandos Disponíveis

```bash
# Limpeza básica (preserva .env e credenciais)
make clean

# Limpa arquivos locais (remove node_modules, .venv, etc)
make clean-local

# Limpa instalação completa no Raspberry Pi
make clean-pi

# Remove apenas ambientes virtuais
make clean-venv

# Remove apenas node_modules
make clean-node

# Limpa tudo localmente
make clean-all
```

### Limpeza no Raspberry Pi

```bash
# Via Makefile (recomendado)
make clean-pi

# Direto via script
ssh autocore@10.0.10.119
cd /opt/autocore/deploy
sudo ./clean_raspberry.sh
```

## 📦 Deploy Completo

### 1. Preparação Local

```bash
# Verificar configurações
cat deploy/.credentials

# Limpar instalação anterior (se necessário)
make clean-pi

# Deploy limpo
make deploy
```

### 2. Arquivos de Configuração

#### `.credentials` (Deploy)
```bash
RASPBERRY_USER=autocore
RASPBERRY_PASS=SUA_SENHA_SSH
RASPBERRY_IP=10.0.10.119
MQTT_USERNAME=autocore
MQTT_PASSWORD=SUA_SENHA_MQTT
```

#### `.env` (Serviços)

**Backend** (`config-app/backend/.env`):
```env
CONFIG_APP_PORT=8081
CONFIG_APP_HOST=0.0.0.0
MQTT_USERNAME=autocore
MQTT_PASSWORD=SUA_SENHA_MQTT
SECRET_KEY=<gerada-automaticamente>
```

**Frontend** (`config-app/frontend/.env`):
```env
VITE_PORT=8080
VITE_API_PORT=8081
VITE_API_URL=http://localhost:8081
```

**Gateway** (`gateway/.env`):
```env
MQTT_USERNAME=autocore
MQTT_PASSWORD=SUA_SENHA_MQTT
SECRET_KEY=<gerada-automaticamente>
```

## 🔄 Processo de Deploy

### Deploy Inicial
```bash
make deploy
# Escolha opção 2: Setup completo
```

### Atualização
```bash
make deploy
# Escolha opção 1: Apenas reiniciar serviços
```

### Verificação
```bash
# Status dos serviços
make status

# Logs em tempo real
make logs-gateway
make logs-config
make logs-frontend

# URLs de acesso
echo "Frontend: http://10.0.10.119:8080"
echo "Backend API: http://10.0.10.119:8081"
echo "MQTT: 10.0.10.119:1883"
```

## 🛠️ Troubleshooting

### Problema: Porta já em uso

```bash
# Verificar qual processo está usando a porta
sudo lsof -i :8080
sudo lsof -i :8081

# Matar processo se necessário
sudo kill -9 <PID>
```

### Problema: Serviços não iniciam

```bash
# Verificar logs
sudo journalctl -u autocore-config-app -n 50
sudo journalctl -u autocore-config-frontend -n 50
sudo journalctl -u autocore-gateway -n 50

# Reiniciar serviços
sudo systemctl restart autocore-config-app
sudo systemctl restart autocore-config-frontend
sudo systemctl restart autocore-gateway
```

### Problema: MQTT não conecta

```bash
# Verificar Mosquitto
sudo systemctl status mosquitto

# Verificar autenticação
mosquitto_sub -h localhost -u autocore -P SUA_SENHA -t test -C 1

# Verificar arquivo de senhas
sudo cat /etc/mosquitto/passwd
```

## 📋 Checklist de Deploy

### Pré-Deploy
- [ ] Credenciais configuradas em `.credentials`
- [ ] Secrets seguros gerados
- [ ] Raspberry Pi acessível na rede
- [ ] Mosquitto configurado com autenticação

### Durante Deploy
- [ ] Arquivos copiados com sucesso
- [ ] Dependências instaladas
- [ ] Serviços systemd instalados
- [ ] Configurações .env criadas

### Pós-Deploy
- [ ] Todos os serviços rodando
- [ ] Frontend acessível na porta 8080
- [ ] Backend API respondendo na porta 8081
- [ ] Gateway conectado ao MQTT
- [ ] Logs sem erros críticos

## 🔒 Segurança

### Secrets Gerados no Deploy
- SECRET_KEY para Backend (64 hex)
- SECRET_KEY para Gateway (64 hex)
- Senhas MQTT configuradas

### Firewall (Opcional)
```bash
# Permitir apenas portas necessárias
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 8080/tcp  # Frontend
sudo ufw allow 8081/tcp  # Backend API
sudo ufw allow 1883/tcp  # MQTT
sudo ufw enable
```

## 📝 Notas Importantes

1. **Nunca** commitar arquivos `.env` reais
2. **Sempre** usar senhas diferentes em produção
3. **Verificar** logs após cada deploy
4. **Documentar** mudanças de configuração
5. **Testar** em ambiente de desenvolvimento primeiro

---

**Última atualização**: Janeiro 2025  
**Versão**: 1.0.0