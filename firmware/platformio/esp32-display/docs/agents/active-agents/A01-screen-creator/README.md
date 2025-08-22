# A01 - Screen Creator Agent

## 🎯 Purpose
Automatiza a criação de novas telas LVGL para o sistema AutoCore ESP32 Display. Este agente gera código C++ completo para telas responsivas, incluindo headers, implementações, e integração automática com o ScreenFactory.

## 🚀 Usage
```bash
# Criar tela básica com botões de relay
./run-agent.sh A01-screen-creator --template=basic --screen_name=LightingControl --components=relay,navigation

# Criar dashboard com múltiplos tipos de componentes
./run-agent.sh A01-screen-creator --template=dashboard --screen_name=SystemDashboard --components=relay,action,display,gauge --layout_columns=2 --layout_rows=3

# Criar tela de configurações
./run-agent.sh A01-screen-creator --template=settings --screen_name=DeviceSettings --components=switch,navigation --theme=dark
```

## ⚙️ Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| screen_name | string | Yes | - | Nome da classe da tela (ex: "LightingControl") |
| template | string | No | basic | Tipo de template: basic, dashboard, settings, status |
| components | array | No | ["navigation"] | Componentes a incluir: relay, action, display, navigation, switch, gauge |
| layout_columns | integer | No | 2 | Número de colunas no grid layout (1-4) |
| layout_rows | integer | No | 3 | Número de linhas no grid layout (1-6) |
| theme | string | No | default | Tema visual: default, dark, light, custom |
| header_title | string | No | screen_name | Título exibido no header da tela |
| enable_gestures | boolean | No | true | Habilitar suporte a gestos (swipe, etc.) |
| animation_type | string | No | slide | Tipo de animação: slide, fade, none |

## 📊 Output

O agente gera os seguintes arquivos:

### Generated Files
- `{screen_name}.h` - Header da tela com declarações de classe
- `{screen_name}.cpp` - Implementação completa da tela
- `{screen_name}_config.json` - Configuração JSON para ScreenFactory
- `{screen_name}_test.cpp` - Testes unitários básicos
- `README_{screen_name}.md` - Documentação da tela

### Integration Files
- Atualiza `ScreenFactory.cpp` com novo tipo de tela
- Adiciona entrada em `screen_registry.json`
- Gera exemplo de uso em `examples/`

## 🔧 Configuration

### agent-config.json
```json
{
  "agent_id": "A01-screen-creator",
  "agent_name": "Screen Creator Agent",
  "version": "1.2.0",
  "description": "Automated LVGL screen generation for ESP32 displays",
  "templates": {
    "basic": {
      "layout": "simple_grid",
      "components": ["header", "content", "footer"],
      "max_buttons": 6
    },
    "dashboard": {
      "layout": "flexible_grid", 
      "components": ["header", "navigation", "content", "status"],
      "max_buttons": 12
    },
    "settings": {
      "layout": "list_view",
      "components": ["header", "content", "save_buttons"],
      "max_buttons": 8
    },
    "status": {
      "layout": "info_panels",
      "components": ["header", "metrics", "logs"],
      "max_buttons": 4
    }
  },
  "validation_rules": {
    "max_memory_usage": "32KB",
    "max_objects": 50,
    "required_methods": ["initialize", "show", "hide", "update"],
    "naming_convention": "PascalCase"
  }
}
```

### Template Customization
```json
{
  "custom_templates": {
    "sensor_dashboard": {
      "base_template": "dashboard",
      "specialized_components": ["gauge", "chart", "alert"],
      "default_layout": {"columns": 3, "rows": 2},
      "color_scheme": "blue_gradient"
    }
  }
}
```

## 🧪 Testing

### Automated Tests
```bash
# Testar geração básica
./test-agent.sh A01-screen-creator basic_generation

# Testar todos os templates
./test-agent.sh A01-screen-creator all_templates

# Testar integração com ScreenFactory
./test-agent.sh A01-screen-creator integration
```

### Manual Validation
1. **Compilation Test**: Código gerado deve compilar sem erros
2. **Memory Test**: Uso de memória deve estar dentro dos limites
3. **UI Test**: Interface deve renderizar corretamente
4. **Integration Test**: Tela deve integrar com ScreenManager

### Validation Script
```python
#!/usr/bin/env python3
"""
Validação automática do código gerado pelo Screen Creator
"""

import subprocess
import json
from pathlib import Path

def validate_generated_screen(screen_name: str) -> bool:
    """Valida se a tela gerada está correta"""
    
    # 1. Verificar se arquivos foram criados
    header_file = f"output/{screen_name}.h"
    cpp_file = f"output/{screen_name}.cpp"
    
    if not all(Path(f).exists() for f in [header_file, cpp_file]):
        print("❌ Missing generated files")
        return False
    
    # 2. Verificar sintaxe C++
    compile_result = subprocess.run([
        "g++", "-fsyntax-only", "-I../include", 
        header_file, cpp_file
    ], capture_output=True)
    
    if compile_result.returncode != 0:
        print(f"❌ Compilation errors: {compile_result.stderr}")
        return False
    
    # 3. Verificar métodos obrigatórios
    with open(cpp_file) as f:
        content = f.read()
        required_methods = ["initialize", "show", "hide", "update"]
        for method in required_methods:
            if f"::{method}(" not in content:
                print(f"❌ Missing required method: {method}")
                return False
    
    # 4. Verificar naming convention
    if not screen_name[0].isupper():
        print("❌ Screen name must start with uppercase")
        return False
    
    print("✅ Screen validation passed")
    return True
```

