# Desenvolvimento - AutoCore Config App Frontend

## Visão Geral

Guia completo para desenvolvimento no frontend React/TypeScript do AutoCore Config App.

## Stack Tecnológica

### Core Technologies
- **React 18.2.0** - Biblioteca de UI com hooks modernos
- **TypeScript 5.2.2** - Tipagem estática para JavaScript
- **Vite 5.0.8** - Build tool rápida e moderna
- **TailwindCSS 3.3.6** - Framework CSS utility-first

### UI Components
- **shadcn/ui** - Componentes acessíveis baseados em Radix UI
- **Radix UI** - Primitivos de componentes sem estilo
- **Lucide React** - Ícones SVG otimizados
- **Class Variance Authority** - Gerenciamento de variantes

### State & Data
- **Sonner** - Sistema de notificações toast
- **React Markdown** - Renderização de markdown
- **Fetch API** - Cliente HTTP nativo

### Development Tools
- **ESLint** - Linting de código
- **Prettier** - Formatação automática
- **PostCSS** - Processamento CSS
- **Autoprefixer** - Prefixos CSS automáticos

## Arquitetura do Projeto

```
src/
├── components/                 # Componentes React
│   ├── ui/                    # Componentes shadcn/ui
│   ├── AutoCoreLogo.jsx       # Logo e branding
│   ├── ThemeSelector.jsx      # Seletor de temas
│   ├── HelpModal.jsx          # Sistema de ajuda
│   └── ...                    # Outros componentes
│
├── pages/                      # Páginas da aplicação
│   ├── DevicesPage.jsx        # Gerenciamento de dispositivos
│   ├── RelaysPage.jsx         # Configuração de relés
│   ├── ScreensPageV2.jsx      # Editor de telas
│   └── ...                    # Outras páginas
│
├── hooks/                      # Custom hooks
│   └── use-toast.js           # Hook de toast
│
├── lib/                        # Utilitários e configurações
│   ├── api.js                 # Cliente API centralizado
│   └── utils.js               # Funções utilitárias
│
├── services/                   # Serviços externos
│   └── mqttService.js         # Serviço MQTT
│
├── utils/                      # Utilitários específicos
│   ├── normalizers.js         # Normalização de dados
│   └── previewAdapter.js      # Adaptador de preview
│
├── types/                      # Definições TypeScript
│
├── App.jsx                     # Componente raiz
├── main.jsx                    # Entry point
└── index.css                   # Estilos globais
```

## Configurações

### Vite Configuration

```javascript
// vite.config.js
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const port = parseInt(env.VITE_PORT || '8080')
  const apiPort = parseInt(env.VITE_API_PORT || '8081')
  
  return {
    plugins: [react()],
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./src"),
      },
    },
    server: {
      port: port,
      host: true,
      proxy: {
        '/api': {
          target: `http://localhost:${apiPort}`,
          changeOrigin: true,
          secure: false,
        },
      },
    },
    build: {
      outDir: 'dist',
      sourcemap: true,
      rollupOptions: {
        output: {
          manualChunks: {
            vendor: ['react', 'react-dom'],
            ui: ['@radix-ui/react-slot', 'class-variance-authority']
          }
        }
      }
    }
  }
})
```

### TypeScript Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"]
}
```

### TailwindCSS Configuration

```javascript
// tailwind.config.js
module.exports = {
  darkMode: ["class"],
  content: [
    './pages/**/*.{js,jsx}',
    './components/**/*.{js,jsx}',
    './app/**/*.{js,jsx}',
    './src/**/*.{js,jsx}',
  ],
  theme: {
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        // ... outras cores
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
```

## Padrões de Desenvolvimento

### Estrutura de Componentes

