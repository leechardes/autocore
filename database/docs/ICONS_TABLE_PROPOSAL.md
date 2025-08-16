# 📋 Proposta: Tabela de Ícones (icons)

## 📊 Visão Geral

Proposta para criação de uma tabela `icons` no database AutoCore para centralizar o gerenciamento de ícones utilizados em diferentes plataformas (Web, Mobile, ESP32).

## 🎯 Objetivo

Criar uma tabela que:
1. Armazene SVG customizados para ícones específicos
2. Mapeie ícones para bibliotecas nativas de cada plataforma
3. Permita fallback quando um ícone não existir em determinada plataforma
4. Centralize a gestão visual dos ícones do sistema

## 📐 Estrutura Proposta

### Tabela: `icons`

```sql
CREATE TABLE icons (
    -- Identificação
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,      -- Nome único do ícone (ex: "light_high")
    display_name VARCHAR(100) NOT NULL,    -- Nome para exibição (ex: "Farol Alto")
    category VARCHAR(50),                  -- Categoria (lighting, navigation, control, status)
    
    -- SVG Customizado (quando disponível)
    svg_content TEXT,                      -- Conteúdo SVG completo
    svg_viewbox VARCHAR(50),               -- ViewBox do SVG (ex: "0 0 24 24")
    svg_fill_color VARCHAR(7),             -- Cor padrão de preenchimento
    svg_stroke_color VARCHAR(7),           -- Cor padrão de contorno
    
    -- Mapeamentos para Bibliotecas
    lucide_name VARCHAR(50),               -- Nome no Lucide Icons (web/mobile)
    material_name VARCHAR(50),             -- Nome no Material Icons
    fontawesome_name VARCHAR(50),          -- Nome no Font Awesome
    lvgl_symbol VARCHAR(50),               -- Símbolo LVGL para ESP32 (ex: "LV_SYMBOL_LIGHT")
    
    -- Fallbacks e Alternativas
    unicode_char VARCHAR(10),              -- Caractere Unicode como fallback
    emoji VARCHAR(10),                     -- Emoji como último fallback
    fallback_icon_id INTEGER,              -- ID de outro ícone como fallback
    
    -- Metadados
    description TEXT,                      -- Descrição do uso do ícone
    tags TEXT,                             -- Tags para busca (JSON array)
    is_custom BOOLEAN DEFAULT FALSE,       -- Se é um ícone customizado
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    FOREIGN KEY (fallback_icon_id) REFERENCES icons(id) ON DELETE SET NULL
);

-- Índices para performance
CREATE INDEX idx_icons_name ON icons(name);
CREATE INDEX idx_icons_category ON icons(category);
CREATE INDEX idx_icons_active ON icons(is_active);
```

## 📝 Exemplos de Dados

