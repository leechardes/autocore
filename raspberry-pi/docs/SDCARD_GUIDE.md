# 📱 Guia Completo de SD Cards para Raspberry Pi Zero 2W

## 🎯 Problema Comum: SD Cards Falhando

Se você está tendo problemas com SD Cards no Raspberry Pi, você não está sozinho! É um dos problemas mais comuns. Este guia vai ajudar a diagnosticar, corrigir e prevenir problemas.

## ⚠️ Sinais de SD Card com Problema

### Sintomas Críticos (Trocar Imediatamente)
- ❌ Sistema não inicializa (tela preta)
- ❌ Kernel panic durante boot
- ❌ Arquivos desaparecendo ou corrompidos
- ❌ Sistema travando constantemente
- ❌ Erro: "mmc0: timeout waiting for hardware interrupt"

### Sintomas de Alerta (Monitorar)
- ⚠️ Boot lento (>1 minuto)
- ⚠️ Aplicações travando ocasionalmente
- ⚠️ Mensagens de erro no dmesg sobre mmcblk0
- ⚠️ Velocidade de escrita < 10 MB/s
- ⚠️ Espaço sumindo misteriosamente

## 🔍 Como Testar seu SD Card

### 1. Teste Rápido (No Raspberry Pi)
```bash
# Baixar e executar script de teste
wget https://raw.githubusercontent.com/seu-usuario/autocore/main/raspberry-pi/scripts/test_sdcard.sh
chmod +x test_sdcard.sh
sudo ./test_sdcard.sh
```

### 2. Teste Completo (No Raspberry Pi)
```bash
# Script Python avançado
wget https://raw.githubusercontent.com/seu-usuario/autocore/main/raspberry-pi/scripts/test_sdcard_advanced.py
sudo python3 test_sdcard_advanced.py
```

### 3. Teste no Windows (Antes de Gravar)
Use o **H2testw** para verificar se o cartão é genuíno:
1. Baixe H2testw
2. Insira o SD Card
3. Execute o teste completo
4. Se houver erros = cartão falsificado ou defeituoso

### 4. Teste no Linux/Mac
```bash
# Teste de bad blocks (DEMORA!)
sudo badblocks -wsv /dev/sdX  # Substitua sdX pelo seu dispositivo

# Teste F3 (detecta cartões falsos)
sudo apt install f3
f3write /media/sdcard/
f3read /media/sdcard/
```

## 🛠️ Como Corrigir Problemas

### Correção Automática
```bash
# Baixar e executar script de correção
wget https://raw.githubusercontent.com/seu-usuario/autocore/main/raspberry-pi/scripts/fix_sdcard_issues.sh
chmod +x fix_sdcard_issues.sh
sudo ./fix_sdcard_issues.sh
```

### Correção Manual

#### 1. Verificar Sistema de Arquivos
```bash
# Forçar verificação no próximo boot
sudo touch /forcefsck
sudo reboot

# Ou verificar manualmente (sistema desmontado)
sudo umount /dev/mmcblk0p2
sudo fsck.ext4 -y /dev/mmcblk0p2
```

#### 2. Liberar Espaço
```bash
# Limpar logs
sudo journalctl --vacuum-time=7d

# Limpar cache
sudo apt clean
sudo apt autoremove

# Verificar maiores arquivos
du -h / | sort -rh | head -20
```

#### 3. Otimizar Performance
```bash
# Reduzir swappiness
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf

# Desabilitar serviços desnecessários
sudo systemctl disable bluetooth
sudo systemctl disable triggerhappy
```

## 🛒 Escolhendo o SD Card Certo

### ✅ Recomendados (Testados e Aprovados)

#### Premium (Melhor Performance)
1. **SanDisk Extreme Pro** (32GB/64GB)
   - Velocidade: 100MB/s leitura, 90MB/s escrita
   - Classe: A2, U3, V30
   - Preço: ~R$ 80-150

2. **Samsung EVO Select** (32GB/64GB)
   - Velocidade: 100MB/s leitura, 60MB/s escrita
   - Classe: A2, U3
   - Preço: ~R$ 60-120

3. **Kingston Canvas React Plus** (32GB/64GB)
   - Velocidade: 100MB/s leitura, 80MB/s escrita
   - Classe: A1, U3, V30
   - Preço: ~R$ 70-130

#### Custo-Benefício
1. **SanDisk Ultra** (32GB)
   - Velocidade: 100MB/s leitura, 40MB/s escrita
   - Classe: A1, U1
   - Preço: ~R$ 40-60

2. **Samsung EVO Plus** (32GB)
   - Velocidade: 95MB/s leitura, 20MB/s escrita
   - Classe: U1
   - Preço: ~R$ 35-50

3. **Lexar High-Performance** (32GB)
   - Velocidade: 100MB/s leitura, 30MB/s escrita
   - Classe: A1, U3
   - Preço: ~R$ 40-55

### ❌ EVITAR
- Marcas desconhecidas/genéricas
- Cartões muito baratos (< R$ 20)
- Cartões sem especificação de classe
- Vendedores não oficiais (alto risco de falsificação)

### 📊 Especificações Importantes

#### Classes de Velocidade
- **Class 10**: Mínimo 10MB/s (OK para uso básico)
- **U1**: Mínimo 10MB/s
- **U3**: Mínimo 30MB/s (recomendado)
- **V30**: Mínimo 30MB/s para vídeo

#### Classes de Aplicação (Importante!)
- **A1**: 1500 IOPS leitura, 500 IOPS escrita
- **A2**: 4000 IOPS leitura, 2000 IOPS escrita (melhor para OS)

## 🔧 Configuração Ideal para Raspberry Pi

### 1. Preparação do Cartão