```jsx
// Padrão para componentes funcionais
import React, { useState, useEffect, useCallback } from 'react'
import { ComponentIcon } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { toast } from 'sonner'
import api from '@/lib/api'

const ComponentName = ({ 
  // Props obrigatórias
  data,
  onAction,
  
  // Props opcionais com defaults
  title = 'Default Title',
  isVisible = true,
  className = ''
}) => {
  // Estado local
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  
  // Efeitos
  useEffect(() => {
    // Lógica de inicialização
  }, [])
  
  // Handlers
  const handleAction = useCallback(async () => {
    setLoading(true)
    try {
      await api.someAction()
      toast.success('Ação realizada!')
      onAction?.()
    } catch (err) {
      toast.error(api.getErrorMessage(err))
    } finally {
      setLoading(false)
    }
  }, [onAction])
  
  // Renderização condicional
  if (!isVisible) return null
  
  return (
    <div className={`component-container ${className}`}>
      {/* JSX do componente */}
    </div>
  )
}

export default ComponentName
```

### Naming Conventions

#### Componentes
```
✅ PascalCase: DeviceCard, RelayChannel, ScreenEditor
❌ camelCase: deviceCard, relayChannel
❌ kebab-case: device-card, relay-channel
```

#### Arquivos
```
✅ PascalCase para componentes: DeviceCard.jsx
✅ camelCase para utilitários: api.js, utils.js
✅ kebab-case para páginas: devices-page.jsx (opcional)
```

#### Props e Estados
```
✅ camelCase: isVisible, onUpdate, deviceData
✅ Boolean props: is/has/can + substantivo
✅ Event handlers: on + Verbo + Substantivo
```

### Gerenciamento de Estado

#### Estado Local
```jsx
// Para estado simples do componente
const [isOpen, setIsOpen] = useState(false)
const [data, setData] = useState(null)
const [loading, setLoading] = useState(false)
const [error, setError] = useState(null)
```

#### Estado Compartilhado
```jsx
// Para estado entre componentes próximos - via props
<ParentComponent>
  <ChildA data={sharedData} onUpdate={setSharedData} />
  <ChildB data={sharedData} onUpdate={setSharedData} />
</ParentComponent>

// Para estado global - Context API (se necessário)
const AppContext = createContext()
```

### Tratamento de Erros

```jsx
// Padrão consistente de error handling
const handleAsyncAction = async () => {
  setLoading(true)
  setError(null)
  
  try {
    const result = await api.performAction()
    setData(result)
    toast.success('Sucesso!')
  } catch (err) {
    const errorMessage = api.getErrorMessage(err)
    setError(errorMessage)
    toast.error('Erro', { description: errorMessage })
  } finally {
    setLoading(false)
  }
}
```

### Integração com API

```jsx
// Uso padrão do cliente API
import api from '@/lib/api'

const DevicesPage = () => {
  const [devices, setDevices] = useState([])
  
  useEffect(() => {
    const loadDevices = async () => {
      try {
        const data = await api.getDevices()
        setDevices(data)
      } catch (error) {
        toast.error('Erro ao carregar dispositivos')
      }
    }
    
    loadDevices()
  }, [])
  
  const handleCreateDevice = async (deviceData) => {
    try {
      const newDevice = await api.createDevice(deviceData)
      setDevices(prev => [...prev, newDevice])
      toast.success('Dispositivo criado!')
    } catch (error) {
      toast.error('Erro ao criar dispositivo')
    }
  }
  
  return (
    // JSX do componente
  )
}
```

## Sistema de Temas

### CSS Variables
```css
:root {
  --background: 0 0% 100%;
  --foreground: 240 10% 3.9%;
  --primary: 240 5.9% 10%;
  --primary-foreground: 0 0% 98%;
  --secondary: 240 4.8% 95.9%;
  --secondary-foreground: 240 5.9% 10%;
  /* ... outras variáveis */
}

.dark {
  --background: 240 10% 3.9%;
  --foreground: 0 0% 98%;
  --primary: 0 0% 98%;
  --primary-foreground: 240 5.9% 10%;
  /* ... variáveis dark */
}
```

### Uso em Componentes
```jsx
// Classes com suporte automático a temas
<div className="bg-background text-foreground border-border">
  <Button variant="default">Botão com tema</Button>
</div>
```

## Performance

### Otimizações Implementadas

1. **Code Splitting**
```javascript
// vite.config.js
output: {
  manualChunks: {
    vendor: ['react', 'react-dom'],
    ui: ['@radix-ui/react-slot', 'class-variance-authority']
  }
}
```

