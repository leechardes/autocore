# 🔧 Troubleshooting - Gateway AutoCore

## 🎯 Visão Geral

Guias para solução de problemas comuns no Gateway AutoCore.

## 📖 Conteúdo

### Problemas Comuns
- [COMMON-ISSUES.md](COMMON-ISSUES.md) - Problemas frequentes
- [FAQ.md](FAQ.md) - Perguntas frequentes
- [DEBUG-GUIDE.md](DEBUG-GUIDE.md) - Como debugar

### Por Componente
- [MQTT-ISSUES.md](MQTT-ISSUES.md) - Problemas MQTT
- [CONNECTION-ISSUES.md](CONNECTION-ISSUES.md) - Problemas de conexão
- [DATABASE-ISSUES.md](DATABASE-ISSUES.md) - Problemas de banco
- [PERFORMANCE-ISSUES.md](PERFORMANCE-ISSUES.md) - Problemas de performance

## 🚨 Problemas Críticos

### Gateway não inicia
```bash
# Verificar logs
tail -f logs/gateway.log

# Verificar serviços
systemctl status mosquitto
systemctl status autocore-gateway

# Testar conectividade
mosquitto_sub -t "#" -v
```

### MQTT não conecta
1. Verificar broker: `mosquitto_pub -t test -m test`
2. Verificar firewall: `sudo ufw status`
3. Verificar credenciais em `.env`
4. Reiniciar serviço: `sudo systemctl restart mosquitto`

### Alta latência
1. Verificar CPU: `htop`
2. Verificar memória: `free -h`
3. Verificar logs: `journalctl -u autocore-gateway`
4. Otimizar cache Redis

## 💡 Debug Tools

```bash
# MQTT debug
mosquitto_sub -t "autocore/#" -v

# Database debug
sqlite3 autocore.db ".tables"

# Network debug
netstat -tulpn | grep :1883

# System debug
dmesg | tail
```

---

**Última atualização**: 27/01/2025