# Endpoints - Telas e Interface

Gerenciamento de telas, componentes UI e temas para dispositivos de display.

## 📋 Visão Geral

Os endpoints de telas permitem:
- Configurar interfaces para ESP32 Display
- Gerenciar componentes e layouts
- Personalizar temas e aparência
- Definir comportamento por tipo de dispositivo

## 🖥️ Endpoints de Telas

### `GET /api/screens`

Lista todas as telas configuradas no sistema.

**Resposta:**
```json
[
  {
    "id": 1,
    "name": "main_dashboard",
    "title": "Dashboard Principal",
    "icon": "home",
    "screen_type": "dashboard",
    "parent_id": null,
    "position": 1,
    "columns_mobile": 2,
    "columns_display_small": 2,
    "columns_display_large": 3,
    "columns_web": 4,
    "is_visible": true,
    "show_on_mobile": true,
    "show_on_display_small": true,
    "show_on_display_large": true,
    "show_on_web": true,
    "show_on_controls": false,
    "required_permission": null,
    "created_at": "2025-01-20T08:00:00Z"
  }
]
```

---

### `GET /api/screens/{screen_id}`

Busca uma tela específica com opção de incluir itens.

**Parâmetros de Path:**
- `screen_id` (integer): ID da tela

**Parâmetros de Query:**
- `include_items` (boolean, opcional): Se deve incluir os itens da tela

**Resposta:**
```json
{
  "id": 1,
  "name": "main_dashboard",
  "title": "Dashboard Principal",
  "icon": "home",
  "screen_type": "dashboard",
  "position": 1,
  "is_visible": true,
  "items_count": 6,
  "items": [
    {
      "id": 1,
      "item_type": "button",
      "name": "luz_sala",
      "label": "Luz da Sala",
      "icon": "lightbulb",
      "position": 1,
      "action_type": "relay_toggle",
      "action_target": "relay_1"
    }
  ]
}
```

---

### `POST /api/screens`

Cria uma nova tela no sistema.

**Body (JSON):**
```json
{
  "name": "garage_control",
  "title": "Controle da Garagem",
  "icon": "garage",
  "screen_type": "control",
  "position": 3,
  "columns_display_small": 2,
  "columns_display_large": 3,
  "show_on_display_small": true,
  "show_on_display_large": true,
  "is_visible": true
}
```

**Resposta:**
```json
{
  "id": 4,
  "name": "garage_control",
  "title": "Controle da Garagem",
  "message": "Tela criada com sucesso"
}
```

---

### `PATCH /api/screens/{screen_id}`

Atualiza uma tela existente.

**Body (JSON) - Parcial:**
```json
{
  "title": "Novo Título",
  "icon": "new-icon",
  "position": 2,
  "is_visible": false
}
```

---

### `DELETE /api/screens/{screen_id}`

Remove uma tela e todos os seus itens (CASCADE).

## 🔘 Endpoints de Itens de Tela

### `GET /api/screens/{screen_id}/items`

Lista todos os itens de uma tela específica.

**Resposta:**
```json
[
  {
    "id": 1,
    "screen_id": 1,
    "item_type": "button",
    "name": "luz_principal",
    "label": "Luz Principal",
    "icon": "lightbulb",
    "position": 1,
    "size_mobile": "normal",
    "size_display_small": "normal",
    "size_display_large": "large",
    "size_web": "normal",
    "action_type": "relay_toggle",
    "action_target": "channel_1",
    "relay_board_id": 1,
    "relay_channel_id": 1,
    "is_active": true
  }
]
```

---

### `POST /api/screens/{screen_id}/items`

Adiciona um novo item a uma tela.

**Body (JSON):**
```json
{
  "item_type": "gauge",
  "name": "temperatura_motor",
  "label": "Temperatura do Motor",
  "icon": "thermometer",
  "position": 2,
  "size_display_small": "large",
  "data_source": "telemetry",
  "data_path": "engine_temp",
  "data_unit": "°C",
  "data_format": "gauge",
  "is_active": true
}
```

