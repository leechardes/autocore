# 📺 Endpoints Necessários para ESP32-Display

## 📋 Resumo

Este documento descreve os endpoints necessários para o ESP32-display funcionar corretamente. Baseado na análise do firmware `firmware/platformio/esp32-display` e do backend `config-app/backend`.

## ✅ Endpoints EXISTENTES no Backend

### 1. **GET /api/screens** ✅
- **Status**: IMPLEMENTADO
- **Descrição**: Lista todas as telas disponíveis
- **Retorno**: Array de objetos Screen com id, name, title, type, position, etc.
- **Uso no Display**: Carrega lista de telas para navegação

### 2. **GET /api/screens/{screen_id}/items** ✅
- **Status**: IMPLEMENTADO
- **Descrição**: Retorna todos os itens de uma tela específica
- **Retorno**: Array de ScreenItem com configurações de cada componente
- **Uso no Display**: Renderiza os componentes na tela

### 3. **GET /api/devices** ✅
- **Status**: IMPLEMENTADO
- **Descrição**: Lista todos os dispositivos do sistema
- **Retorno**: Array de Device com id, uuid, name, type, status
- **Uso no Display**: Popula DeviceRegistry para referências

### 4. **GET /api/relays/boards** ✅
- **Status**: IMPLEMENTADO
- **Descrição**: Lista todas as placas de relé
- **Retorno**: Array de RelayBoard com canais e configurações
- **Uso no Display**: Popula registro de placas de relé

### 5. **GET /api/icons** ✅ **IMPLEMENTÁVEL AGORA**
- **Status**: TABELA CRIADA - Pronto para implementar
- **Descrição**: Retorna mapeamento de ícones por plataforma
- **Parâmetro**: `?platform=esp32` (esp32, web, mobile)
- **Retorno**: Mapeamento otimizado para a plataforma
- **Uso no Display**: Mapeia nomes de ícones para símbolos LVGL

## ❌ Endpoints FALTANTES (Precisam ser criados)

### ✅ **UPDATE**: Tabela `icons` foi criada!
A tabela `icons` foi implementada no database com 26 ícones base, tornando o endpoint `/api/icons` implementável agora.

### 1. **GET /api/config/full** ❌
**Prioridade**: ALTA 🔴

**Descrição**: Endpoint unificado que retorna TODA a configuração necessária para o display em uma única chamada.

**Estrutura baseada nos campos REAIS do database**:
```json
{
  "version": "2.0.0",
  "protocol_version": "2.2.0",
  "system": {
    "name": "AutoCore System",
    "language": "pt-BR"
  },
  "screens": [
    {
      "id": 1,                          // INTEGER
      "name": "home",                   // VARCHAR(100)
      "title": "Menu Principal",        // VARCHAR(100)
      "icon": "home",                   // VARCHAR(50) nullable
      "screen_type": "menu",            // VARCHAR(50) nullable
      "parent_id": null,                // INTEGER nullable
      "position": 0,                    // INTEGER
      "columns_display_small": 2,       // INTEGER nullable
      "columns_display_large": 3,       // INTEGER nullable
      "is_visible": true,               // BOOLEAN nullable
      "show_on_display_small": true,    // BOOLEAN nullable
      "show_on_display_large": true,    // BOOLEAN nullable
      "items": [                        // De screen_items
        {
          "id": 1,
          "item_type": "relay",          // VARCHAR(50)
          "name": "light_1",             // VARCHAR(100)
          "label": "Luz Principal",      // VARCHAR(100)
          "icon": "light",               // VARCHAR(50) nullable
          "position": 0,                 // INTEGER
          "action_type": "toggle",       // VARCHAR(50) nullable
          "action_target": "relay_1",    // VARCHAR(200) nullable
          "relay_board_id": 1,           // INTEGER nullable
          "relay_channel_id": 1          // INTEGER nullable
        }
      ]
    }
  ],
  "devices": [
    {
      "id": 1,                           // INTEGER
      "uuid": "esp32-001",               // VARCHAR(36)
      "name": "ESP32 Principal",        // VARCHAR(100)
      "type": "relay_board",             // VARCHAR(50)
      "ip_address": "192.168.1.100",    // VARCHAR(15) nullable
      "mac_address": "AA:BB:CC:DD:EE",  // VARCHAR(17) nullable
      "status": "online",                // VARCHAR(20) nullable
      "is_active": true                  // BOOLEAN nullable
    }
  ],
  "relay_boards": [
    {
      "id": 1,                           // INTEGER
      "device_id": 1,                    // INTEGER
      "total_channels": 16,              // INTEGER
      "board_model": "16CH",             // VARCHAR(50) nullable
      "is_active": true                  // BOOLEAN nullable
    }
  ],
  "theme": {
    "id": 1,                             // INTEGER
    "name": "dark",                      // VARCHAR(100)
    "primary_color": "#2196F3",          // VARCHAR(7)
    "secondary_color": "#FFC107",        // VARCHAR(7)
    "background_color": "#121212",       // VARCHAR(7)
    "surface_color": "#1E1E1E",          // VARCHAR(7)
    "text_primary": "#FFFFFF",           // VARCHAR(7)
    "text_secondary": "#B0B0B0",         // VARCHAR(7)
    "error_color": "#F44336",            // VARCHAR(7)
    "warning_color": "#FF9800",          // VARCHAR(7)
    "success_color": "#4CAF50",          // VARCHAR(7)
    "info_color": "#2196F3"              // VARCHAR(7)
  }
}
```

