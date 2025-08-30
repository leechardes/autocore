# 🎨 A12-THEME-SYSTEM-FIXER - Corretor do Sistema de Temas

## 📋 Objetivo

Agente autônomo para implementar um sistema de temas unificado no frontend React, corrigindo o problema do tema escuro e garantindo que siga o padrão do sistema operacional.

## 🎯 Missão

Criar um ThemeProvider centralizado que unifique controle de dark/light mode com seleção de cores, detecte preferências do sistema e persista configurações do usuário.

## ⚙️ Configuração

```yaml
tipo: implementation
prioridade: urgente
autônomo: true
projeto: config-app/frontend
prerequisito: A11-THEME-VEHICLE-DEBUGGER executado
output: docs/agents/executed/A12-THEME-FIX-[DATA].md
```

## 🔄 Fluxo de Implementação

### Fase 1: Criar ThemeProvider (20%)
1. Criar `src/providers/theme-provider.jsx`
2. Implementar contexto de tema unificado
3. Integrar dark/light + cores + radius
4. Detectar preferência do sistema
5. Persistir no localStorage

### Fase 2: Criar Hook useTheme (35%)
1. Criar `src/hooks/use-theme.js`
2. Expor funções de controle
3. Sincronizar com localStorage
4. Aplicar classes no document.documentElement
5. Gerenciar variáveis CSS

### Fase 3: Atualizar App.jsx (50%)
1. Importar ThemeProvider
2. Envolver aplicação com provider
3. Remover lógica de tema antiga
4. Manter estrutura de rotas

### Fase 4: Criar Theme Toggle (65%)
1. Criar `src/components/theme-toggle.jsx`
2. Botão com ícones sun/moon/system
3. Menu dropdown para opções
4. Integrar com useTheme

### Fase 5: Atualizar Header (80%)
1. Adicionar ThemeToggle ao header
2. Posicionar corretamente
3. Estilizar com shadcn/ui
4. Testar responsividade

### Fase 6: Validação (100%)
1. Testar dark/light mode
2. Verificar persistência
3. Testar detecção do sistema
4. Validar em diferentes páginas
5. Gerar relatório

## 📝 Implementações

### ThemeProvider.jsx
```jsx
import * as React from "react"

const ThemeProviderContext = React.createContext({
  theme: "system",
  setTheme: () => null,
})

export function ThemeProvider({
  children,
  defaultTheme = "system",
  storageKey = "vite-ui-theme",
  ...props
}) {
  const [theme, setTheme] = React.useState(
    () => localStorage.getItem(storageKey) || defaultTheme
  )

  React.useEffect(() => {
    const root = window.document.documentElement
    root.classList.remove("light", "dark")

    if (theme === "system") {
      const systemTheme = window.matchMedia("(prefers-color-scheme: dark)")
        .matches
        ? "dark"
        : "light"
      root.classList.add(systemTheme)
      return
    }

    root.classList.add(theme)
  }, [theme])

  const value = {
    theme,
    setTheme: (theme) => {
      localStorage.setItem(storageKey, theme)
      setTheme(theme)
    },
  }

  return (
    <ThemeProviderContext.Provider {...props} value={value}>
      {children}
    </ThemeProviderContext.Provider>
  )
}

export const useTheme = () => {
  const context = React.useContext(ThemeProviderContext)
  if (context === undefined)
    throw new Error("useTheme must be used within a ThemeProvider")
  return context
}
```

### use-theme.js (Hook)
```javascript
import { useContext } from 'react'
import { ThemeProviderContext } from '@/providers/theme-provider'

export function useTheme() {
  const context = useContext(ThemeProviderContext)
  
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider')
  }
  
  return context
}
```

### ThemeToggle.jsx
```jsx
import * as React from "react"
import { Moon, Sun, Monitor } from "lucide-react"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { useTheme } from "@/hooks/use-theme"

export function ThemeToggle() {
  const { theme, setTheme } = useTheme()
  
  const getIcon = () => {
    if (theme === 'dark') return <Moon className="h-5 w-5" />
    if (theme === 'light') return <Sun className="h-5 w-5" />
    return <Monitor className="h-5 w-5" />
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="outline" size="icon">
          {getIcon()}
          <span className="sr-only">Toggle theme</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem onClick={() => setTheme("light")}>
          <Sun className="mr-2 h-4 w-4" />
          <span>Light</span>
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => setTheme("dark")}>
          <Moon className="mr-2 h-4 w-4" />
          <span>Dark</span>
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => setTheme("system")}>
          <Monitor className="mr-2 h-4 w-4" />
          <span>System</span>
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
```

### App.jsx (Atualizado)
```jsx
import { ThemeProvider } from "@/providers/theme-provider"
import { BrowserRouter } from "react-router-dom"
// ... outros imports

function App() {
  return (
    <ThemeProvider defaultTheme="system" storageKey="autocore-theme">
      <BrowserRouter>
        {/* Resto da aplicação */}
      </BrowserRouter>
    </ThemeProvider>
  )
}
```

## 🎨 Configuração Tailwind

### tailwind.config.js
```javascript
module.exports = {
  darkMode: ["class"],
  content: [
    "./index.html",
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      // Configurações do tema
    },
  },
  plugins: [],
}
```

## 🔧 Verificações CSS

### index.css (Variáveis)
```css
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;
    --radius: 0.5rem;
  }
 
  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 212.7 26.8% 83.9%;
  }
}
```

## 🔍 Detecção do Sistema

```javascript
// Detectar mudanças na preferência do sistema
React.useEffect(() => {
  const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
  
  const handleChange = () => {
    if (theme === 'system') {
      const root = window.document.documentElement
      root.classList.remove('light', 'dark')
      root.classList.add(mediaQuery.matches ? 'dark' : 'light')
    }
  }
  
  mediaQuery.addEventListener('change', handleChange)
  return () => mediaQuery.removeEventListener('change', handleChange)
}, [theme])
```

## ✅ Checklist de Implementação

- [ ] ThemeProvider criado e funcional
- [ ] Hook useTheme implementado
- [ ] App.jsx envolvido com provider
- [ ] ThemeToggle componente criado
- [ ] Header atualizado com toggle
- [ ] localStorage persistindo tema
- [ ] Detecção do sistema funcionando
- [ ] Classes dark aplicadas corretamente
- [ ] Variáveis CSS funcionando
- [ ] Teste em todas as páginas

## 🧪 Testes de Validação

1. **Teste Manual do Tema**
   - Clicar no toggle e verificar mudança
   - Recarregar página e verificar persistência
   - Mudar tema do sistema e verificar detecção

2. **Verificação no Console**
   ```javascript
   // Verificar localStorage
   localStorage.getItem('autocore-theme')
   
   // Verificar classes
   document.documentElement.classList
   
   // Verificar contexto (React DevTools)
   // ThemeProvider > value > theme
   ```

3. **Teste de Páginas**
   - Dashboard
   - Devices
   - Relays
   - Screens
   - Vehicle
   - Settings

## 📊 Output Esperado

Arquivo `A12-THEME-FIX-[DATA].md` contendo:
1. Arquivos criados/modificados
2. Funcionalidades implementadas
3. Testes realizados
4. Screenshots do antes/depois
5. Validação de persistência
6. Confirmação de detecção do sistema

## 🚀 Resultado Final

- Sistema de temas unificado e funcional
- Dark mode seguindo padrão do sistema
- Persistência de preferências
- Toggle acessível no header
- Todas as páginas respeitando tema
- Código limpo e manutenível

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/01/2025  
**Tipo**: Implementation & Fix