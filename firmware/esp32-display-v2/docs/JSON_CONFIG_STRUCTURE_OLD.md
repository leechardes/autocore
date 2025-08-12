# 📋 Estrutura JSON de Configuração - AutoTech HMI Display v2

## 📄 Visão Geral

Este documento descreve a estrutura JSON utilizada para configurar dinamicamente as telas e componentes do sistema AutoTech HMI Display. A configuração é totalmente parametrizável, permitindo criar interfaces customizadas sem modificar o código.

## 🏗️ Estrutura Raiz

```json
{
  "version": "2.0.0",
  "metadata": {
    "created_at": "2025-01-05T00:00:00Z",
    "updated_at": "2025-01-05T00:00:00Z",
    "author": "AutoTech Team",
    "description": "Configuração do sistema"
  },
  "system": {
    "name": "AutoTech Control System",
    "language": "pt-BR",
    "theme": "dark",
    "display": {
      "width": 320,
      "height": 240,
      "backlight": 100,
      "layout": {
        "margin": 10,
        "gap": 10,
        "header_height": 40,
        "navbar_height": 40
      }
    }
  },
  "screens": {
    "home": { /* definição da tela */ },
    "lighting": { /* definição da tela */ }
  },
  "devices": { /* configuração de dispositivos */ }
}
```

## 📱 Estrutura de Telas (screens)

### Tela Básica

```json
{
  "home": {
    "type": "menu",
    "title": "Menu Principal",
    "description": "Tela principal do sistema",
    "items": [ /* array de itens */ ]
  }
}
```

### Propriedades da Tela

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `type` | string | ✅ | Tipo da tela: `menu`, `control`, `actions`, `mode_selector` |
| `title` | string | ✅ | Título exibido no header |
| `description` | string | ❌ | Descrição da tela (para documentação) |
| `items` | array | ✅ | Array de componentes da tela |

### Tipos de Tela

1. **menu** - Tela de navegação principal
2. **control** - Tela de controle de dispositivos (relés)
3. **actions** - Tela de ações rápidas e presets
4. **mode_selector** - Tela de seleção de modos (ex: 4x4)

### Sistema de Paginação

O sistema suporta automaticamente múltiplas páginas quando há mais de 6 itens:
- **Máximo por página**: 6 itens (grid 2x3)
- **Navegação**: Automática entre páginas
- **Exemplo**: Tela "Iluminação" com 11 itens = 2 páginas

## 🔲 Estrutura de Itens (items)

### Item de Navegação

```json
{
  "id": "nav_lighting",
  "type": "navigation",
  "label": "Iluminação",
  "icon": "💡",
  "target": "lighting",
  "style": {
    "expand": true,
    "color": "#00aaff"
  }
}
```

### Item de Relay

```json
{
  "id": "light_high",
  "type": "relay",
  "label": "Farol Alto",
  "icon": "light_high",
  "device": "relay_board_1",
  "channel": 1,
  "mode": "toggle"      // toggle, momentary
}
```

### Item de Action

```json
{
  "id": "all_lights",
  "type": "action",
  "label": "Todas Luzes",
  "icon": "star",
  "action_type": "preset",
  "preset": "all_lights"
}
```

### Item de Mode

```json
{
  "id": "mode_4x4",
  "type": "mode",
  "label": "4x4",
  "icon": "4x4",
  "mode": "4x4"
}
```

### Item de Slider

```json
{
  "id": "brightness",
  "type": "slider",
  "label": "Brilho",
  "min": 0,
  "max": 100,
  "value": 50,
  "unit": "%",
  "action": {
    "type": "setting",
    "name": "backlight",
    "immediate": true
  }
}
```

### Item de Label (Informativo)

```json
{
  "id": "info_voltage",
  "type": "label",
  "label": "Voltagem:",
  "value": {
    "source": "sensor",
    "device": "battery_monitor",
    "field": "voltage",
    "format": "{value} V"
  },
  "style": {
    "font_size": 14,
    "color": "#cccccc"
  }
}
```

### Item de Gauge (Medidor)

```json
{
  "id": "temperature",
  "type": "gauge",
  "label": "Temperatura",
  "min": 0,
  "max": 100,
  "value": {
    "source": "sensor",
    "device": "temp_sensor_1",
    "field": "temperature"
  },
  "unit": "°C",
  "zones": [
    { "min": 0, "max": 60, "color": "#00aa44" },
    { "min": 60, "max": 80, "color": "#ffaa00" },
    { "min": 80, "max": 100, "color": "#ff0044" }
  ]
}
```

### Item de Lista

```json
{
  "id": "quick_actions",
  "type": "list",
  "label": "Ações Rápidas",
  "options": [
    {
      "id": "action_1",
      "label": "Ligar Tudo",
      "icon": "⚡",
      "action": {
        "type": "preset",
        "name": "all_on"
      }
    },
    {
      "id": "action_2",
      "label": "Desligar Tudo",
      "icon": "🔌",
      "action": {
        "type": "preset",
        "name": "all_off"
      }
    }
  ]
}
```

## 🎯 Propriedades Comuns dos Itens

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `id` | string | ✅ | Identificador único do item |
| `type` | string | ✅ | Tipo: `navigation`, `relay`, `action`, `mode` |
| `label` | string | ✅ | Texto exibido |
| `icon` | string | ✅ | ID do ícone (não emoji) |

### Propriedades Específicas por Tipo

**Navigation:**
- `target` - ID da tela de destino

**Relay:**
- `device` - ID do dispositivo de relé
- `channel` - Número do canal
- `mode` - `toggle` ou `momentary`