**Implementação sugerida usando campos REAIS**:
```python
@app.get("/api/config/full/{device_uuid}", tags=["Config"])
async def get_full_config(device_uuid: str):
    """
    Retorna configuração completa para um dispositivo ESP32
    Usa apenas campos existentes no database
    """
    try:
        # Buscar dispositivo usando campos reais
        device = devices.get_by_uuid(device_uuid)
        if not device:
            raise HTTPException(404, "Device not found")
        
        # Base config com campos existentes
        config_data = {
            "version": "2.0.0",
            "protocol_version": "2.2.0",
            "device": {
                "id": device.id,
                "uuid": device.uuid,
                "type": device.type,
                "name": device.name,
                "status": device.status,
                "ip_address": device.ip_address,
                "mac_address": device.mac_address
            },
            "system": {
                "name": "AutoCore System",
                "language": "pt-BR"
            }
        }
        
        # Se for display, adicionar configurações
        if device.type in ["hmi_display", "esp32-display"]:
            # Screens com campos reais
            screens_data = []
            all_screens = config.get_screens()
            
            for screen in all_screens:
                if screen.show_on_display_small or screen.show_on_display_large:
                    screen_dict = {
                        "id": screen.id,
                        "name": screen.name,
                        "title": screen.title,
                        "icon": screen.icon,
                        "screen_type": screen.screen_type,
                        "position": screen.position,
                        "columns_display_small": screen.columns_display_small or 2,
                        "columns_display_large": screen.columns_display_large or 3,
                        "is_visible": screen.is_visible,
                        "items": []
                    }
                    
                    # Adicionar screen_items
                    items = config.get_screen_items(screen.id)
                    for item in items:
                        screen_dict["items"].append({
                            "id": item.id,
                            "item_type": item.item_type,
                            "name": item.name,
                            "label": item.label,
                            "icon": item.icon,
                            "position": item.position,
                            "action_type": item.action_type,
                            "action_target": item.action_target,
                            "relay_board_id": item.relay_board_id,
                            "relay_channel_id": item.relay_channel_id
                        })
                    
                    screens_data.append(screen_dict)
            
            config_data["screens"] = screens_data
            
            # Devices
            all_devices = devices.get_all()
            config_data["devices"] = [
                {
                    "id": d.id,
                    "uuid": d.uuid,
                    "name": d.name,
                    "type": d.type,
                    "status": d.status,
                    "is_active": d.is_active
                }
                for d in all_devices if d.is_active
            ]
            
            # Relay boards com campos reais
            boards = relays.get_all_boards()
            config_data["relay_boards"] = [
                {
                    "id": b.id,
                    "device_id": b.device_id,
                    "total_channels": b.total_channels,
                    "board_model": b.board_model,
                    "is_active": b.is_active
                }
                for b in boards if b.is_active
            ]
            
            # Theme padrão
            default_theme = config.get_default_theme()
            if default_theme:
                config_data["theme"] = {
                    "id": default_theme.id,
                    "name": default_theme.name,
                    "primary_color": default_theme.primary_color,
                    "secondary_color": default_theme.secondary_color,
                    "background_color": default_theme.background_color,
                    "surface_color": default_theme.surface_color,
                    "text_primary": default_theme.text_primary,
                    "text_secondary": default_theme.text_secondary,
                    "error_color": default_theme.error_color,
                    "warning_color": default_theme.warning_color,
                    "success_color": default_theme.success_color,
                    "info_color": default_theme.info_color
                }
        
        return config_data
        
    except Exception as e:
        raise HTTPException(500, str(e))
```

