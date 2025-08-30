# 🏗️ Architecture - Frontend AutoCore

## 🎯 Visão Geral
Arquitetura do frontend React/TypeScript do AutoCore Config App, seguindo princípios modernos de desenvolvimento web.

## 📐 Arquitetura Geral

```
┌─────────────────────────────────────────────────────────────┐
│                    Browser (Cliente)                        │
├─────────────────────────────────────────────────────────────┤
│  React App (SPA)                                           │
│  ├── Components (UI)                                       │
│  ├── Pages (Routes)                                        │
│  ├── Hooks (Logic)                                         │
│  ├── Services (API)                                        │
│  └── Utils (Helpers)                                       │
├─────────────────────────────────────────────────────────────┤
│  HTTP/WebSocket                                            │
├─────────────────────────────────────────────────────────────┤
│  Backend API (FastAPI)                                     │
│  ├── REST Endpoints                                        │
│  ├── WebSocket (real-time)                                 │
│  └── MQTT Bridge                                           │
├─────────────────────────────────────────────────────────────┤
│  MQTT Broker                                               │
├─────────────────────────────────────────────────────────────┤
│  ESP32 Devices                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🗂️ Estrutura de Diretórios

```
src/
├── components/           # Componentes React
│   ├── ui/              # Componentes base (shadcn/ui)
│   ├── layout/          # Componentes de layout
│   └── modules/         # Componentes específicos do domínio
├── pages/               # Páginas/Rotas principais
├── hooks/               # Custom React hooks
├── services/            # Camada de serviços (API, MQTT)
├── utils/               # Funções utilitárias
├── types/               # Definições TypeScript
├── config/              # Configurações da aplicação
└── lib/                 # Bibliotecas e helpers
```

## 🧩 Camadas da Aplicação

### 1. Presentation Layer (UI)
- **Responsabilidade**: Renderização e interação do usuário
- **Tecnologias**: React 18, shadcn/ui, TailwindCSS
- **Componentes**:
  - `components/ui/` - Componentes primitivos
  - `components/layout/` - Layout containers
  - `components/modules/` - Componentes de negócio

### 2. State Management Layer
- **Responsabilidade**: Gerenciamento de estado da aplicação
- **Padrões**:
  - React Context para estado global
  - useState/useReducer para estado local
  - Custom hooks para lógica compartilhada

### 3. Business Logic Layer
- **Responsabilidade**: Regras de negócio e lógica da aplicação
- **Implementação**:
  - Custom hooks (`hooks/`)
  - Service classes (`services/`)
  - Utility functions (`utils/`)

### 4. Data Access Layer
- **Responsabilidade**: Comunicação com backend e dados
- **Tecnologias**: Axios, WebSocket, EventSource
- **Implementação**:
  - `services/api.js` - REST API calls
  - `services/mqttService.js` - MQTT communication
  - Custom hooks para data fetching

## 🔄 Fluxo de Dados

### Unidirecional Data Flow
```
User Action → Event Handler → Service Call → State Update → UI Re-render
```

### Data Fetching Pattern
```
Component Mount → Custom Hook → Service Call → Cache/State → Render
```

### Real-time Updates
```
MQTT Message → Service → Event Emission → Hook Listener → State Update → UI
```

## 🎣 Custom Hooks Architecture

### Data Hooks
- `useDevices()` - Gerencia estado de dispositivos
- `useRelays()` - Controle de relés
- `useMacros()` - Gestão de macros
- `useThemes()` - Temas e customização

### UI Hooks
- `useModal()` - Controle de modais
- `useToast()` - Sistema de notificações
- `useLocalStorage()` - Persistência local
- `useDebounce()` - Debounce de inputs

### Service Hooks
- `useApi()` - HTTP requests
- `useMqtt()` - MQTT communication
- `useWebSocket()` - WebSocket real-time

## 🎨 Component Architecture

### Atomic Design Principles
```
Atoms (ui/) → Molecules (layout/) → Organisms (modules/) → Pages
```

### Component Types
1. **Pure Components**: Apenas renderização, sem estado
2. **Container Components**: Gerenciam estado e lógica
3. **Higher-Order Components**: Composição e reutilização
4. **Render Props**: Compartilhamento de lógica

### Component Structure
```typescript
// ComponentName.jsx
import { useState, useEffect } from 'react'
import { ComponentProps } from './types'

interface ComponentNameProps extends ComponentProps {
  // Props específicas
}

export function ComponentName({ prop1, prop2 }: ComponentNameProps) {
  // Hooks e estado local
  // Event handlers
  // Render
}
```

## 🛡️ Error Boundaries

### Error Handling Strategy
```
Page Level → Component Level → Hook Level → Service Level
```

### Implementation
- React Error Boundaries para crashes
- Try-catch em async operations
- Fallback UI para componentes críticos
- Error logging e reporting

## 📱 Responsive Design

### Breakpoint System (Tailwind)
- `sm`: 640px - Tablet portrait
- `md`: 768px - Tablet landscape
- `lg`: 1024px - Desktop
- `xl`: 1280px - Large desktop
- `2xl`: 1536px - Extra large

### Mobile-First Approach
```css
/* Base: Mobile */
.component { /* mobile styles */ }

/* Tablet and up */
@screen sm { .component { /* tablet styles */ } }

/* Desktop and up */
@screen lg { .component { /* desktop styles */ } }
```

## ⚡ Performance Strategies

### Code Splitting
- Route-based splitting com React.lazy
- Component-based splitting para componentes pesados
- Dynamic imports para bibliotecas grandes

### Memoization
- React.memo para componentes puros
- useMemo para cálculos custosos
- useCallback para event handlers

### Bundle Optimization
- Tree shaking automático (Vite)
- Dead code elimination
- Asset optimization (images, fonts)

## 🔐 Security Architecture

### Client-Side Security
- JWT token storage em httpOnly cookies
- CSRF protection
- XSS prevention (sanitização)
- Input validation

### API Communication
- HTTPS only
- Request/response interceptors
- Rate limiting awareness
- Error message sanitization

## 🧪 Testing Architecture

### Testing Pyramid
```
E2E Tests (Cypress)
├── Integration Tests (React Testing Library)
├── Component Tests (Jest + RTL)
└── Unit Tests (Jest)
```

### Testing Patterns
- Component testing com render + screen
- Custom hook testing com renderHook
- API mocking com MSW
- User interaction testing

## 🚀 Build & Deploy

### Build Process (Vite)
```
Source Code → TypeScript Check → Bundle → Optimize → Static Files
```

### Environment Management
- `.env.local` - Development
- `.env.staging` - Staging
- `.env.production` - Production

### Deployment Targets
- Static hosting (Nginx)
- CDN distribution
- Docker containers

## 📊 Monitoring & Analytics

### Performance Monitoring
- Core Web Vitals tracking
- Bundle size monitoring
- Runtime performance metrics

### Error Tracking
- Error boundaries logging
- API error tracking
- User action logging

### User Analytics
- Page view tracking
- Feature usage analytics
- User flow analysis

---

**Status**: Documentação completa ✅  
**Última atualização**: 2025-01-28  
**Responsável**: Arquiteto Frontend