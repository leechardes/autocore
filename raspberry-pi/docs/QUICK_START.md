# ⚡ Quick Start - Raspberry Pi Zero 2 W

## 🎯 Setup Rápido em 5 Minutos

### 1️⃣ Gravar Imagem no SD Card

```bash
# Usando Raspberry Pi Imager
1. Abra o Imager
2. Choose OS → Use custom → Selecione: 
   AutoCore/raspberry-pi/images/2025-05-13-raspios-bookworm-armhf-lite.img.xz
3. Configure (⚙️):
   - Hostname: autocore
   - SSH: Enable
   - User: leechardes / lee159753
   - WiFi: Sua rede
4. Write
```

### 2️⃣ Primeiro Boot

```bash
# Inserir SD Card → Ligar Pi → Aguardar 2 min

# Conectar via SSH
ssh leechardes@autocore.local
# Senha: lee159753
```

### 3️⃣ Setup Automático

```bash
# Copiar e colar no terminal (uma linha por vez)
cd ~
wget https://raw.githubusercontent.com/leechardes/AutoCore/main/scripts/pi_initial_setup.sh
chmod +x pi_initial_setup.sh
./pi_initial_setup.sh
```

**⏱️ Aguarde ~10 minutos** - O script fará tudo automaticamente!

### 4️⃣ Deploy do AutoCore

```bash
# No seu Mac (não na Pi)
cd ~/Projetos/AutoCore
./scripts/deploy_to_pi.sh
# Escolha opção 1 (Deploy completo)
```

### 5️⃣ Verificar

```bash
# Na Pi
ac-status  # Ver status geral
ac-mqtt    # Ver mensagens MQTT
```

## ✅ Pronto!

### Acessos:
- **SSH:** `ssh leechardes@autocore.local`
- **API:** http://autocore.local:8000
- **MQTT:** autocore.local:1883

### Comandos Úteis:
```bash
ac-status   # Status do sistema
ac-monitor  # Monitor em tempo real
ac-logs     # Ver logs
ac-restart  # Reiniciar serviços
```

## 🆘 Problemas?

### Não conecta SSH?
```bash
# Descobrir IP
ping autocore.local
# ou verificar no roteador
```

### Serviços não funcionam?
```bash
# Reiniciar tudo
ac-restart

# Ver logs
ac-logs
```

---
**Setup completo em:** ~/AutoCore/raspberry-pi/docs/SETUP_GUIDE.md