2. **Tree Shaking**
```jsx
// ✅ Import específico
import { Button } from '@/components/ui/button'

// ❌ Import genérico
import * as UI from '@/components/ui'
```

3. **Lazy Loading** (futuro)
```jsx
const DevicesPage = lazy(() => import('./pages/DevicesPage'))

<Suspense fallback={<LoadingSpinner />}>
  <DevicesPage />
</Suspense>
```

### Métricas Atuais
- **Bundle Size**: ~800KB (gzipped)
- **First Load**: <2s em 3G
- **Lighthouse Score**: 90+
- **Core Web Vitals**: Dentro dos parâmetros

## Scripts de Desenvolvimento

### Package.json Scripts
```json
{
  "scripts": {
    "dev": "vite",                    // Servidor de desenvolvimento
    "build": "vite build",           // Build de produção
    "preview": "vite preview",       // Preview do build
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "format": "prettier --write \"src/**/*.{js,jsx,ts,tsx,json,css,md}\""
  }
}
```

### Comandos Comuns
```bash
# Desenvolvimento
npm run dev              # Inicia servidor de desenvolvimento
npm run build           # Build para produção
npm run preview         # Preview do build

# Qualidade de código
npm run lint            # Verificar linting
npm run format          # Formatar código

# Análise
npm run build -- --analyze  # Analisar bundle size
```

## Debugging

### Development Tools
```javascript
// Em desenvolvimento, debug global
if (import.meta.env.DEV) {
  window.api = api
  window.debugApp = {
    components: () => document.querySelectorAll('[data-component]'),
    state: () => window.__REACT_DEVTOOLS_GLOBAL_HOOK__
  }
}
```

### Browser DevTools
- **React DevTools** - Inspecionar componentes
- **Vite DevTools** - Performance do build
- **Network Tab** - Monitorar API calls
- **Console** - Logs e erros

### Logs Estruturados
```javascript
// Padrão de logging
const logger = {
  info: (message, data) => {
    if (import.meta.env.DEV) {
      console.log(`🟢 [INFO] ${message}`, data)
    }
  },
  error: (message, error) => {
    console.error(`🔴 [ERROR] ${message}`, error)
  },
  warn: (message, data) => {
    console.warn(`🟡 [WARN] ${message}`, data)
  }
}
```

## Testing (Futuro)

### Setup de Testes
```bash
npm install --save-dev vitest @testing-library/react @testing-library/jest-dom
```

### Estrutura de Testes
```
src/
├── components/
│   ├── __tests__/
│   │   ├── DeviceCard.test.jsx
│   │   └── ThemeSelector.test.jsx
│   └── DeviceCard.jsx
└── __tests__/
    ├── setup.js
    └── utils.js
```

## Deploy

### Build de Produção
```bash
# Build otimizado
npm run build

# Verificar saída
ls -la dist/

# Testar localmente
npm run preview
```

### Variáveis de Ambiente
```bash
# .env.production
VITE_API_BASE_URL=https://api.autocore.local
VITE_API_PORT=443
VITE_ENVIRONMENT=production
```

## Roadmap de Desenvolvimento

### Implementações Atuais
- [x] React 18 com hooks modernos
- [x] TypeScript para type safety
- [x] Vite para build rápida
- [x] TailwindCSS para styling
- [x] shadcn/ui para componentes
- [x] Sistema de temas
- [x] Cliente API centralizado
- [x] Sistema de toast

### Próximas Features
- [ ] Sistema de testes automatizados
- [ ] Storybook para documentação visual
- [ ] PWA features
- [ ] Offline support
- [ ] Internacionalização (i18n)
- [ ] Real-time updates via WebSocket
- [ ] Performance monitoring
- [ ] Error boundary

## Links Relacionados

- [Getting Started](getting-started.md) - Como começar
- [Coding Standards](coding-standards.md) - Padrões de código
- [TypeScript Guide](typescript-guide.md) - Guia TypeScript
- [Testing Guide](testing-guide.md) - Guia de testes
- [Components](../components/README.md) - Documentação de componentes
- [API Integration](../api/README.md) - Integração com backend