```sql
-- Ícones de Iluminação
INSERT INTO icons (name, display_name, category, svg_content, lucide_name, lvgl_symbol, unicode_char, emoji) 
VALUES 
('light', 'Luz', 'lighting', NULL, 'lightbulb', 'LV_SYMBOL_LIGHT', '\uf0eb', '💡'),
('light_high', 'Farol Alto', 'lighting', '<svg>...</svg>', 'zap', 'LV_SYMBOL_LIGHT', '\uf0e7', '🔦'),
('light_low', 'Farol Baixo', 'lighting', NULL, 'lightbulb', 'LV_SYMBOL_LIGHT', '\uf0eb', '💡'),
('fog_light', 'Farol de Neblina', 'lighting', '<svg>...</svg>', 'cloud-fog', NULL, '\uf0c2', '🌫️');

-- Ícones de Navegação  
INSERT INTO icons (name, display_name, category, lucide_name, material_name, lvgl_symbol)
VALUES
('home', 'Início', 'navigation', 'home', 'home', 'LV_SYMBOL_HOME'),
('back', 'Voltar', 'navigation', 'arrow-left', 'arrow_back', 'LV_SYMBOL_LEFT'),
('settings', 'Configurações', 'navigation', 'settings', 'settings', 'LV_SYMBOL_SETTINGS');

-- Ícones de Controle
INSERT INTO icons (name, display_name, category, lucide_name, lvgl_symbol, fallback_icon_id)
VALUES
('power', 'Liga/Desliga', 'control', 'power', 'LV_SYMBOL_POWER', NULL),
('play', 'Iniciar', 'control', 'play', 'LV_SYMBOL_PLAY', NULL),
('stop', 'Parar', 'control', 'square', 'LV_SYMBOL_STOP', NULL),
('winch_in', 'Guincho Recolher', 'control', NULL, NULL, (SELECT id FROM icons WHERE name = 'play')),
('winch_out', 'Guincho Soltar', 'control', NULL, NULL, (SELECT id FROM icons WHERE name = 'play'));

-- Ícones de Status
INSERT INTO icons (name, display_name, category, lucide_name, material_name, lvgl_symbol, emoji)
VALUES
('ok', 'OK', 'status', 'check', 'check', 'LV_SYMBOL_OK', '✅'),
('warning', 'Aviso', 'status', 'alert-triangle', 'warning', 'LV_SYMBOL_WARNING', '⚠️'),
('error', 'Erro', 'status', 'x-circle', 'error', 'LV_SYMBOL_CLOSE', '❌'),
('wifi', 'WiFi', 'status', 'wifi', 'wifi', 'LV_SYMBOL_WIFI', '📶'),
('battery', 'Bateria', 'status', 'battery', 'battery_full', 'LV_SYMBOL_BATTERY_FULL', '🔋');

-- Ícones Customizados (SVG específicos do AutoCore)
INSERT INTO icons (name, display_name, category, svg_content, svg_viewbox, is_custom)
VALUES
('compressor', 'Compressor de Ar', 'control', 
    '<svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10..."/></svg>',
    '0 0 24 24', TRUE),
('4x4_mode', 'Modo 4x4', 'control',
    '<svg viewBox="0 0 32 32"><rect x="4" y="8" width="6" height="8"/>...</svg>',
    '0 0 32 32', TRUE);
```

## 🔧 Repository Methods Sugeridos

```python
# database/shared/repositories/icons.py

class IconsRepository:
    def get_all(self, category: str = None, active_only: bool = True):
        """Lista todos os ícones, opcionalmente filtrados por categoria"""
        
    def get_by_name(self, name: str):
        """Busca ícone por nome único"""
        
    def get_platform_mapping(self, platform: str):
        """Retorna mapeamento de ícones para plataforma específica"""
        # platform: web, mobile, esp32
        
    def get_with_fallbacks(self, name: str):
        """Retorna ícone com sua cadeia de fallbacks"""
        
    def search(self, query: str):
        """Busca ícones por nome, display_name ou tags"""
        
    def create_custom(self, name: str, svg_content: str, **kwargs):
        """Cria ícone customizado com SVG"""
        
    def update_mappings(self, icon_id: int, mappings: dict):
        """Atualiza mapeamentos para bibliotecas"""
```

## 🎯 Casos de Uso

### 1. Web (React/Vue)
```javascript
// Busca ícone e usa Lucide ou SVG customizado
const icon = await api.get('/api/icons/light_high');
if (icon.svg_content) {
    // Renderiza SVG customizado
    return <div dangerouslySetInnerHTML={{__html: icon.svg_content}} />;
} else if (icon.lucide_name) {
    // Usa Lucide Icons
    return <LucideIcon name={icon.lucide_name} />;
}
```

### 2. Mobile (Flutter)
```dart
// Busca ícone e usa Material Icons ou SVG
final icon = await api.getIcon('light_high');
if (icon.materialName != null) {
  return Icon(IconData(icon.materialName));
} else if (icon.svgContent != null) {
  return SvgPicture.string(icon.svgContent);
}
```