#### No Windows (Raspberry Pi Imager)
1. Baixe o Raspberry Pi Imager
2. Escolha o OS (Raspberry Pi OS Lite)
3. Configure (Ctrl+Shift+X):
   - Hostname
   - SSH habilitado
   - WiFi
   - Usuário/senha
4. Grave o cartão

#### No Linux
```bash
# Baixar imagem
wget https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2025-05-13/2025-05-13-raspios-bookworm-armhf-lite.img.xz

# Descompactar
xz -d 2025-05-13-raspios-bookworm-armhf-lite.img.xz

# Gravar (CUIDADO com o dispositivo!)
sudo dd if=2025-05-13-raspios-bookworm-armhf-lite.img of=/dev/sdX bs=4M status=progress conv=fsync
```

### 2. Primeira Inicialização

```bash
# Expandir sistema de arquivos
sudo raspi-config --expand-rootfs

# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar ferramentas essenciais
sudo apt install -y htop iotop dstat smartmontools

# Configurar monitoramento
sudo crontab -e
# Adicionar:
0 */6 * * * /usr/local/bin/check_sdcard_health.sh
```

## 📈 Monitoramento Contínuo

### Script de Monitoramento Automático
```bash
#!/bin/bash
# Salvar como /usr/local/bin/monitor_sdcard.sh

# Verificar velocidade
SPEED=$(dd if=/dev/zero of=/tmp/test bs=1M count=10 conv=fdatasync 2>&1 | grep -oP '\d+\.\d+ MB/s')
echo "$(date): Velocidade: $SPEED" >> /var/log/sdcard_monitor.log

# Verificar erros
ERRORS=$(dmesg | grep -c "mmcblk0.*error")
if [ $ERRORS -gt 0 ]; then
    echo "$(date): ALERTA! $ERRORS erros detectados" >> /var/log/sdcard_monitor.log
fi

# Verificar espaço
USAGE=$(df / | tail -1 | awk '{print $5}')
echo "$(date): Uso de disco: $USAGE" >> /var/log/sdcard_monitor.log
```

### Comandos Úteis para Diagnóstico

```bash
# Ver erros do SD Card
dmesg | grep mmc

# Verificar velocidade de leitura
sudo hdparm -tT /dev/mmcblk0

# Verificar SMART (se suportado)
sudo smartctl -a /dev/mmcblk0

# Ver estatísticas de I/O
iostat -x 1

# Monitorar em tempo real
watch -n 1 'dmesg | grep -i error | tail -5'
```

## 🚀 Otimizações para Maior Durabilidade

### 1. Reduzir Escritas

```bash
# Desabilitar swap
sudo dphys-swapfile swapoff
sudo systemctl disable dphys-swapfile

# Logs em RAM (log2ram)
sudo apt install log2ram

# Montar /tmp em RAM
echo "tmpfs /tmp tmpfs defaults,noatime,nosuid,size=100m 0 0" | sudo tee -a /etc/fstab
```

### 2. Configurar Mount Options

```bash
# Editar /etc/fstab
# Adicionar noatime para reduzir escritas
/dev/mmcblk0p2 / ext4 defaults,noatime 0 1
```

### 3. Backup Automático

```bash
# Script de backup diário
cat > /usr/local/bin/daily_backup.sh << 'EOF'
#!/bin/bash
rsync -av --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/tmp / /backup/
EOF

chmod +x /usr/local/bin/daily_backup.sh
```

## 🆘 Recuperação de Emergência

### Se o Sistema Não Inicializa

1. **No Windows:**
   - Use o Win32DiskImager para fazer imagem do cartão
   - Tente recuperar arquivos com Recuva ou PhotoRec

2. **No Linux:**
   ```bash
   # Fazer backup da imagem
   sudo dd if=/dev/sdX of=backup.img bs=4M
   
   # Tentar montar partições
   sudo mount -o loop,offset=$((532480*512)) backup.img /mnt
   
   # Recuperar arquivos
   sudo photorec backup.img
   ```

### Recuperar Dados Específicos

```bash
# Montar cartão em outro Linux
sudo mount /dev/sdX2 /mnt

# Copiar configurações importantes
cp -r /mnt/etc/network /backup/
cp -r /mnt/home/pi /backup/
cp /mnt/etc/wpa_supplicant/wpa_supplicant.conf /backup/
```

## 📋 Checklist de Manutenção

### Diário
- [ ] Verificar logs de erro: `dmesg | grep -i error`
- [ ] Verificar espaço: `df -h`

### Semanal
- [ ] Executar teste rápido: `./test_sdcard.sh`
- [ ] Verificar velocidade: `dd if=/dev/zero of=/tmp/test bs=1M count=10`
- [ ] Limpar logs antigos: `sudo journalctl --vacuum-time=7d`

### Mensal
- [ ] Executar teste completo: `sudo python3 test_sdcard_advanced.py`
- [ ] Fazer backup completo
- [ ] Verificar atualizações: `sudo apt update && sudo apt upgrade`
- [ ] Executar fsck: `sudo touch /forcefsck && sudo reboot`

## 🎓 Conclusão

SD Cards são o ponto fraco do Raspberry Pi, mas com:
- ✅ Cartão de qualidade
- ✅ Monitoramento constante
- ✅ Backups regulares
- ✅ Otimizações adequadas

Você pode ter um sistema confiável e durável!

**Dica Final:** Mantenha sempre um SD Card de backup pronto com sua imagem configurada. Quando houver problemas, você pode trocar rapidamente e voltar a operar em minutos!

---

*Última atualização: Agosto 2025*  
*Testado com: Raspberry Pi Zero 2W + Raspberry Pi OS Bookworm*