### 2. **GET /api/screens/{screen_id}** ❌
**Prioridade**: MÉDIA 🟡

**Descrição**: Retorna detalhes completos de uma tela específica (não apenas os itens).

**Estrutura esperada**:
```json
{
  "id": 1,
  "name": "home",
  "title": "Menu Principal",
  "type": "menu",
  "layout": "grid_2x3",
  "parent_id": null,
  "position": 0,
  "background": "#1E3A5F",
  "columns_display_small": 2,
  "columns_display_large": 3,
  "is_visible": true,
  "items_count": 6,
  "items": [...]  // Opcional, pode incluir os itens
}
```

**Implementação sugerida**:
```python
@app.get("/api/screens/{screen_id}", tags=["UI"])
async def get_screen_by_id(screen_id: int, include_items: bool = False):
    """Retorna detalhes de uma tela específica"""
    try:
        screen = config.get_screen_by_id(screen_id)
        if not screen:
            raise HTTPException(404, "Screen not found")
        
        result = {
            "id": screen.id,
            "name": screen.name,
            "title": screen.title,
            "type": screen.screen_type,
            "layout": f"grid_{screen.columns_display_small}x{screen.columns_display_large}",
            "parent_id": screen.parent_id,
            "position": screen.position,
            # ... outros campos
        }
        
        if include_items:
            result["items"] = config.get_screen_items(screen_id)
        
        return result
        
    except Exception as e:
        raise HTTPException(500, str(e))
```

### 3. **GET /api/layouts** ❌
**Prioridade**: BAIXA 🟢

**Descrição**: Lista layouts disponíveis para renderização de telas.

**Nota**: Não existe tabela de layouts no database. Este endpoint retornaria valores hardcoded baseados nos campos `columns_display_small` e `columns_display_large` da tabela `screens`.

**Estrutura sugerida (hardcoded)**:
```json
[
  {
    "id": "grid_2x2",
    "name": "Grid 2x2",
    "description": "4 itens em grade",
    "max_items": 4,
    "columns": 2,
    "rows": 2,
    "for_display": "small"
  },
  {
    "id": "grid_2x3",
    "name": "Grid 2x3", 
    "description": "6 itens em grade",
    "max_items": 6,
    "columns": 2,
    "rows": 3,
    "for_display": "small"
  },
  {
    "id": "grid_3x3",
    "name": "Grid 3x3",
    "description": "9 itens em grade",
    "max_items": 9,
    "columns": 3,
    "rows": 3,
    "for_display": "large"
  },
  {
    "id": "list",
    "name": "Lista",
    "description": "Lista vertical",
    "max_items": 20,
    "columns": 1,
    "rows": null,
    "for_display": "both"
  }
]
```

**Implementação sugerida**:
```python
@app.get("/api/layouts", tags=["UI"])
async def get_layouts():
    """Retorna layouts disponíveis para displays"""
    return [
        {
            "id": "grid_2x2",
            "name": "Grid 2x2",
            "description": "4 itens em grade",
            "max_items": 4,
            "columns": 2,
            "rows": 2,
            "supported_devices": ["hmi_display_small", "hmi_display_large"]
        },
        {
            "id": "grid_2x3",
            "name": "Grid 2x3",
            "description": "6 itens em grade", 
            "max_items": 6,
            "columns": 2,
            "rows": 3,
            "supported_devices": ["hmi_display_large"]
        },
        {
            "id": "grid_3x2",
            "name": "Grid 3x2",
            "description": "6 itens em grade horizontal",
            "max_items": 6,
            "columns": 3,
            "rows": 2,
            "supported_devices": ["hmi_display_large"]
        },
        {
            "id": "list",
            "name": "Lista Vertical",
            "description": "Lista com scroll",
            "max_items": 20,
            "columns": 1,
            "rows": null,
            "supported_devices": ["hmi_display_small", "hmi_display_large"]
        },
        {
            "id": "form",
            "name": "Formulário",
            "description": "Layout para configurações",
            "max_items": 15,
            "columns": 1,
            "rows": null,
            "supported_devices": ["hmi_display_large"]
        }
    ]
```

