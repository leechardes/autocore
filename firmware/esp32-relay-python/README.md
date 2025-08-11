# ESP32 Relay Controller

Sistema de controle de relés para ESP32 com interface web de configuração.

## 🚀 Quick Start

```bash
# 1. Instalar ferramentas
make install-tools

# 2. Instalar firmware MicroPython (primeira vez apenas)
make flash

# 3. Enviar código
make deploy

# 4. Ver logs
make monitor
```

## 📡 Configuração WiFi

1. **Conecte ao WiFi:** `ESP32-xxxxxx` (senha: `12345678`)
2. **Acesse:** http://192.168.4.1
3. **Configure WiFi e Backend**
4. **Sistema reinicia automaticamente**

## 🛠️ Comandos Disponíveis

| Comando | Descrição |
|---------|-----------|
| `make help` | Lista todos os comandos |
| `make install-tools` | Instala ampy e esptool |
| `make flash` | Instala firmware MicroPython |
| `make deploy` | Envia main.py para ESP32 |
| `make monitor` | Monitor serial com logs |
| `make restart` | Reinicia ESP32 |
| `make format` | Formata ESP32 (apaga tudo) |
| `make clean` | Limpa arquivos temporários |

## ⚙️ Configuração do Sistema

### Backend
- **IP:** 192.168.1.100 (padrão)
- **Porta:** 8000 (padrão)

### MQTT (Opcional)
- **Broker:** 192.168.1.100 (padrão)
- **Porta:** 1883 (padrão)

## 🔧 Hardware

- **ESP32:** Qualquer modelo com WiFi
- **Relés:** Conectar aos pinos GPIO (configurável)
- **Alimentação:** 5V/2A recomendado

## 📁 Estrutura

```
esp32-relay-python/
├── main.py              # Código principal
├── Makefile            # Comandos make
├── README.md           # Esta documentação
├── scripts/            # Scripts de automação
│   ├── deploy.py      # Deploy via ampy
│   ├── monitor.py     # Monitor serial
│   ├── flash.py       # Flash firmware
│   └── restart.py     # Restart ESP32
└── firmware/
    └── esp32-micropython.bin  # Firmware MicroPython
```

## 🔍 Troubleshooting

### ESP32 não conecta
- Verificar cabo USB
- Verificar porta serial (`/dev/cu.usbserial-*`)
- Pressionar botão BOOT durante flash

### WiFi não conecta
- Verificar SSID e senha
- Verificar sinal WiFi
- Usar reset de fábrica no painel web

### Deploy falha
```bash
# Verificar conexão
make check

# Tentar restart
make restart

# Verificar arquivos
make list-files
```

## 📱 Interface Web

Após configuração, acesse a interface via IP da rede:
- **Dashboard:** Status e controles
- **Configuração:** Alterar parâmetros
- **Reset:** Voltar ao padrão de fábrica

## 🔒 Segurança

- **AP Mode:** Senha fixa `12345678`
- **Station Mode:** Protegido pela rede WiFi
- **Reset:** Confirmação obrigatória

## 📊 Monitoramento

```bash
# Logs em tempo real
make monitor

# Verificar status
make check

# Ver arquivos no ESP32
make list-files
```

## 🆘 Reset de Fábrica

**Via Web:** Botão "Reset de Fábrica" na interface
**Via Hardware:** Segurar botão BOOT + RESET por 3 segundos

## 📄 Licença

MIT License - Use livremente em projetos pessoais e comerciais.

---

**Versão:** 2.0  
**Autor:** AutoCore Team  
**Atualização:** $(date +'%d/%m/%Y')