# 📊 Guia Completo de Displays para AutoCore

## 🎯 Matriz de Decisão Rápida

| Tamanho | Uso Principal | Melhor Opção | Custo Total |
|---------|---------------|--------------|-------------|
| **2.8"-3.5"** | Controle básico IoT | ESP32 + LVGL | R$ 150-250 |
| **7"** | Interface touch simples | Nextion/TJC | R$ 400-600 |
| **7"-10"** | Dashboard multimídia | Raspberry Pi + Flutter | R$ 900-1200 |
| **10"-15"** | Terminal/Kiosk completo | Mini PC + Touch Monitor | R$ 2000-3000 |

---

## 📱 Cenário 1: Display Pequeno (2.8"-3.5") - ESP32 + LVGL

### ✅ Ideal Para
- Controles de automação residencial
- Painéis de dispositivos IoT
- Interfaces touch compactas
- Termostatos inteligentes

### 🛒 Lista de Compras - Mercado Livre

#### Kit Básico (2.8" - Mais Barato)
| Item | Link | Preço |
|------|------|-------|
| ESP32 DevKit V1 | [ESP32 WROOM-32](https://produto.mercadolivre.com.br/MLB-1897543915) | R$ 35 |
| Display ILI9341 2.8" Touch | [Display 2.8" Touch SPI](https://produto.mercadolivre.com.br/MLB-2150088329) | R$ 65 |
| Protoboard + Jumpers | [Kit Protoboard](https://produto.mercadolivre.com.br/MLB-1632585217) | R$ 25 |
| Fonte 5V 2A | [Fonte USB 5V](https://produto.mercadolivre.com.br/MLB-1910456123) | R$ 15 |
| **TOTAL** | | **R$ 140** |

#### Kit Recomendado (3.5" - Melhor Experiência)
| Item | Link | Preço |
|------|------|-------|
| ESP32 WROVER (PSRAM) | [ESP32 WROVER 8MB](https://produto.mercadolivre.com.br/MLB-2686077595) | R$ 65 |
| Display ILI9488 3.5" Touch | [Display 3.5" Touch Paralelo](https://produto.mercadolivre.com.br/MLB-2691706458) | R$ 120 |
| Case Impressão 3D | [Case personalizado](https://produto.mercadolivre.com.br/MLB-3228953621) | R$ 35 |
| Cabo USB-C | [Cabo USB-C 1m](https://produto.mercadolivre.com.br/MLB-2075585329) | R$ 15 |
| **TOTAL** | | **R$ 235** |

### 💻 Código Exemplo - LVGL

```cpp
// platformio.ini
[env:esp32_lvgl]
platform = espressif32
board = esp32dev
framework = arduino
lib_deps = 
    lvgl/lvgl @ ^8.3.0
    bodmer/TFT_eSPI @ ^2.5.0
    
build_flags =
    -D USER_SETUP_LOADED=1
    -D ILI9341_DRIVER=1
    -D TFT_WIDTH=240
    -D TFT_HEIGHT=320
    -D TFT_MISO=19
    -D TFT_MOSI=23
    -D TFT_SCLK=18
    -D TFT_CS=15
    -D TFT_DC=2
    -D TFT_RST=4
    -D TOUCH_CS=21
```

---

## 🖥️ Cenário 2: Display 7" Interface Simples - Nextion

### ✅ Ideal Para
- Painéis de controle industrial
- Interfaces que não precisam de vídeo
- Projetos com desenvolvimento rápido
- Sistemas com ESP32 limitado

### 🛒 Lista de Compras - Mercado Livre

#### Kit Nextion Básico (Sem capa)
| Item | Link | Preço |
|------|------|-------|
| Display Nextion 7" Basic | [Nextion NX8048T070](https://produto.mercadolivre.com.br/MLB-3166091958) | R$ 380 |
| ESP32 DevKit | [ESP32 WROOM-32](https://produto.mercadolivre.com.br/MLB-1897543915) | R$ 35 |
| Conversor Nível Lógico | [Level Shifter 3.3V-5V](https://produto.mercadolivre.com.br/MLB-1646171844) | R$ 12 |
| Fonte 5V 3A | [Fonte Chaveada 5V](https://produto.mercadolivre.com.br/MLB-2148915673) | R$ 28 |
| **TOTAL** | | **R$ 455** |

#### Kit Nextion Enhanced (Recomendado)
| Item | Link | Preço |
|------|------|-------|
| Display Nextion 7" Enhanced | [Nextion NX8048K070](https://produto.mercadolivre.com.br/MLB-4712855325) | R$ 520 |
| ESP32 WROVER | [ESP32 WROVER 8MB](https://produto.mercadolivre.com.br/MLB-2686077595) | R$ 65 |
| Case Acrílico 7" | [Case para Display 7"](https://produto.mercadolivre.com.br/MLB-2154785236) | R$ 45 |
| Cabos Dupont | [Kit Cabos Dupont](https://produto.mercadolivre.com.br/MLB-1632587458) | R$ 15 |
| **TOTAL** | | **R$ 645** |

### 💻 Código Exemplo - Nextion

```cpp
// ESP32 + Nextion
#include <HardwareSerial.h>

HardwareSerial NextionSerial(2); // UART2

void setup() {
  NextionSerial.begin(9600, SERIAL_8N1, 16, 17);
  
  // Enviar comando para Nextion
  NextionSerial.print("page 0");
  NextionSerial.write(0xFF);
  NextionSerial.write(0xFF);
  NextionSerial.write(0xFF);
}

void updateButton(String id, String text, uint16_t color) {
  String cmd = id + ".txt=\"" + text + "\"";
  sendCommand(cmd);
  
  cmd = id + ".bco=" + String(color);
  sendCommand(cmd);
}
```

---

## 🎬 Cenário 3: Display 7"-10" Multimídia - Raspberry Pi

### ✅ Ideal Para
- Dashboards com gráficos animados
- Reprodução de vídeo/streaming
- Interfaces web complexas
- Visualização de câmeras

### 🛒 Lista de Compras - Mercado Livre

#### Kit Pi 4 + Display 7" (Entrada)
| Item | Link | Preço |
|------|------|-------|
| Raspberry Pi 4 2GB | [Pi 4 Model B 2GB](https://produto.mercadolivre.com.br/MLB-2639877451) | R$ 450 |
| Display HDMI 7" Touch | [Monitor Touch 7" HDMI](https://produto.mercadolivre.com.br/MLB-3632632394) | R$ 280 |
| MicroSD 32GB | [SanDisk Ultra 32GB](https://produto.mercadolivre.com.br/MLB-1936587412) | R$ 35 |
| Fonte USB-C 3A | [Fonte Oficial Pi](https://produto.mercadolivre.com.br/MLB-2075648523) | R$ 65 |
| Case com Cooler | [Case Pi 4 Cooler](https://produto.mercadolivre.com.br/MLB-2103654785) | R$ 45 |
| **TOTAL** | | **R$ 875** |

#### Kit Pi 5 + Display 10" (Premium)
| Item | Link | Preço |
|------|------|-------|
| Raspberry Pi 5 4GB | [Pi 5 Model B 4GB](https://produto.mercadolivre.com.br/MLB-3877455124) | R$ 750 |
| Display IPS 10" Touch | [Monitor Touch 10" IPS](https://produto.mercadolivre.com.br/MLB-2981547852) | R$ 580 |
| NVMe SSD 128GB | [SSD M.2 NVMe](https://produto.mercadolivre.com.br/MLB-3124587965) | R$ 120 |
| HAT M.2 para Pi 5 | [Pi 5 M.2 HAT](https://produto.mercadolivre.com.br/MLB-3952147852) | R$ 85 |
| Fonte 27W USB-C PD | [Fonte PD 27W](https://produto.mercadolivre.com.br/MLB-3658974521) | R$ 95 |
| Case Alumínio | [Case Premium Pi 5](https://produto.mercadolivre.com.br/MLB-3985214753) | R$ 120 |
| **TOTAL** | | **R$ 1.750** |

### 💻 Stack de Software - Flutter

```bash
# Instalar Flutter no Pi
cd ~
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:~/flutter/bin"

# Instalar flutter-pi (sem X11)
git clone https://github.com/ardera/flutter-pi
cd flutter-pi
mkdir build && cd build
cmake ..
make -j4
sudo make install

# Criar app
flutter create autocore_dashboard
cd autocore_dashboard

# Build para ARM64
flutter build bundle --target-platform=linux-arm64

# Executar
flutter-pi --release ./build/flutter_assets
```

---

## 💻 Cenário 4: Display 10"-15" Terminal - Mini PC x86

### ✅ Ideal Para
- Kiosks interativos
- Painéis de controle industrial
- Digital signage
- Múltiplos displays

### 🛒 Lista de Compras - Mercado Livre

#### Kit Mini PC + Monitor 10" (Compacto)
| Item | Link | Preço |
|------|------|-------|
| Mini PC N100 | [Beelink Mini S N100](https://produto.mercadolivre.com.br/MLB-3658974125) | R$ 1.100 |
| Monitor Touch 10" | [Monitor Touch 10" HDMI](https://produto.mercadolivre.com.br/MLB-3215478965) | R$ 650 |
| RAM 8GB DDR4 | [RAM SODIMM 8GB](https://produto.mercadolivre.com.br/MLB-2547896321) | R$ 150 |
| SSD 256GB | [SSD SATA 256GB](https://produto.mercadolivre.com.br/MLB-1874521456) | R$ 140 |
| **TOTAL** | | **R$ 2.040** |

#### Kit Mini PC + Monitor 15" (Performance)
| Item | Link | Preço |
|------|------|-------|
| Mini PC i5-8250U | [Mini PC i5 8ª Gen](https://produto.mercadolivre.com.br/MLB-3985214587) | R$ 1.850 |
| Monitor Touch 15.6" | [Monitor Touch 15.6" FHD](https://produto.mercadolivre.com.br/MLB-3652147852) | R$ 1.200 |
| RAM 16GB DDR4 | [Kit RAM 16GB](https://produto.mercadolivre.com.br/MLB-2985647125) | R$ 280 |
| NVMe 512GB | [SSD NVMe 512GB](https://produto.mercadolivre.com.br/MLB-3214785963) | R$ 250 |
| Suporte VESA | [Suporte Monitor VESA](https://produto.mercadolivre.com.br/MLB-1985236547) | R$ 85 |
| **TOTAL** | | **R$ 3.665** |

### 💻 Stack de Software - Electron

```javascript
// package.json
{
  "name": "autocore-kiosk",
  "main": "main.js",
  "scripts": {
    "start": "electron .",
    "build": "electron-builder"
  },
  "dependencies": {
    "electron": "^27.0.0",
    "mqtt": "^5.0.0"
  }
}

// main.js - Modo Kiosk
const { app, BrowserWindow } = require('electron');

function createWindow() {
  const win = new BrowserWindow({
    fullscreen: true,
    kiosk: true,
    autoHideMenuBar: true,
    webPreferences: {
      nodeIntegration: true
    }
  });
  
  win.loadURL('http://localhost:3000');
}

app.whenReady().then(createWindow);
```

---

## 🎯 Comparação Final - Custos e Capacidades

### 📊 Tabela Comparativa Completa

| Solução | Custo Min | Custo Rec | FPS | Resolução Max | Vídeo | Dev Time | Manutenção |
|---------|-----------|-----------|-----|---------------|--------|----------|------------|
| **ESP32 + TFT 2.8"** | R$ 140 | R$ 235 | 30 | 320x240 | ❌ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **ESP32 + LVGL 3.5"** | R$ 185 | R$ 280 | 60 | 480x320 | ❌ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Nextion 7"** | R$ 455 | R$ 645 | 60 | 800x480 | ❌ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Pi 4 + 7"** | R$ 875 | R$ 1.200 | 60 | 1920x1080 | ✅ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Pi 5 + 10"** | R$ 1.430 | R$ 1.750 | 60 | 4K | ✅ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Mini PC + 10"** | R$ 2.040 | R$ 2.500 | 144 | 4K | ✅ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Mini PC + 15"** | R$ 3.050 | R$ 3.665 | 144 | 4K | ✅ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

### 🚀 Recomendações por Projeto

#### Projeto Simples (Automação Residencial)
➡️ **ESP32 + Display 3.5" LVGL**
- Custo: R$ 280
- Desenvolvimento: Rápido com LVGL
- Manutenção: Simples

#### Projeto Médio (Painel Industrial)
➡️ **Nextion 7" Enhanced**
- Custo: R$ 645
- Desenvolvimento: Visual com editor
- Manutenção: Updates via SD card

#### Projeto Avançado (Dashboard Multimídia)
➡️ **Raspberry Pi 4 + Display 7"**
- Custo: R$ 1.200
- Desenvolvimento: Flutter/Web
- Manutenção: SSH/VNC remoto

#### Projeto Enterprise (Kiosk/Terminal)
➡️ **Mini PC N100 + Touch 10"**
- Custo: R$ 2.040
- Desenvolvimento: Web/Electron
- Manutenção: Windows/Linux completo

---

## 📝 Notas Importantes

### ⚠️ Cuidados na Compra

1. **Displays Chineses Genéricos**
   - Verificar se tem driver Touch
   - Confirmar resolução real
   - Pedir vídeo funcionando antes

2. **Raspberry Pi**
   - Comprar apenas vendedores com boa reputação
   - Verificar se é modelo original
   - Pi 4 de 2GB é suficiente para dashboards

3. **ESP32**
   - Preferir WROVER com PSRAM para LVGL
   - DevKit com USB-C é mais confiável
   - Evitar clones muito baratos

4. **Fontes de Alimentação**
   - SEMPRE usar fonte adequada
   - Display 7"+ precisa fonte separada
   - Mini PC: verificar consumo total

### 🛠️ Ferramentas Necessárias

| Ferramenta | Link ML | Preço |
|------------|---------|-------|
| Ferro de Solda 60W | [Estação de Solda](https://produto.mercadolivre.com.br/MLB-1968574123) | R$ 85 |
| Multímetro | [Multímetro Digital](https://produto.mercadolivre.com.br/MLB-1874523698) | R$ 45 |
| Protoboard 830 pontos | [Protoboard Grande](https://produto.mercadolivre.com.br/MLB-1632584789) | R$ 18 |
| Kit Jumpers | [Jumpers M-M, M-F, F-F](https://produto.mercadolivre.com.br/MLB-1658974523) | R$ 25 |
| Case Impressão 3D | [Serviço Impressão](https://produto.mercadolivre.com.br/MLB-2587469852) | R$ 50-150 |

### 💡 Dicas de Economia

1. **Compre em Kits** - Geralmente mais barato
2. **AliExpress** - 50% mais barato, mas 30-60 dias de espera
3. **Grupos Facebook** - Mercado de usados
4. **Promoções** - Black Friday, Prime Day
5. **Importação Direta** - Para quantidade (10+ peças)

---

## 🎓 Recursos de Aprendizado

### Tutoriais YouTube BR
- [ESP32 + Display Touch](https://youtube.com/playlist?list=PLxI8Can9yAHdG5pqzLtpbPR-2ZhI_AXHV)
- [Raspberry Pi Projetos](https://youtube.com/playlist?list=PLHz_AreHm4dlFH1innAcPkK7dXHh3REwz)
- [Nextion Tutorial](https://youtube.com/playlist?list=PLxI8Can9yAHfzKlAuzSi9ryqV9d86BqVd)

### Documentação
- [LVGL Docs](https://docs.lvgl.io)
- [Flutter Pi](https://github.com/ardera/flutter-pi)
- [Nextion Guide](https://nextion.tech/instruction-set/)

### Comunidades
- [ESP32 Brasil (Telegram)](https://t.me/esp32br)
- [Raspberry Pi Brasil](https://www.raspberrypibrasil.com)
- [Makers Brasil (Discord)](https://discord.gg/makersbr)

---

*Última atualização: Janeiro 2025*
*Preços podem variar. Links são apenas referências.*