### 4. **GET /api/icons** ✅ (Tabela criada!)
**Prioridade**: BAIXA 🟢 → **IMPLEMENTÁVEL AGORA**

**Descrição**: Retorna mapeamento de ícones disponíveis para uso no display.

**Status**: ✅ **Tabela `icons` foi criada no database com 26 ícones base!**

**Estrutura baseada nos campos REAIS da tabela `icons`**:
```json
{
  "version": "1.0.0",
  "platform": "esp32",
  "icons": {
    "light": {
      "id": 1,
      "display_name": "Luz",
      "category": "lighting",
      "lvgl_symbol": "LV_SYMBOL_LIGHT",
      "unicode_char": "\uf0eb",
      "emoji": "💡",
      "fallback": null
    },
    "light_high": {
      "id": 2,
      "display_name": "Farol Alto",
      "category": "lighting",
      "lvgl_symbol": "LV_SYMBOL_LIGHT",
      "unicode_char": "\uf0e7",
      "emoji": "🔦",
      "fallback": "light"
    },
    "power": {
      "id": 5,
      "display_name": "Liga/Desliga",
      "category": "control",
      "lvgl_symbol": "LV_SYMBOL_POWER",
      "unicode_char": "\uf011",
      "emoji": "⚡",
      "fallback": null
    },
    "settings": {
      "id": 8,
      "display_name": "Configurações",
      "category": "navigation",
      "lvgl_symbol": "LV_SYMBOL_SETTINGS",
      "unicode_char": "\uf013",
      "emoji": "⚙️",
      "fallback": null
    },
    "home": {
      "id": 7,
      "display_name": "Início",
      "category": "navigation",
      "lvgl_symbol": "LV_SYMBOL_HOME",
      "unicode_char": "\uf015",
      "emoji": "🏠",
      "fallback": null
    }
  }
}
```

**Implementação usando a tabela REAL `icons`**:
```python
@app.get("/api/icons", tags=["UI"])
async def get_icons(platform: str = "esp32"):
    """
    Retorna mapeamento de ícones para displays
    Usa a tabela icons do database
    """
    try:
        # Import do repository icons
        from shared.repositories import icons
        
        # Buscar mapeamento otimizado para a plataforma
        if platform == "esp32":
            # Para ESP32, retornar mapeamento LVGL
            all_icons = icons.get_all(active_only=True)
            icons_map = {}
            
            for icon in all_icons:
                icons_map[icon.name] = {
                    "id": icon.id,
                    "display_name": icon.display_name,
                    "category": icon.category,
                    "lvgl_symbol": icon.lvgl_symbol,
                    "unicode_char": icon.unicode_char,
                    "emoji": icon.emoji,
                    "fallback": icon.fallback_icon_id
                }
            
            return {
                "version": "1.0.0",
                "platform": platform,
                "icons": icons_map
            }
            
        elif platform == "web":
            # Para web, retornar Lucide/Material/FontAwesome
            all_icons = icons.get_all(active_only=True)
            icons_map = {}
            
            for icon in all_icons:
                icons_map[icon.name] = {
                    "id": icon.id,
                    "display_name": icon.display_name,
                    "lucide_name": icon.lucide_name,
                    "material_name": icon.material_name,
                    "fontawesome_name": icon.fontawesome_name,
                    "svg_content": icon.svg_content if icon.is_custom else None
                }
            
            return {
                "version": "1.0.0",
                "platform": platform,
                "icons": icons_map
            }
            
        else:
            # Método otimizado do repository
            mapping = icons.get_platform_mapping(platform)
            return {
                "version": "1.0.0",
                "platform": platform,
                "icons": mapping
            }
            
    except Exception as e:
        raise HTTPException(500, str(e))

@app.get("/api/icons/{icon_name}", tags=["UI"])
async def get_icon_by_name(icon_name: str):
    """Retorna detalhes completos de um ícone específico"""
    try:
        from shared.repositories import icons
        
        icon = icons.get_by_name(icon_name)
        if not icon:
            raise HTTPException(404, f"Icon '{icon_name}' not found")
        
        # Se tem fallback, buscar o nome do ícone de fallback
        fallback_name = None
        if icon.fallback_icon_id:
            fallback_icon = icons.get_by_id(icon.fallback_icon_id)
            if fallback_icon:
                fallback_name = fallback_icon.name
        
        return {
            "id": icon.id,
            "name": icon.name,
            "display_name": icon.display_name,
            "category": icon.category,
            "svg_content": icon.svg_content,
            "svg_viewbox": icon.svg_viewbox,
            "lucide_name": icon.lucide_name,
            "material_name": icon.material_name,
            "fontawesome_name": icon.fontawesome_name,
            "lvgl_symbol": icon.lvgl_symbol,
            "unicode_char": icon.unicode_char,
            "emoji": icon.emoji,
            "fallback": fallback_name,
            "is_custom": icon.is_custom,
            "description": icon.description,
            "tags": json.loads(icon.tags) if icon.tags else []
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(500, str(e))
```

