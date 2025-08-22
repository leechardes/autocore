# Componentes React - AutoCore Config App

## Visão Geral

Esta seção documenta todos os componentes React utilizados no AutoCore Config App. Os componentes estão organizados por categoria e incluem tanto componentes customizados quanto componentes do shadcn/ui.

## Arquitetura de Componentes

```
src/components/
├── ui/                          # Componentes shadcn/ui
│   ├── button.jsx              # Botão base
│   ├── card.jsx                # Card container
│   ├── dialog.jsx              # Modal/Dialog
│   ├── input.jsx               # Input de texto
│   ├── select.jsx              # Dropdown select
│   ├── switch.jsx              # Toggle switch
│   ├── tabs.jsx                # Sistema de abas
│   ├── table.jsx               # Tabelas
│   ├── toast.jsx               # Notificações
│   └── ...                     # Outros componentes UI
│
├── AutoCoreLogo.jsx            # Logo e branding
├── ThemeSelector.jsx           # Seletor de temas
├── HelpModal.jsx               # Modal de ajuda
├── HelpButton.jsx              # Botão de ajuda
├── ScreenItemsManager.jsx      # Gerenciador de itens de tela
├── ScreenPreview.jsx           # Preview de telas
├── MacroActionEditor.jsx       # Editor de ações de macro
└── ...
```

## Categorias de Componentes

### 1. Componentes de Layout
- **App.jsx** - Componente raiz da aplicação
- **Sidebar Navigation** - Navegação lateral
- **Header** - Cabeçalho das páginas

### 2. Componentes de UI Base (shadcn/ui)
- **Button** - Botões reutilizáveis
- **Card** - Containers de conteúdo
- **Dialog** - Modais e dialogs
- **Input, Select** - Elementos de formulário
- **Toast** - Sistema de notificações

### 3. Componentes Específicos do AutoCore
- **AutoCoreLogo** - Branding e identidade visual
- **ThemeSelector** - Alternador de temas
- **HelpModal** - Sistema de ajuda contextual
- **ScreenItemsManager** - Editor de elementos de tela
- **ScreenPreview** - Visualização de telas ESP32

### 4. Componentes de Página
- **DevicesPage** - Gerenciamento de dispositivos
- **RelaysPage** - Configuração de relés
- **ScreensPageV2** - Editor de telas
- **MQTTMonitorPage** - Monitor MQTT
- **MacrosPage** - Sistema de macros

## Padrões de Desenvolvimento

### Estrutura Padrão de Componente

```jsx
import React, { useState, useEffect } from 'react'
import { ComponentIcon } from 'lucide-react'
import { Button } from '@/components/ui/button'
import api from '@/lib/api'

const ComponentName = ({ prop1, prop2, onAction }) => {
  // State management
  const [localState, setLocalState] = useState(initialValue)
  const [loading, setLoading] = useState(false)
  
  // Effects
  useEffect(() => {
    // Initialization logic
  }, [])
  
  // Event handlers
  const handleAction = async () => {
    setLoading(true)
    try {
      await api.someAction()
      onAction?.()
    } catch (error) {
      console.error('Error:', error)
    } finally {
      setLoading(false)
    }
  }
  
  return (
    <div className="component-container">
      {/* Component JSX */}
    </div>
  )
}

export default ComponentName
```

### Conventions de Naming

- **Componentes**: PascalCase (ex: `DeviceCard`)
- **Props**: camelCase (ex: `isVisible`, `onUpdate`)
- **Event Handlers**: `handle` prefix (ex: `handleClick`, `handleSubmit`)
- **State**: descriptive names (ex: `isLoading`, `selectedDevice`)

### Props Pattern

```jsx
const ComponentName = ({ 
  // Required props
  data,
  onAction,
  
  // Optional props with defaults
  title = 'Default Title',
  isVisible = true,
  variant = 'default',
  
  // Event handlers
  onClick,
  onUpdate,
  
  // Style props
  className = '',
  ...rest 
}) => {
  // Component implementation
}
```

## Integração com Sistemas

### API Integration

Todos os componentes que fazem chamadas à API seguem o padrão:

```jsx
import api from '@/lib/api'

// Inside component
const fetchData = async () => {
  try {
    setLoading(true)
    const data = await api.getData()
    setData(data)
  } catch (error) {
    console.error('Error fetching data:', error)
    // Show error toast
  } finally {
    setLoading(false)
  }
}
```

### Theme Integration

Todos os componentes suportam temas através do TailwindCSS:

```jsx
// Dark mode classes são aplicadas automaticamente
<div className="bg-background text-foreground border-border">
  {/* Conteúdo com tema aplicado */}
</div>
```

### Toast Notifications

```jsx
import { toast } from 'sonner'

// Success notification
toast.success('Ação realizada com sucesso!')

// Error notification
toast.error('Erro ao realizar ação')

// Custom toast
toast('Mensagem personalizada', {
  description: 'Descrição adicional',
  duration: 4000
})
```

## Componentes Principais

### App.jsx
**Propósito**: Componente raiz que gerencia estado global e navegação

**Features**:
- Sistema de navegação single-page
- Gerenciamento de tema global
- Loading states
- Sistema de notificações
- Layout responsivo

**Props**: Nenhuma (componente raiz)

### ThemeSelector.jsx
**Propósito**: Permite alternar entre temas visuais

**Features**:
- Múltiplos temas (light, dark, auto)
- Persistência em localStorage
- Preview instantâneo

**Props**: Nenhuma (uso global)

### HelpModal.jsx
**Propósito**: Sistema de ajuda contextual por página

**Features**:
- Conteúdo dinâmico por página
- Markdown rendering
- Navegação entre seções

**Props**: `currentPage` (string)

## Métricas dos Componentes

| Categoria | Quantidade | Status |
|-----------|------------|--------|
| UI Base (shadcn/ui) | 15+ | ✅ Documentado |
| Componentes Customizados | 8+ | ✅ Documentado |
| Páginas | 10+ | ✅ Documentado |
| Hooks Customizados | 8+ | 🔄 Em progresso |

## Links Relacionados

- [Componentes UI](ui-components.md) - Documentação detalhada dos componentes shadcn/ui
- [Componentes de Layout](layout-components.md) - Documentação de layout e navegação
- [Componentes de Formulário](form-components.md) - Inputs, selects e validação
- [Componentes Compartilhados](shared-components.md) - Componentes reutilizáveis
- [Hooks](../hooks/README.md) - Custom hooks utilizados
- [API Integration](../api/README.md) - Integração com backend