## 📝 Examples

### Example 1: Basic Relay Control Screen
```bash
./run-agent.sh A01-screen-creator \
  --screen_name=RelayControl \
  --template=basic \
  --components=relay,navigation \
  --layout_columns=2 \
  --layout_rows=2 \
  --header_title="Relay Control"
```

**Generated Output:**
```cpp
// RelayControl.h
#ifndef RELAY_CONTROL_H
#define RELAY_CONTROL_H

#include "ScreenBase.h"
#include "NavButton.h"

class RelayControl : public ScreenBase {
private:
    std::vector<NavButton*> relayButtons;
    lv_obj_t* container;
    lv_obj_t* header;
    lv_obj_t* content;

public:
    RelayControl(const String& screenId, JsonObject& config);
    virtual ~RelayControl();
    
    virtual bool initialize() override;
    virtual void show() override;
    virtual void hide() override;
    virtual void update(JsonObject& data) override;
    // ... more methods
};

#endif
```

### Example 2: System Dashboard
```bash
./run-agent.sh A01-screen-creator \
  --screen_name=SystemDashboard \
  --template=dashboard \
  --components=display,gauge,action,navigation \
  --layout_columns=3 \
  --layout_rows=2 \
  --theme=dark \
  --enable_gestures=true
```

**Features Generated:**
- Real-time system metrics display
- CPU/Memory gauge widgets
- Quick action buttons
- Swipe navigation between metrics
- Dark theme styling
- Auto-refresh every 5 seconds

### Example 3: Device Settings Screen
```bash
./run-agent.sh A01-screen-creator \
  --screen_name=DeviceSettings \
  --template=settings \
  --components=switch,navigation \
  --layout_columns=1 \
  --header_title="Device Configuration"
```

**Features Generated:**
- List-style settings layout
- Toggle switches for options
- Save/Cancel navigation buttons
- Configuration persistence
- Input validation

## 🔍 Advanced Features

### Custom Component Templates
```json
{
  "custom_components": {
    "temperature_display": {
      "type": "display",
      "widget": "gauge",
      "properties": {
        "unit": "°C",
        "min_value": -10,
        "max_value": 50,
        "color_ranges": [
          {"min": -10, "max": 0, "color": "#2196F3"},
          {"min": 0, "max": 25, "color": "#4CAF50"},
          {"min": 25, "max": 50, "color": "#FF5722"}
        ]
      }
    }
  }
}
```

### Layout Optimization
```python
def optimize_layout(components, screen_size):
    """Otimiza layout baseado no número de componentes"""
    component_count = len(components)
    
    if component_count <= 4:
        return {"columns": 2, "rows": 2}
    elif component_count <= 6:
        return {"columns": 2, "rows": 3}
    elif component_count <= 9:
        return {"columns": 3, "rows": 3}
    else:
        return {"columns": 4, "rows": 3}  # Maximum density
```

### Memory Optimization
- Lazy loading de componentes não visíveis
- Object pooling para botões
- Compression de recursos gráficos
- Smart caching de configurações

## 🚨 Common Issues

### Issue 1: Memory Overflow
**Problem**: Tela gerada usa muita memória RAM  
**Solution**: Reduzir número de componentes ou usar layout mais eficiente
```bash
--layout_columns=1 --components=relay,navigation  # Minimal layout
```

### Issue 2: Compilation Errors
**Problem**: Código gerado não compila  
**Solution**: Verificar dependências e includes
```bash
# Re-run with validation
./run-agent.sh A01-screen-creator --validate=true --screen_name=TestScreen
```

### Issue 3: UI Not Responsive
**Problem**: Interface fica lenta ou não responde  
**Solution**: Otimizar refresh rate e animações
```bash
--animation_type=none --enable_gestures=false  # Performance mode
```

## 📈 Performance Metrics

### Generation Speed
- Basic screen: ~2 seconds
- Dashboard screen: ~5 seconds  
- Settings screen: ~3 seconds
- Complex custom screen: ~8 seconds

### Memory Usage
- Generated header: ~2-5 KB
- Implementation file: ~5-15 KB
- Runtime memory: ~8-32 KB (depending on components)

### Code Quality
- Automatic code formatting (clang-format)
- Static analysis integration
- LVGL best practices compliance
- Memory leak detection

## 🔄 Version History

### v1.2.0 (Current)
- Added gauge and switch component support
- Improved memory optimization
- Custom theme support
- Gesture handling
- Better error reporting

### v1.1.0
- Dashboard template added
- Layout optimization
- Integration with ScreenFactory
- Test generation

### v1.0.0
- Basic screen generation
- NavButton integration
- Simple layouts