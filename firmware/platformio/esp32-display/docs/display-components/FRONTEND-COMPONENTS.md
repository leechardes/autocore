# Frontend Components - Display P Análise Completa

Este documento detalha todos os componentes visuais suportados pelo frontend do sistema Display P, suas propriedades e como são renderizados.

## 1. Visão Geral do Sistema

O sistema Display P suporta 4 tipos de dispositivos com diferentes resoluções e layouts:

### Tipos de Dispositivo Suportados

| Dispositivo | Resolução | Colunas Padrão | Campo API |
|------------|-----------|----------------|-----------|
| **Mobile** | 375x667px | 2 | `columns_mobile` |
| **Display P (Small)** | 480x320px | 2 | `columns_display_small` |
| **Display G (Large)** | 800x480px | 3 | `columns_display_large` |
| **Web** | 100%x600px | 4 | `columns_web` |

## 2. Tipos de Componentes Suportados

### 2.1. Button (Botão)

**Funcionalidade**: Componentes clicáveis para executar ações

**Estrutura visual**:
```jsx
<Button
  variant={buttonVariant}        // 'default', 'outline', 'destructive', 'secondary'
  className="col-span-X h-Y flex flex-col gap-2"
  onClick={handleItemAction}
>
  <IconComponent className="h-6 w-6" />
  <span className="text-xs">{item.label}</span>
  {buttonType === 'momentary' && (
    <Badge variant="outline" className="text-[10px]">HOLD</Badge>
  )}
</Button>
```

**Propriedades Visuais**:
- **Tamanhos**: `small` (h-16), `normal` (h-20), `large` (h-24), `full` (col-span-full)
- **Estados**: `toggle` (padrão), `momentary`, `pulse`
- **Cores**: Baseadas no estado (ativo/inativo) e tipo
- **Ícones**: Sistema Lucide React com 20+ ícones mapeados

**Tipos de Ação**:
- `relay_toggle` - Alterna estado de relé
- `relay_on` - Liga relé
- `relay_off` - Desliga relé  
- `screen_navigate` - Navega para outra tela
- `macro_execute` - Executa macro
- `none` - Sem ação

### 2.2. Switch (Interruptor)

**Funcionalidade**: Toggle visual mais elegante que botões

**Estrutura visual**:
```jsx
<Card className="col-span-X p-4">
  <div className="flex items-center justify-between">
    <div className="flex items-center gap-3">
      <IconComponent className="h-5 w-5" />
      <span className="text-sm font-medium">{item.label}</span>
    </div>
    <Switch
      checked={isActive}
      onCheckedChange={handleItemAction}
    />
  </div>
</Card>
```

**Propriedades Visuais**:
- **Layout**: Sempre horizontal com ícone + label + switch
- **Tamanhos**: Mesmos tamanhos que botões
- **Estados**: Checked/unchecked com animação
- **Estilo**: Card com bordas arredondadas

### 2.3. Gauge (Medidor)

**Funcionalidade**: Exibe valores numéricos com barra de progresso

**Estrutura visual**:
```jsx
<Card className="col-span-X p-4">
  <div className="space-y-2">
    <div className="flex items-center justify-between">
      <span className="text-sm font-medium">{item.label}</span>
      <IconComponent className="h-4 w-4 text-muted-foreground" />
    </div>
    <div className="space-y-1">
      <Progress value={value} className="h-2" />
      <div className="flex justify-between text-xs text-muted-foreground">
        <span>0</span>
        <span className="font-medium text-foreground">
          {value}{item.data_unit || '%'}
        </span>
        <span>100</span>
      </div>
    </div>
  </div>
</Card>
```

**Propriedades Visuais**:
- **Barra de Progresso**: Altura fixa (h-2), valor 0-100
- **Labels**: Min/Max/Atual com formatação
- **Cores**: Progressiva baseada no valor
- **Unidades**: Configurável por item

### 2.4. Display (Informativo)

**Funcionalidade**: Mostra dados dinâmicos sem interação