### 5. **GET /api/themes** ❌ (Parcialmente implementado)
**Prioridade**: BAIXA 🟢

**Status atual**: 
- ✅ `GET /api/themes` - Lista temas
- ✅ `GET /api/themes/default` - Tema padrão
- ❌ Falta estrutura completa de cores para displays

**Estrutura esperada aprimorada**:
```json
{
  "id": 1,
  "name": "dark",
  "description": "Tema escuro",
  "colors": {
    "primary": "#2196F3",
    "secondary": "#FFC107",
    "background": "#121212",
    "surface": "#1E1E1E",
    "text": "#FFFFFF",
    "text_secondary": "#B0B0B0",
    "error": "#F44336",
    "warning": "#FF9800",
    "success": "#4CAF50",
    "info": "#2196F3"
  },
  "display": {
    "background": "#000000",
    "header_bg": "#1E1E1E",
    "header_text": "#FFFFFF",
    "button_bg": "#2196F3",
    "button_text": "#FFFFFF",
    "button_pressed": "#1976D2",
    "nav_bg": "#1E1E1E",
    "nav_text": "#B0B0B0",
    "nav_active": "#2196F3"
  },
  "is_default": true
}
```

## 📝 Implementação Recomendada

### Ordem de Prioridade:

1. **🔴 ALTA**: `/api/config/full` - Crítico para reduzir número de requisições
2. **🟡 MÉDIA**: `/api/screens/{id}` - Útil para navegação dinâmica
3. **🟢 BAIXA**: `/api/layouts`, `/api/icons`, `/api/themes` - Nice to have

### Localização dos Arquivos:

Para implementar estes endpoints, você deve:

1. **Adicionar rotas** em:
   - `config-app/backend/main.py` (para testes rápidos)
   - OU criar `config-app/backend/api/routes/config.py` (recomendado)

2. **Usar repositories existentes**:
   ```python
   from shared.repositories import devices, relays, config
   ```

3. **Adicionar modelos Pydantic** em:
   - `config-app/backend/api/models/config.py` (criar arquivo)

### Exemplo de Implementação Completa:

```python
# config-app/backend/api/routes/config.py
from fastapi import APIRouter, HTTPException
from typing import Dict, Any
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent.parent.parent / "database"))
from shared.repositories import devices, relays, config as config_repo

router = APIRouter(prefix="/api/config", tags=["Configuration"])

@router.get("/full/{device_uuid}")
async def get_full_configuration(device_uuid: str) -> Dict[str, Any]:
    """
    Retorna configuração completa para dispositivo ESP32.
    Endpoint otimizado para reduzir número de requisições.
    """
    try:
        # Validar dispositivo
        device = devices.get_by_uuid(device_uuid)
        if not device:
            raise HTTPException(404, f"Device {device_uuid} not found")
        
        # Base config
        full_config = {
            "version": "2.0.0",
            "protocol_version": "2.2.0",
            "timestamp": datetime.now().isoformat(),
            "device": {
                "uuid": device.uuid,
                "type": device.type,
                "name": device.name
            }
        }
        
        # Adicionar configurações específicas por tipo
        if device.type in ["hmi_display", "esp32-display"]:
            # Screens com items
            screens = config_repo.get_screens()
            screens_data = []
            
            for screen in screens:
                screen_dict = {
                    "id": screen.id,
                    "name": screen.name,
                    "title": screen.title,
                    "type": screen.screen_type,
                    "position": screen.position,
                    "items": []
                }
                
                # Adicionar items
                items = config_repo.get_screen_items(screen.id)
                for item in items:
                    screen_dict["items"].append({
                        "id": item.id,
                        "type": item.item_type,
                        "label": item.label,
                        "icon": item.icon,
                        "action": item.action_json,
                        "position": item.position
                    })
                
                screens_data.append(screen_dict)
            
            full_config["screens"] = screens_data
            
            # Devices registry
            all_devices = devices.get_all()
            full_config["devices"] = [
                {
                    "id": d.id,
                    "uuid": d.uuid,
                    "name": d.name,
                    "type": d.type
                }
                for d in all_devices
            ]
            
            # Relay boards
            relay_boards = relays.get_all_boards()
            full_config["relay_boards"] = [
                {
                    "id": b.id,
                    "device_id": b.device_id,
                    "name": b.name,
                    "total_channels": b.total_channels
                }
                for b in relay_boards
            ]
            
            # Theme
            full_config["theme"] = {
                "name": "dark",
                "colors": {
                    "primary": "#2196F3",
                    "background": "#121212",
                    "text": "#FFFFFF"
                }
            }
        
        return full_config
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error generating config: {e}")
        raise HTTPException(500, "Internal server error")
```

