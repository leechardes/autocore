# 🔧 Troubleshooting - Solução de Problemas

## 🎯 Visão Geral

Guias para resolução de problemas comuns no sistema AutoCore.

## 📖 Conteúdo

### Guias Gerais
- [COMMON-ISSUES.md](COMMON-ISSUES.md) - Problemas comuns e soluções
- [FAQ.md](FAQ.md) - Perguntas frequentes
- [DEBUG-GUIDE.md](DEBUG-GUIDE.md) - Como debugar problemas

### Por Componente
- [ESP32-ISSUES.md](ESP32-ISSUES.md) - Problemas com ESP32
- [MQTT-ISSUES.md](MQTT-ISSUES.md) - Problemas de comunicação MQTT
- [API-ISSUES.md](API-ISSUES.md) - Problemas da API
- [FLUTTER-ISSUES.md](FLUTTER-ISSUES.md) - Problemas do app Flutter

### Logs e Diagnóstico
- [LOG-ANALYSIS.md](LOG-ANALYSIS.md) - Como analisar logs
- [DIAGNOSTIC-TOOLS.md](DIAGNOSTIC-TOOLS.md) - Ferramentas de diagnóstico

## 🚨 Problemas Críticos

### Sistema não inicia
1. Verificar logs em `/var/log/autocore/`
2. Verificar serviços: `systemctl status autocore-*`
3. Verificar conectividade de rede
4. Verificar banco de dados

### ESP32 não conecta
1. Verificar configuração WiFi
2. Verificar MQTT broker
3. Verificar firewall/portas
4. Reset do dispositivo

### App não sincroniza
1. Verificar API backend
2. Verificar conectividade
3. Limpar cache do app
4. Verificar credenciais

## 💡 Dicas de Debug

1. **Sempre verifique logs primeiro**
2. **Isole o problema** - teste componentes individualmente
3. **Reproduza consistentemente** - identifique padrão
4. **Documente a solução** - ajude outros

---

**Última atualização**: 27/01/2025