**Estrutura visual**:
```jsx
<Card className="col-span-X p-Y hover:shadow-lg transition-shadow">
  <div className="flex items-center justify-between">
    <div className="flex-1">
      <div className="text-xs text-muted-foreground uppercase tracking-wider">
        {item.label}
      </div>
      <div className="text-2xl font-bold tabular-nums">
        {displayValue.toLocaleString()} {item.data_unit || ''}
      </div>
    </div>
    <IconComponent className="h-8 w-8 text-muted-foreground" />
  </div>
</Card>
```

**Propriedades Visuais**:
- **Typography**: `text-xs` para label, `text-2xl` para valor
- **Cores Condicionais**: 
  - Vermelho: temperatura > 90°C
  - Laranja: combustível < 20%
  - Amarelo: RPM > 4000
- **Tamanhos de Fonte**: Escalam com tamanho do componente
- **Formatação**: Números com separadores de milhar

## 3. Sistema de Tamanhos

### 3.1. Mapeamento de Tamanhos por Dispositivo

Cada item tem 4 campos de tamanho independentes:
- `size_mobile`: Para dispositivos mobile
- `size_display_small`: Para Display P (480x320)
- `size_display_large`: Para Display G (800x480)  
- `size_web`: Para interface web

### 3.2. Classes CSS por Tamanho

```css
/* Grid Span Classes */
.col-span-1    /* small/normal - 1 coluna */
.col-span-2    /* large - 2 colunas */
.col-span-full /* full - largura total */

/* Height Classes */
.h-16         /* small - 64px */
.h-20         /* normal - 80px */
.h-24         /* large - 96px */

/* Icon Sizes */
.h-4.w-4      /* 16px - gauge icons */
.h-5.w-5      /* 20px - switch icons */
.h-6.w-6      /* 24px - button icons normal */
.h-8.w-8      /* 32px - button icons large */
.h-10.w-10    /* 40px - display icons large */
```

## 4. Sistema de Ícones

### 4.1. Biblioteca Base

Utiliza **Lucide React** com mapeamento customizado:

```javascript
const iconMap = {
  // Ícones básicos
  'home': Home,
  'lightbulb': Lightbulb,
  'power': Power,
  'gauge': Gauge,
  'toggle': ToggleLeft,
  'circle': Circle,
  'square': Square,
  'activity': Activity,
  'thermometer': Thermometer,
  'droplets': Droplets,
  'wind': Wind,
  'battery': Battery,
  'wifi': Wifi,
  'settings': Settings,
  
  // Ícones específicos do projeto
  'speedometer': Gauge,
  'tachometer': Activity,
  'fuel': Droplets,
  'light-high': Lightbulb,
  'light-low': Lightbulb,
  'light-fog': Lightbulb,
  'light-emergency': Lightbulb,
  'winch': Settings,
  'air-compressor': Wind,
  'power-inverter': Power,
  'radio': Wifi
}
```

### 4.2. Fallback e Tratamento de Erros

- **Ícone padrão**: `Circle` quando ícone não encontrado
- **Log de aviso**: Para ícones não mapeados
- **Graceful degradation**: Funcionalidade mantida sem ícone

## 5. Sistema de Estados e Cores

### 5.1. Estados de Botão

```javascript
// Estados baseados no tipo e ação
if (buttonType === 'momentary') {
  buttonVariant = isActive ? 'destructive' : 'secondary'
} else {
  buttonVariant = isActive ? 'default' : 'outline'
}
```

### 5.2. Variantes de Estilo

- **default**: Cor primária do tema
- **outline**: Borda com fundo transparente
- **secondary**: Cor secundária do tema
- **destructive**: Vermelho para ações perigosas

### 5.3. Classes de Transição

```css
.transition-all      /* Todas as propriedades */
.hover:scale-105     /* Efeito hover nos botões */
.hover:shadow-lg     /* Sombra nos cards */
.transition-shadow   /* Transição suave de sombra */
```

## 6. Layout e Grid System