**Action:**
- `action_type` - Tipo da ação (ex: `preset`)
- `preset` - Nome do preset a executar

**Mode:**
- `mode` - Nome do modo (ex: `4x4`)

## 🎨 Objeto Style

```json
{
  "style": {
    "expand": true,           // expande para preencher espaço
    "width": 150,            // largura fixa (sobrescreve responsivo)
    "height": 60,            // altura fixa (sobrescreve responsivo)
    "color": "#ffffff",      // cor do texto
    "bg_color": "#2a2a2a",   // cor de fundo
    "border_color": "#404040", // cor da borda
    "border_width": 2,       // espessura da borda
    "radius": 8,             // raio dos cantos
    "font_size": 16,         // tamanho da fonte
    "align": "center",       // alinhamento do texto
    "padding": 5,            // espaçamento interno
    "on_color": "#00aa44",   // cor quando ativo (switches/buttons)
    "off_color": "#2a2a2a",  // cor quando inativo
    "selected_color": "#00aaff" // cor quando selecionado
  }
}
```

## 🔧 Objeto Action

Define a ação executada quando o item é ativado:

```json
{
  "action": {
    "type": "relay",         // relay, navigation, preset, variable, command
    "device": "relay_board_1", // dispositivo alvo
    "channel": 1,            // canal (para relés)
    "mode": "toggle",        // toggle, on, off, pulse
    "duration": 1000,        // duração em ms (para pulse)
    "target": "screen_id",   // tela de destino (para navigation)
    "command": "custom_cmd", // comando customizado
    "payload": {}           // payload adicional
  }
}
```

### Tipos de Action

1. **relay**: Controla relés
2. **navigation**: Navega para outra tela
3. **preset**: Executa preset/macro
4. **variable**: Altera variável do sistema
5. **command**: Envia comando MQTT customizado
6. **setting**: Altera configuração do sistema

## 📊 Objeto State

Define a fonte do estado do componente:

```json
{
  "state": {
    "source": "relay",       // relay, sensor, variable, calculated
    "device": "relay_board_1",
    "channel": 1,
    "field": "state",       // campo específico (para sensores)
    "update_interval": 1000, // intervalo de atualização (ms)
    "transform": "value ? 'ON' : 'OFF'" // transformação JS opcional
  }
}
```

## 🔄 Sistema de Navegação e Paginação

### Navegação entre Telas

- Items do tipo `navigation` levam para outras telas via `target`
- Botão "Home" sempre disponível para voltar ao menu principal
- Histórico de navegação mantido para facilitar retorno
- Botão "Configurações" adicionado localmente na tela Home

### Paginação Automática

Quando uma tela tem mais de 6 itens:
- Sistema divide automaticamente em páginas
- Navegação entre páginas com botões Prev/Next
- Indicador de página atual
- Exemplo: 11 itens = 2 páginas (6 + 5 itens)

### Item de Configuração Local

O dispositivo adiciona automaticamente um botão de configuração na tela Home:

```json
{
  "id": "local_config",
  "type": "local_navigation",
  "icon": "settings",
  "label": "Configurações",
  "target": "_config",
  "local": true  // Indica que é item local, não vem do MQTT
}
```

Este item permite configurar:
- **Layout**: Itens por linha (1-4), número de linhas (1-3)
- **Visual**: Tema, tamanho de fonte, brilho
- **Comportamento**: Timeouts, sons, animações
- **Sistema**: Info do dispositivo, reset, versão

## 🌐 Internacionalização

Suporte a múltiplos idiomas:

```json
{
  "label": {
    "pt-BR": "Iluminação",
    "en-US": "Lighting",
    "es-ES": "Iluminación"
  }
}
```

## 📱 Exemplo Completo de Tela

```json
{
  "screen_2c77b42f": {
    "type": "control",
    "title": "Iluminação",
    "description": "Controle completo do sistema de iluminação do veículo",
    "items": [
      {
        "id": "light_high",
        "type": "relay",
        "icon": "light_high",
        "label": "Luz Alta",
        "device": "relay_board_1",
        "channel": 1,
        "mode": "toggle"
      },
      {
        "id": "light_low",
        "type": "relay",
        "icon": "light_low",
        "label": "Luz Baixa",
        "device": "relay_board_1",
        "channel": 2,
        "mode": "toggle"
      },
      {
        "id": "brake_light",
        "type": "relay",
        "icon": "brake",
        "label": "Luz de Freio",
        "device": "relay_board_1",
        "channel": 5,
        "mode": "momentary"
      }
      // ... mais 8 itens (total 11 = 2 páginas)
    ]
  }
}
```

## 🔐 Validação

### Regras de Validação

1. **IDs únicos**: Todos os IDs devem ser únicos no escopo
2. **Tipos válidos**: Apenas tipos suportados pelo sistema
3. **Referências válidas**: Targets e devices devem existir
4. **Limites de itens**: Máximo 6 itens por tela (sem scroll)
5. **Campos obrigatórios**: Todos os campos marcados como obrigatórios

### Schema JSON

O sistema valida automaticamente usando JSON Schema. Erros são reportados com detalhes específicos.

## 📝 Notas Importantes

1. **Performance**: Mantenha o JSON otimizado, evitando dados desnecessários
2. **Compatibilidade**: Use a versão correta para garantir compatibilidade
3. **Backup**: Sempre faça backup antes de modificar configurações
4. **Hot Reload**: Mudanças podem ser aplicadas sem reiniciar o sistema
5. **Limites**: Respeite os limites de memória do ESP32

---

*Documento atualizado em: Janeiro 2025*
*Versão: 2.0.0*