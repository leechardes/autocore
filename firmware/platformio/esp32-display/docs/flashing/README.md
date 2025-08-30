# ⚡ Flashing e Programação

## 🎯 Visão Geral

Esta pasta contém documentação sobre procedimentos de flashing e programação do ESP32-Display.

## 📁 Conteúdo

### Métodos de Flashing
- **Serial Upload** - Via USB-UART
- **OTA Updates** - Over-the-Air (sem fio)
- **JTAG Debug** - Para desenvolvimento avançado

### Ambientes Suportados
- **PlatformIO** - Ambiente principal
- **Arduino IDE** - Compatibilidade
- **ESP-IDF** - Framework nativo

## 🔧 Quick Start

### Via PlatformIO (Recomendado)
```bash
# Na pasta do projeto
pio run --target upload

# Com monitor serial
pio run --target upload --target monitor
```

### Via Script de Desenvolvimento
```bash
# Usar o dev-manager.sh
./dev-manager.sh -f    # Flash
./dev-manager.sh -m    # Monitor
```

## 📋 Pré-requisitos

- ESP32 conectado via USB
- Drivers CH340/CP2102 instalados
- PlatformIO instalado
- Porta serial disponível

## 🔍 Troubleshooting

### Problemas Comuns
- **Erro de porta**: Verificar drivers USB-UART
- **Falha no upload**: Pressionar BOOT button
- **Timeout**: Verificar cabo USB
- **Permissão negada**: Verificar acesso à porta serial

## 📖 Documentação Relacionada

- [Development Guide](../DEVELOPMENT-GUIDE.md)
- [Hardware Guide](../HARDWARE-GUIDE.md)
- [Troubleshooting](../troubleshooting/)
- [OTA Updates](../networking/OTA-UPDATES.md)