### 3. ESP32 (LVGL)
```cpp
// Busca ícone e usa símbolo LVGL ou caractere Unicode
Icon icon = getIcon("light_high");
if (icon.lvgl_symbol) {
    lv_label_set_text(label, icon.lvgl_symbol);
} else if (icon.unicode_char) {
    lv_label_set_text(label, icon.unicode_char);
} else {
    // Usa emoji como último recurso
    lv_label_set_text(label, icon.emoji);
}
```

## 📊 Endpoints da API

### Endpoints Necessários

```python
# GET /api/icons
# Lista todos os ícones disponíveis
{
    "icons": [
        {
            "id": 1,
            "name": "light",
            "display_name": "Luz",
            "category": "lighting",
            "has_svg": false,
            "platforms": ["web", "mobile", "esp32"]
        }
    ]
}

# GET /api/icons/{name}
# Retorna ícone específico com todos os mapeamentos
{
    "id": 1,
    "name": "light",
    "display_name": "Luz",
    "svg_content": null,
    "lucide_name": "lightbulb",
    "material_name": "lightbulb",
    "lvgl_symbol": "LV_SYMBOL_LIGHT",
    "unicode_char": "\uf0eb",
    "emoji": "💡"
}

# GET /api/icons/platform/{platform}
# Retorna mapeamento otimizado para plataforma
# platform: web, mobile, esp32
{
    "light": "lightbulb",      // Para web: retorna lucide_name
    "power": "power",
    "settings": "settings"
}

# POST /api/icons
# Cria novo ícone customizado (admin only)
{
    "name": "custom_icon",
    "display_name": "Ícone Custom",
    "svg_content": "<svg>...</svg>",
    "category": "custom"
}
```

## 🔄 Migração

### Passo 1: Criar tabela
```bash
cd database
python manage.py create_migration add_icons_table
# Adicionar SQL de criação da tabela
python manage.py migrate
```

### Passo 2: Popular dados iniciais
```python
# database/seeds/icons_seed.py
def seed_icons():
    """Popula tabela icons com ícones padrão do sistema"""
    icons = [
        # Lista de ícones base
    ]
    icons_repo.bulk_insert(icons)
```

### Passo 3: Atualizar referências
```sql
-- Atualizar screen_items e screens para usar icon_id ao invés de icon string
ALTER TABLE screen_items ADD COLUMN icon_id INTEGER REFERENCES icons(id);
ALTER TABLE screens ADD COLUMN icon_id INTEGER REFERENCES icons(id);

-- Migrar dados existentes
UPDATE screen_items 
SET icon_id = (SELECT id FROM icons WHERE name = screen_items.icon)
WHERE icon IS NOT NULL;
```

## 💡 Benefícios

1. **Centralização**: Um único local para gerenciar todos os ícones
2. **Flexibilidade**: Suporte a SVG customizado quando necessário
3. **Performance**: Cache de mapeamentos por plataforma
4. **Consistência**: Mesmos ícones em todas as plataformas
5. **Fallbacks**: Sistema robusto de fallbacks
6. **Extensibilidade**: Fácil adicionar novas bibliotecas de ícones

## ⚠️ Considerações

1. **Tamanho do SVG**: Limitar tamanho do campo svg_content (sugestão: 10KB)
2. **Cache**: Implementar cache agressivo no backend
3. **Compressão**: Considerar compressão do SVG antes de armazenar
4. **Validação**: Validar SVG antes de aceitar (evitar XSS)
5. **Retrocompatibilidade**: Manter campo string `icon` nas tabelas existentes durante transição

## 📅 Cronograma Sugerido

1. **Fase 1**: Criar tabela e repository (1 dia)
2. **Fase 2**: Popular com ícones base (1 dia)
3. **Fase 3**: Implementar endpoints da API (1 dia)
4. **Fase 4**: Atualizar frontend para usar nova estrutura (2 dias)
5. **Fase 5**: Migrar ESP32 para usar mapeamentos (1 dia)

---

**Documento criado em**: Janeiro 2025  
**Autor**: Sistema AutoCore  
**Versão**: 1.0.0  
**Status**: 🔵 PROPOSTA - Aguardando aprovação para implementação