## 🧪 Testes

### Testar com curl:

```bash
# Testar config completa
curl http://localhost:8000/api/config/full/esp32-display-001

# Testar tela específica
curl http://localhost:8000/api/screens/1?include_items=true

# Testar layouts
curl http://localhost:8000/api/layouts

# Testar ícones
curl http://localhost:8000/api/icons
```

### Testar com ESP32:

No firmware do ESP32, o `ScreenApiClient` deve ser atualizado para usar o novo endpoint:

```cpp
bool ScreenApiClient::loadFullConfiguration(JsonDocument& config) {
    String url = buildUrl("/config/full/" + deviceUUID);
    
    // Fazer apenas UMA requisição
    if (makeHttpRequest(url, response)) {
        DeserializationError error = deserializeJson(config, response);
        if (error == DeserializationError::Ok) {
            Serial.println("[API] Full config loaded in single request!");
            return true;
        }
    }
    return false;
}
```

## 📊 Benefícios da Implementação

### Antes (atual):
- 4+ requisições separadas para carregar configuração
- ~800ms total de latência
- Maior uso de memória com múltiplos buffers
- Complexidade no cliente

### Depois (com `/api/config/full`):
- 1 única requisição
- ~200ms de latência
- Menor uso de memória
- Código mais simples no ESP32

## 🚀 Próximos Passos

1. **Implementar** `/api/config/full` primeiro (prioridade máxima)
2. **Testar** com o ESP32 real
3. **Otimizar** resposta JSON (remover campos não usados)
4. **Cachear** resposta no backend (Redis ou memória)
5. **Documentar** no Swagger automático do FastAPI

## 📊 Notas sobre o Database

### Estrutura Atual
- **Database Principal**: `database/autocore.db` (2.5MB)
- **Database Backend**: `config-app/backend/autocore.db` (0 bytes - arquivo vazio)
- **Conclusão**: O backend usa o database compartilhado via repositories

### Tabelas Relevantes para ESP32-Display
1. **devices** - Dispositivos do sistema (id, uuid, name, type, status)
2. **screens** - Telas configuradas (id, name, title, columns, visibility flags)
3. **screen_items** - Itens das telas (id, type, label, icon, actions, relay refs)
4. **relay_boards** - Placas de relé (id, device_id, total_channels, model)
5. **relay_channels** - Canais individuais (id, board_id, number, name, function)
6. **themes** - Temas visuais (cores completas para UI)
7. **icons** ✅ **NOVA** - Tabela de ícones com mapeamentos multi-plataforma (26 ícones base)

### Campos Não Utilizados
Alguns campos existem no database mas podem não ser necessários para o ESP32-display:
- `screens`: columns_mobile, columns_web, show_on_mobile, show_on_web
- `screen_items`: size_mobile, size_web, data_source, data_path, data_format
- `devices`: configuration_json, capabilities_json (campos TEXT para JSON customizado)

### Recomendações
1. Usar apenas campos necessários para economizar memória no ESP32
2. Filtrar screens por `show_on_display_small` ou `show_on_display_large`
3. Considerar usar `configuration_json` do device para armazenar configs específicas do display

---

**Documento criado em**: Janeiro 2025  
**Autor**: Sistema AutoCore  
**Versão**: 1.1.0  
**Última Atualização**: Ajustado para usar estrutura real do database