### 6.1. Container Principal

```jsx
<div 
  className="grid gap-3"
  style={{
    gridTemplateColumns: `repeat(${columns}, 1fr)`
  }}
>
  {items.map(item => renderItem(item))}
</div>
```

### 6.2. Responsive Design

- **Mobile**: 2 colunas padrão, itens compactos
- **Display P**: 2 colunas, otimizado para 480x320
- **Display G**: 3-4 colunas, aproveita 800x480
- **Web**: 4+ colunas, layout flexível

## 7. Dados Dinâmicos e Formatação

### 7.1. Fontes de Dados

- `relay_state`: Estado atual de relés
- `can_signal`: Sinais do barramento CAN
- `telemetry`: Dados de sensores
- `static`: Valores fixos

### 7.2. Formatação de Valores

```javascript
// Formatação baseada no tipo
if (item.data_format === 'percentage') {
  displayText = `${value}${item.data_unit || '%'}`
} else {
  displayText = `${value.toLocaleString()} ${item.data_unit || ''}`
}
```

### 7.3. Cores Condicionais

```javascript
// Cores baseadas em thresholds
let valueColor = ''
if (item.name === 'temp' && displayValue > 90) valueColor = 'text-red-500'
else if (item.name === 'fuel' && displayValue < 20) valueColor = 'text-orange-500'
else if (item.name === 'rpm' && displayValue > 4000) valueColor = 'text-yellow-500'
```

## 8. Navegação e Interação

### 8.1. Navegação Entre Telas

```javascript
// Ação de navegação
if (item.action_type === 'screen_navigate' && item.action_target) {
  const targetScreen = screens.find(s => s.name === item.action_target)
  if (targetScreen) {
    navigateToScreen(targetScreen)
  }
}
```

### 8.2. Controle de Relés

```javascript
// Estados momentâneos vs toggle
if (payload.momentary) {
  setItemStates(prev => ({ ...prev, [item.id]: true }))
  setTimeout(() => {
    setItemStates(prev => ({ ...prev, [item.id]: false }))
  }, 500)
} else {
  setItemStates(prev => ({ ...prev, [item.id]: !prev[item.id] }))
}
```

## 9. Temas e Customização

### 9.1. Sistema de Temas

Utiliza **Tailwind CSS** com variáveis CSS customizáveis:

```css
:root {
  --primary: 210 40% 98%;
  --primary-foreground: 222.2 47.4% 11.2%;
  --secondary: 210 40% 96%;
  --muted: 210 40% 98%;
  --border: 214.3 31.8% 91.4%;
  /* ... mais variáveis */
}
```

### 9.2. Classes de Tema

- `bg-background`: Cor de fundo principal
- `text-foreground`: Cor do texto principal
- `border-border`: Cor das bordas
- `text-muted-foreground`: Texto secundário

## 10. Performance e Otimizações

### 10.1. Renderização Condicional

```javascript
// Só renderiza itens ativos
{screenItems
  .filter(item => item.is_active)
  .sort((a, b) => a.position - b.position)
  .map(item => renderItem(item))
}
```

### 10.2. Memoização de Estados

- Estados dos itens são mantidos em objeto único
- Atualizações parciais para evitar re-renders
- Simulação de dados dinâmicos para preview

## 11. Compatibilidade e Fallbacks

### 11.1. Dispositivos Não Suportados

- Verificação de visibilidade por dispositivo
- Mensagens de erro amigáveis
- Fallback para configurações básicas

### 11.2. Dados Ausentes

- Valores padrão para todas as propriedades
- Tratamento graceful de erros de API
- Estados de loading e erro

---

## Próximos Passos

Este documento serve como base para implementação no ESP32-Display. As próximas análises devem focar em:

1. Mapeamento dos componentes React para widgets LVGL
2. Identificação de gaps no backend para suportar todos os tipos
3. Plano de implementação priorizado por complexidade
4. Estimativas de memória e performance no ESP32

**Última atualização**: 17/08/2025