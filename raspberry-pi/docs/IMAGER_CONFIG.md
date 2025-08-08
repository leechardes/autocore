# 🔧 Configuração do Raspberry Pi Imager

## 📥 Download e Instalação

### macOS
```bash
# Download direto
https://downloads.raspberrypi.org/imager/imager_latest.dmg

# Ou via Homebrew
brew install --cask raspberry-pi-imager
```

### Windows
```bash
https://downloads.raspberrypi.org/imager/imager_latest.exe
```

### Linux
```bash
# Ubuntu/Debian
sudo apt install rpi-imager

# Ou AppImage
https://downloads.raspberrypi.org/imager/imager_latest_amd64.AppImage
```

## ⚙️ Configurações Pré-definidas para AutoCore

### 1. Tela Principal

![Imager Main Screen]
1. **CHOOSE DEVICE:** Raspberry Pi Zero 2 W
2. **CHOOSE OS:** Use custom → `../images/2025-05-13-raspios-bookworm-armhf-lite.img.xz`
3. **CHOOSE STORAGE:** Seu cartão SD

### 2. Configurações Avançadas (⚙️)

Pressione `Ctrl+Shift+X` ou clique no ⚙️

#### 📋 Aba "General"

```yaml
Image customization options:
  ✅ Set hostname: autocore
  
  ✅ Enable SSH
     ◉ Use password authentication
  
  ✅ Set username and password:
     Username: leechardes
     Password: lee159753
  
  ✅ Configure wireless LAN:
     SSID: [SUA_REDE_WIFI]
     Password: [SENHA_WIFI]
     Wireless LAN country: BR
  
  ✅ Set locale settings:
     Time zone: America/Sao_Paulo
     Keyboard layout: br
```

#### 🔐 Aba "Services"

```yaml
Services:
  ✅ Enable SSH
     ◉ Use password authentication
     ◯ Allow public-key authentication only
```

#### 📊 Aba "Options"

```yaml
Options:
  ✅ Eject media when finished
  ✅ Enable telemetry
  ☐ Play sound when finished
```

### 3. Configuração Salva (config.txt)

O Imager criará automaticamente estes arquivos no boot partition:

#### `/boot/ssh`
Arquivo vazio que habilita SSH

#### `/boot/wpa_supplicant.conf`
```conf
country=BR
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="SUA_REDE_WIFI"
    psk="SENHA_WIFI"
    key_mgmt=WPA-PSK
}
```

#### `/boot/userconf.txt`
```
leechardes:$6$[hash_da_senha]
```

## 🚀 Processo de Gravação

### 1. Confirmar Configurações
- Revisar todas as configurações
- Clicar em "SAVE" para salvar preferências

### 2. Iniciar Gravação
- Clicar em "WRITE"
- Confirmar que deseja apagar o cartão SD
- Digite a senha do sistema se solicitado

### 3. Progresso
```
Writing... [===========] 100%
Verifying... [===========] 100%
```

### 4. Conclusão
- "Write Successful" 
- Cartão será ejetado automaticamente
- Pronto para usar na Pi!

## 💾 Salvando Configurações

### Exportar Configurações
```bash
# As configurações são salvas em:
~/.config/Raspberry Pi/Imager.conf  # Linux
~/Library/Preferences/org.raspberrypi.Imager.plist  # macOS
%APPDATA%\Raspberry Pi\Imager.ini  # Windows
```

### Configuração JSON para AutoCore
Crie `autocore-imager-config.json`:

```json
{
  "hostname": "autocore",
  "enable_ssh": true,
  "username": "leechardes",
  "password": "lee159753",
  "wifi": {
    "ssid": "YOUR_WIFI_SSID",
    "password": "YOUR_WIFI_PASSWORD",
    "country": "BR"
  },
  "locale": {
    "timezone": "America/Sao_Paulo",
    "keyboard": "br"
  },
  "firstrun": {
    "expand_filesystem": true,
    "update_packages": true
  }
}
```

## 🔍 Verificação Pós-Gravação

### 1. Verificar Arquivos no SD Card
```bash
# Monte o cartão SD e verifique:
ls -la /Volumes/boot/  # macOS
ls -la /media/boot/    # Linux

# Deve conter:
# - ssh (arquivo vazio)
# - wpa_supplicant.conf
# - userconf.txt
# - config.txt
# - cmdline.txt
```

### 2. Teste de Conectividade
```bash
# Após inserir na Pi e ligar
ping autocore.local

# Resposta esperada:
# 64 bytes from autocore.local: icmp_seq=1 ttl=64 time=5.12 ms
```

## 🛠️ Customizações Avançadas

### config.txt Personalizado
Adicione ao `/boot/config.txt`:

```ini
# Otimizações para Pi Zero 2 W
gpu_mem=16
dtoverlay=disable-bt
dtoverlay=disable-wifi  # Apenas se usar Ethernet
```

### cmdline.txt Modificado
```
console=serial0,115200 console=tty1 root=PARTUUID=xxx rootfstype=ext4 fsck.repair=yes rootwait quiet init=/usr/lib/raspi-config/init_resize.sh
```

## 📝 Troubleshooting

### Imager não reconhece o SD Card
```bash
# macOS
diskutil list
diskutil unmountDisk /dev/diskN
```

### Erro de permissão ao gravar
- Execute o Imager como administrador
- No macOS: pode precisar permitir em System Preferences → Security

### WiFi não conecta
- Verifique se o país está correto (BR)
- Confirme SSID e senha (case sensitive)
- Tente conexão 2.4GHz (Pi Zero não suporta 5GHz)

## 🎯 Dicas

1. **Sempre use a versão mais recente do Imager**
2. **SD Card Classe 10 ou superior**
3. **Faça backup das configurações**
4. **Use cartões de 16GB+ para ter espaço**
5. **Verifique a gravação (não pule)**

---

**Versão do Imager:** 1.8.5+
**Compatível com:** Raspberry Pi Zero 2 W
**Imagem:** Raspberry Pi OS Bookworm Lite (32-bit)