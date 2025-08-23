# Endpoints - Temas

Gerenciamento de temas visuais para personalização da interface em diferentes dispositivos.

## 📋 Visão Geral

Os endpoints de temas permitem:
- Listar temas disponíveis no sistema
- Obter tema padrão aplicado globalmente
- Personalizar cores e aparência da interface
- Suporte para diferentes dispositivos (ESP32, Web, Mobile)

## 🎨 Endpoints de Temas

### `GET /api/themes`

Lista todos os temas disponíveis no sistema.

**Resposta:**
```json
[
  {
    "id": 1,
    "name": "default_dark",
    "description": "Tema escuro padrão do AutoCore",
    "primary_color": "#1976D2",
    "secondary_color": "#424242",
    "background_color": "#121212",
    "is_default": true
  },
  {
    "id": 2,
    "name": "automotive_blue",
    "description": "Tema azul para aplicações automotivas",
    "primary_color": "#0D47A1",
    "secondary_color": "#1565C0",
    "background_color": "#0A0A0A",
    "is_default": false
  },
  {
    "id": 3,
    "name": "racing_red",
    "description": "Tema vermelho para ambiente racing",
    "primary_color": "#D32F2F",
    "secondary_color": "#F57C00",
    "background_color": "#1A1A1A",
    "is_default": false
  }
]
```

**Códigos de Status:**
- `200` - Lista retornada com sucesso
- `500` - Erro interno do servidor

---

### `GET /api/themes/default`

Retorna o tema padrão configurado no sistema com todas as propriedades de cores.

**Resposta:**
```json
{
  "id": 1,
  "name": "default_dark",
  "description": "Tema escuro padrão do AutoCore",
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

**Códigos de Status:**
- `200` - Tema padrão retornado com sucesso
- `404` - Tema padrão não encontrado
- `500` - Erro interno do servidor

## 🎯 Propriedades de Cor

### Cores Principais
- **`primary_color`** - Cor primária do tema (botões, destaques)
- **`secondary_color`** - Cor secundária (elementos de apoio)
- **`background_color`** - Cor de fundo principal
- **`surface_color`** - Cor de superfícies (cards, painéis)

### Cores de Texto
- **`text_primary`** - Cor do texto principal
- **`text_secondary`** - Cor do texto secundário (labels, descrições)

### Cores de Status
- **`error_color`** - Cor para erros e alertas críticos (#F44336)
- **`warning_color`** - Cor para avisos e atenção (#FF9800)
- **`success_color`** - Cor para sucesso e confirmações (#4CAF50)
- **`info_color`** - Cor para informações gerais (#2196F3)

## 🎨 Temas Pré-definidos

### Default Dark
```json
{
  "name": "default_dark",
  "description": "Tema escuro padrão - ideal para ambientes com pouca luz",
  "primary_color": "#1976D2",
  "secondary_color": "#424242",
  "background_color": "#121212",
  "surface_color": "#1E1E1E",
  "text_primary": "#FFFFFF",
  "text_secondary": "#AAAAAA"
}
```

### Automotive Blue
```json
{
  "name": "automotive_blue",
  "description": "Tema azul automotivo - inspirado em painéis de carros esportivos",
  "primary_color": "#0D47A1",
  "secondary_color": "#1565C0",
  "background_color": "#0A0A0A",
  "surface_color": "#0F1419",
  "text_primary": "#E3F2FD",
  "text_secondary": "#90CAF9"
}
```

### Racing Red
```json
{
  "name": "racing_red",
  "description": "Tema vermelho racing - para ambiente de alta performance",
  "primary_color": "#D32F2F",
  "secondary_color": "#F57C00",
  "background_color": "#1A1A1A",
  "surface_color": "#2C1810",
  "text_primary": "#FFEBEE",
  "text_secondary": "#FFCDD2"
}
```

### Classic Light
```json
{
  "name": "classic_light",
  "description": "Tema claro clássico - para ambientes bem iluminados",
  "primary_color": "#1976D2",
  "secondary_color": "#757575",
  "background_color": "#FAFAFA",
  "surface_color": "#FFFFFF",
  "text_primary": "#212121",
  "text_secondary": "#757575"
}
```

## 📱 Aplicação por Dispositivo

### ESP32 Display
- Cores otimizadas para displays TFT
- Alto contraste para legibilidade
- Cores sólidas para performance

### Interface Web
- Suporte completo a gradientes
- Transparências e sombras
- Animações de transição

### Mobile App
- Adaptação automática ao modo escuro do sistema
- Cores seguem guidelines Material Design
- Suporte a temas personalizados do usuário

## 🔧 Integração com Configuração

O tema padrão é automaticamente incluído na configuração completa dos dispositivos:

```json
{
  "version": "2.0.0",
  "device": { ... },
  "screens": [ ... ],
  "theme": {
    "id": 1,
    "name": "default_dark",
    "primary_color": "#1976D2",
    "secondary_color": "#424242",
    "background_color": "#121212",
    "surface_color": "#1E1E1E",
    "text_primary": "#FFFFFF",
    "text_secondary": "#AAAAAA",
    "error_color": "#F44336",
    "warning_color": "#FF9800",
    "success_color": "#4CAF50",
    "info_color": "#2196F3"
  }
}
```

## 🎯 Casos de Uso

### Personalização por Usuário
```javascript
// Web/Mobile - Aplicar tema dinamicamente
const theme = await fetch('/api/themes/default').then(r => r.json());
applyTheme(theme);
```

### Configuração ESP32
```cpp
// ESP32 - Usar cores do tema na interface
void setupDisplay() {
    display.setBackgroundColor(theme.background_color);
    display.setPrimaryColor(theme.primary_color);
    display.setTextColor(theme.text_primary);
}
```

### Validação de Contraste
```python
# Backend - Validar legibilidade das cores
def validateThemeContrast(theme):
    contrast_ratio = calculateContrast(
        theme.text_primary, 
        theme.background_color
    )
    return contrast_ratio >= 4.5  # WCAG AA standard