**Resposta:**
```json
{
  "id": 8,
  "screen_id": 1,
  "item_type": "gauge",
  "name": "temperatura_motor",
  "message": "Item criado com sucesso"
}
```

---

### `PATCH /api/screens/{screen_id}/items/{item_id}`

Atualiza um item específico.

**Body (JSON) - Parcial:**
```json
{
  "label": "Novo Label",
  "position": 3,
  "icon": "new-icon",
  "size_display_small": "large"
}
```

---

### `DELETE /api/screens/{screen_id}/items/{item_id}`

Remove um item da tela.

## 🎨 Endpoints de Temas

### `GET /api/themes`

Lista todos os temas disponíveis.

**Resposta:**
```json
[
  {
    "id": 1,
    "name": "default_dark",
    "description": "Tema escuro padrão",
    "primary_color": "#1976D2",
    "secondary_color": "#424242",
    "background_color": "#121212",
    "is_default": true
  }
]
```

---

### `GET /api/themes/default`

Retorna o tema padrão do sistema.

**Resposta:**
```json
{
  "id": 1,
  "name": "default_dark",
  "description": "Tema escuro padrão",
  "primary_color": "#1976D2",
  "secondary_color": "#424242", 
  "background_color": "#121212",
  "surface_color": "#1E1E1E",
  "text_primary": "#FFFFFF",
  "text_secondary": "#AAAAAA",
  "error_color": "#F44336",
  "warning_color": "#FF9800",
  "success_color": "#4CAF50",
  "info_color": "#2196F3",
  "is_default": true
}
```

## 🎯 Tipos de Itens de Tela

### Button
```json
{
  "item_type": "button",
  "action_type": "relay_toggle|relay_on|relay_off",
  "action_target": "channel_id",
  "relay_board_id": 1,
  "relay_channel_id": 2
}
```

### Gauge (Medidor)
```json
{
  "item_type": "gauge",
  "data_source": "telemetry",
  "data_path": "rpm",
  "data_unit": "RPM",
  "min_value": 0,
  "max_value": 8000,
  "color_ranges": [
    {"min": 0, "max": 3000, "color": "#4CAF50"},
    {"min": 3000, "max": 6000, "color": "#FF9800"},
    {"min": 6000, "max": 8000, "color": "#F44336"}
  ]
}
```

### Display (Texto/Valor)
```json
{
  "item_type": "display",
  "display_format": "text|number|percentage",
  "data_source": "telemetry",
  "data_path": "speed",
  "data_unit": "km/h",
  "data_format": "##0.0"
}
```

### Navigation
```json
{
  "item_type": "navigation",
  "action_type": "navigate",
  "action_target": "screen_id",
  "action_payload": "{\"screen_id\": 2}"
}
```

## 📏 Tamanhos de Item

- `small` - Ocupa 1/4 da tela
- `normal` - Ocupa 1/2 da tela (padrão)
- `large` - Ocupa tela inteira
- `wide` - Ocupa largura total, altura normal

## 📱 Suporte Multi-Dispositivo

### Campos de Colunas
- `columns_mobile` - Celulares (1-2 colunas)
- `columns_display_small` - ESP32 320x240 (1-2 colunas)
- `columns_display_large` - Displays 480x320+ (2-4 colunas)
- `columns_web` - Interface web (3-6 colunas)

### Campos de Visibilidade
- `show_on_mobile` - Mostrar em apps mobile
- `show_on_display_small` - ESP32 pequenos
- `show_on_display_large` - ESP32 grandes
- `show_on_web` - Interface web
- `show_on_controls` - Painel de controles

## 🔍 Layouts Disponíveis

Use `GET /api/layouts` para obter layouts pré-definidos:

```json
[
  {
    "id": "grid_2x2",
    "name": "Grid 2x2",
    "max_items": 4,
    "columns": 2,
    "rows": 2,
    "supported_devices": ["esp32_display"]
  }
]
```