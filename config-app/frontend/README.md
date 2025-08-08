# 🎨 AutoCore Config App - Frontend

<div align="center">

![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)
![Alpine.js](https://img.shields.io/badge/Alpine.js-8BC34A?style=for-the-badge&logo=alpine.js&logoColor=white)

**Interface Web Leve e Moderna para Configuração do Sistema AutoCore**

[Visão Geral](#-visão-geral) • [Componentes](#-sistema-de-componentes) • [Desenvolvimento](#-desenvolvimento) • [Temas](#-sistema-de-temas)

</div>

---

## 📋 Visão Geral

Interface web de configuração para o sistema AutoCore, otimizada para rodar no **Raspberry Pi Zero 2W**. Esta aplicação permite configurar todos os componentes do sistema veicular (ESP32s, relés, displays, integração CAN) através de uma interface moderna e responsiva.

### ✨ Características Principais

- 🚗 **Configuração Veicular** - Gestão completa de componentes automotivos
- 📱 **100% Responsiva** - Funciona em desktop, tablet e mobile
- ⚡ **Ultra Leve** - Sem build process, ideal para Raspberry Pi Zero
- 🎨 **Design Moderno** - Interface limpa inspirada no shadcn/ui
- 🔧 **Componentizada** - Arquitetura modular e reutilizável
- 🌙 **Temas Dinâmicos** - Suporte para dark/light mode
- 🔄 **Tempo Real** - Comunicação MQTT para atualizações instantâneas

## 🛠️ Stack Tecnológica

### Core
- **HTML5** - Estrutura semântica, sem dependências
- **Tailwind CSS** - Estilização via CDN, sem build
- **Alpine.js** - Reatividade leve (13KB gzipped)
- **Lucide Icons** - Ícones consistentes

### Integrações
- **MQTT WebSocket** - Comunicação tempo real com gateway
- **FastAPI Backend** - APIs REST para configuração
- **Chart.js** - Gráficos de telemetria (carregamento lazy)
- **Local Storage** - Cache de configurações offline

### CDNs
```html
<!-- Essenciais -->
<script src="https://cdn.tailwindcss.com"></script>
<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
<script src="https://unpkg.com/lucide@latest/dist/umd/lucide.js"></script>

<!-- Opcionais -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://unpkg.com/mqtt@4.3.7/dist/mqtt.min.js"></script>
```

## 📁 Estrutura de Arquivos

```
frontend/
├── 📁 assets/                    # Assets estáticos
│   ├── css/
│   │   ├── custom.css           # Estilos customizados
│   │   └── themes.css           # Variáveis de temas
│   ├── js/
│   │   ├── app.js              # Core da aplicação
│   │   ├── mqtt-client.js      # Cliente MQTT WebSocket
│   │   └── api.js              # Cliente REST API
│   └── images/
│       └── autocore-logo.svg   # Logo do sistema
│
├── 📁 components/                # Componentes Alpine.js
│   ├── ui/                     # Componentes base
│   │   ├── button.js           # Botões
│   │   ├── card.js             # Cards
│   │   ├── modal.js            # Modais
│   │   └── toast.js            # Notificações
│   ├── layout/                 # Layout
│   │   ├── navbar.js           # Navegação
│   │   ├── sidebar.js          # Menu lateral
│   │   └── theme-switcher.js   # Alternador de tema
│   └── modules/                # Específicos do AutoCore
│       ├── device-card.js      # Card de dispositivo ESP32
│       ├── relay-control.js    # Controle de relés
│       ├── can-monitor.js      # Monitor dados CAN
│       └── config-editor.js    # Editor de configurações
│
├── 📁 pages/                     # Páginas da aplicação
│   ├── index.html              # Dashboard principal
│   ├── devices.html            # Gestão de ESP32s
│   ├── relays.html             # Configuração de relés
│   ├── can.html                # Integração CAN FuelTech
│   ├── multimedia.html         # Sistema multimídia
│   └── settings.html           # Configurações gerais
│
├── 📁 templates/                 # Templates reutilizáveis
│   └── base.html               # Template base HTML
│
└── 📁 docs/                      # Documentação
    ├── COMPONENTS.md           # Guia de componentes
    └── DEPLOYMENT.md           # Deploy no Raspberry Pi
```

## 🎨 Sistema de Componentes

### Arquitetura

Componentes reutilizáveis usando Alpine.js, sem necessidade de build. Cada componente é um arquivo JavaScript que define comportamentos específicos:

```javascript
// Exemplo: components/modules/relay-control.js
Alpine.data('relayControl', () => ({
    relayId: null,
    state: false,
    loading: false,
    
    init() {
        // Escutar estado do relé via MQTT
        mqtt.subscribe(`autocore/relays/${this.relayId}/state`, (message) => {
            this.state = message.payload === 'ON'
        })
    },
    
    async toggle() {
        this.loading = true
        try {
            await mqtt.publish(`autocore/relays/${this.relayId}/command`, 
                               this.state ? 'OFF' : 'ON')
        } catch (error) {
            this.$dispatch('toast', { 
                type: 'error', 
                message: 'Erro ao controlar relé' 
            })
        }
        this.loading = false
    }
}))
```

### Componentes Específicos do AutoCore

- **device-card** - Mostra status de ESP32s (online/offline, uptime, IP)
- **relay-control** - Controle individual de relés com feedback
- **can-monitor** - Visualização dados CAN da FuelTech (RPM, temp, etc)
- **config-editor** - Editor JSON para configurações avançadas

## 🌙 Sistema de Temas

Sistema simples de temas com CSS custom properties para dark/light mode:

```css
/* assets/css/themes.css */
:root {
    --bg-primary: #ffffff;
    --bg-secondary: #f8fafc;
    --text-primary: #1e293b;
    --border: #e2e8f0;
    --accent: #3b82f6;
}

[data-theme="dark"] {
    --bg-primary: #0f172a;
    --bg-secondary: #1e293b;
    --text-primary: #f1f5f9;
    --border: #334155;
    --accent: #60a5fa;
}
```

### Alternador de Tema

```javascript
Alpine.data('themeSwitcher', () => ({
    theme: localStorage.getItem('theme') || 'light',
    
    toggleTheme() {
        this.theme = this.theme === 'light' ? 'dark' : 'light'
        document.documentElement.setAttribute('data-theme', this.theme)
        localStorage.setItem('theme', this.theme)
    }
}))
```

## 📱 Responsividade

Design mobile-first otimizado para uso em veículos:

```html
<!-- Layout adaptável -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
    <!-- Dispositivos ESP32 -->
</div>

<!-- Navegação touch-friendly -->
<nav class="fixed bottom-0 md:static md:top-0">
    <!-- Botões grandes para uso no veículo -->
</nav>
```

**Breakpoints:** sm(640px), md(768px), lg(1024px), xl(1280px)

## 🚀 Performance

Otimizado para **Raspberry Pi Zero 2W**:

- ⚡ **< 50KB total** de JavaScript
- 🎯 **< 200ms** tempo de carregamento
- 💾 **< 20MB** uso de memória
- 📦 **Zero build process** - servir arquivos diretos
- 🔄 **Cache agressivo** de assets estáticos

## 🔧 Desenvolvimento

### Setup Local

```bash
# Navegar para o frontend
cd /Users/leechardes/Projetos/AutoCore/config-app/frontend

# Servir arquivos estáticos
python -m http.server 8080

# Abrir no navegador
open http://localhost:8080/pages/index.html
```

### Template Base

```html
<!DOCTYPE html>
<html lang="pt-BR" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AutoCore Config</title>
    
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="../assets/css/themes.css">
</head>
<body style="background: var(--bg-primary); color: var(--text-primary)">
    <div x-data="autoCorePage" class="min-h-screen">
        <!-- Conteúdo da aplicação -->
    </div>
    
    <!-- Scripts -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
    <script src="../assets/js/mqtt-client.js"></script>
    <script src="../assets/js/api.js"></script>
    <script src="../components/layout/theme-switcher.js"></script>
    <script src="../assets/js/app.js"></script>
</body>
</html>
```

### Adicionando Novo Componente

1. Criar arquivo em `components/modules/nome-componente.js`
2. Implementar usando padrão Alpine.js
3. Incluir script na página que usa
4. Testar funcionamento no Raspberry Pi

## 🚗 Funcionalidades Principais

### Dashboard
- Status tempo real de todos os ESP32s
- Monitor de relés ativos/inativos
- Dados CAN da ECU FuelTech (RPM, temperatura, pressões)
- Gráficos de telemetria

### Configuração de Dispositivos
- Descoberta automática de ESP32s na rede
- Configuração de parâmetros individuais
- Atualização OTA de firmware
- Logs de diagnóstico

### Controle de Relés
- Interface visual para acionamento manual
- Configuração de temporizadores
- Grupos de relés (ex: luzes, som, refrigeração)
- Histórico de acionamentos

### Integração CAN
- Monitor em tempo real da ECU FuelTech FT450
- Configuração de parâmetros de partida
- Alertas de temperatura e pressão
- Export de dados para análise

## 📱 Deploy no Raspberry Pi

### Configuração de Produção

```bash
# No Raspberry Pi Zero 2W
sudo apt update && sudo apt install nginx python3

# Configurar nginx para servir arquivos estáticos
sudo cp nginx.conf /etc/nginx/sites-available/autocore
sudo ln -s /etc/nginx/sites-available/autocore /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Interface acessível em http://raspberrypi.local
```

### Estrutura Final
```
/var/www/autocore/
├── frontend/     # Interface web (este projeto)
├── backend/      # API FastAPI
└── gateway/      # Hub MQTT
```

---

<div align="center">

**🚗 Interface de configuração do AutoCore - Sistema modular de controle veicular**

Desenvolvido para rodar de forma eficiente no Raspberry Pi Zero 2W

[Backend FastAPI](../backend/README.md) • [Gateway MQTT](../../gateway/README.md) • [App Flutter](../../app-flutter/README.md)

</div>2