```

## 🎨 Paleta de Cores Material

### Blues (Confiabilidade)
- `#0D47A1` - Deep Blue (primário)
- `#1565C0` - Blue 800 (secundário)
- `#1976D2` - Blue 700 (padrão)
- `#1E88E5` - Blue 600 (hover)

### Reds (Urgência/Performance)
- `#B71C1C` - Deep Red (crítico)
- `#C62828` - Red 800 (erro)
- `#D32F2F` - Red 700 (alerta)
- `#E53935` - Red 600 (atenção)

### Greens (Sucesso/OK)
- `#1B5E20` - Deep Green (confirmação)
- `#2E7D32` - Green 800 (sucesso)
- `#388E3C` - Green 700 (positivo)
- `#43A047` - Green 600 (ativo)

### Grays (Neutro)
- `#212121` - Quase preto (texto principal)
- `#424242` - Cinza escuro (bordas)
- `#757575` - Cinza médio (texto secundário)
- `#BDBDBD` - Cinza claro (desabilitado)

## ⚠️ Considerações

### Performance
- ESP32 possui limitações de cores (16-bit)
- Gradientes não são suportados em displays simples
- Cores sólidas têm melhor performance

### Acessibilidade
- Manter contraste mínimo de 4.5:1 (WCAG AA)
- Testar legibilidade em diferentes tamanhos de tela
- Considerar daltonismo na escolha das cores

### Personalização
- Tema padrão é aplicado automaticamente
- Futuras versões suportarão temas customizáveis
- Cores podem ser sobrescritas por dispositivo específico

## 🔄 Roadmap

### Funcionalidades Futuras
- `POST /api/themes` - Criar temas personalizados
- `PUT /api/themes/{id}` - Editar temas existentes
- `POST /api/themes/{id}/set-default` - Definir novo tema padrão
- `GET /api/themes/preview` - Visualização de tema em tempo real
- Suporte a temas por usuário/dispositivo
- Temas sazonais e contextuais