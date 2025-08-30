# 🔍 A11-THEME-VEHICLE-DEBUGGER - Debugger de Tema e Tela Branca

## 📋 Objetivo

Agente autônomo para diagnosticar e identificar problemas relacionados ao tema escuro não funcionando e tela branca ao clicar em cadastrar veículo no frontend React.

## 🎯 Missão

Investigar sistematicamente o sistema de temas, componentes de veículo e identificar as causas dos problemas reportados.

## ⚙️ Configuração

```yaml
tipo: diagnostic
prioridade: urgente
autônomo: true
projeto: config-app/frontend
output: docs/agents/executed/A11-THEME-DEBUG-[DATA].md
```

## 🔄 Fluxo de Diagnóstico

### Fase 1: Análise do Sistema de Temas (20%)
1. Verificar como o tema está configurado no projeto
2. Checar se existe ThemeProvider
3. Verificar localStorage para persistência de tema
4. Analisar classes dark mode do Tailwind
5. Verificar tailwind.config.js

### Fase 2: Verificar Componentes Base (40%)
1. Analisar App.jsx para provider de tema
2. Verificar index.html para classe dark
3. Checar main.jsx para inicialização
4. Verificar index.css para variáveis CSS
5. Analisar componentes ui/ do shadcn

### Fase 3: Diagnóstico da Tela Veículo (60%)
1. Verificar VehicleManager.jsx
2. Analisar VehicleForm.jsx
3. Checar imports e dependências
4. Verificar se componentes estão usando classes corretas
5. Identificar onde ocorre a tela branca

### Fase 4: Verificar Integração shadcn/ui (80%)
1. Checar se components.json está correto
2. Verificar se theme provider está implementado
3. Analisar se componentes ui/ respeitam tema
4. Verificar variáveis CSS em index.css

### Fase 5: Gerar Relatório (100%)
1. Listar todos os problemas encontrados
2. Identificar causas raiz
3. Propor soluções específicas
4. Criar checklist de correções

## 🔍 Pontos de Verificação

### Sistema de Temas
```javascript
// Verificar se existe:
// 1. ThemeProvider component
// 2. useTheme hook
// 3. Theme toggle button
// 4. localStorage.getItem('theme')
// 5. document.documentElement.classList (dark)
```

### Tailwind Config
```javascript
// tailwind.config.js deve ter:
module.exports = {
  darkMode: ['class'],  // ou 'media'
  // ...
}
```

### Variáveis CSS
```css
/* index.css deve ter variáveis para dark mode */
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  /* ... */
}

.dark {
  --background: 222.2 84% 4.9%;
  --foreground: 210 40% 98%;
  /* ... */
}
```

### VehicleForm Debug
```javascript
// Verificar:
// 1. Imports corretos dos componentes
// 2. Se está retornando JSX válido
// 3. Se não há erros de console
// 4. Se o estado isEditing está funcionando
// 5. Se componentes ui/ estão importados
```

## 🐛 Problemas Comuns

### Tema Escuro Não Funciona
1. **Falta ThemeProvider** - Componente não implementado
2. **darkMode incorreto** - Tailwind mal configurado
3. **Variáveis CSS faltando** - index.css incompleto
4. **localStorage quebrado** - Persistência com erro
5. **Classe dark não aplicada** - document.documentElement sem classe

### Tela Branca em Veículo
1. **Import erro** - Componente não encontrado
2. **Erro de renderização** - JSX inválido
3. **Estado quebrado** - Store com problema
4. **Componente faltando** - VehicleForm não existe/erro
5. **CSS conflito** - Classes sobrescrevendo

## 📝 Checklist de Diagnóstico

### Tema
- [ ] Existe arquivo theme-provider.jsx?
- [ ] Existe botão de toggle de tema?
- [ ] tailwind.config.js tem darkMode: ['class']?
- [ ] index.css tem variáveis para .dark?
- [ ] localStorage salva preferência?
- [ ] document.documentElement recebe classe dark?

### Veículo
- [ ] VehicleManager.jsx renderiza corretamente?
- [ ] VehicleForm.jsx existe e está correto?
- [ ] Imports de componentes ui/ funcionam?
- [ ] Console mostra erros?
- [ ] Estado isEditing funciona?
- [ ] Store vehicleStore está ok?

## 🔧 Comandos de Debug

```bash
# Verificar erros no console do navegador
# F12 > Console

# Verificar localStorage
localStorage.getItem('theme')
localStorage.getItem('vite-ui-theme')

# Verificar classe dark
document.documentElement.classList

# Verificar componentes React
# React DevTools Extension

# Verificar network
# F12 > Network (ver 404s)
```

## 📊 Output Esperado

Relatório `A11-THEME-DEBUG-[DATA].md` contendo:

### 1. Diagnóstico do Tema
- Status atual do sistema de temas
- Componentes faltando
- Configurações incorretas
- Solução proposta

### 2. Diagnóstico da Tela Branca
- Componente causador
- Erro específico
- Stack trace se houver
- Solução proposta

### 3. Plano de Correção
- Lista ordenada de fixes
- Código específico a implementar
- Arquivos a criar/modificar
- Testes a realizar

## 🚑 Soluções Rápidas

### Fix Tema Escuro
```jsx
// 1. Criar theme-provider.jsx
// 2. Wrap App com ThemeProvider
// 3. Adicionar toggle button
// 4. Configurar tailwind.config.js
// 5. Adicionar variáveis CSS
```

### Fix Tela Branca
```jsx
// 1. Verificar imports
// 2. Adicionar error boundary
// 3. Debug estado
// 4. Verificar componentes ui/
// 5. Adicionar fallbacks
```

## ✅ Resultado Esperado

Após executar este agente:
1. **Problemas identificados** com precisão
2. **Causas raiz** determinadas
3. **Soluções específicas** propostas
4. **Plano de ação** claro para correções

---

**Versão**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 28/01/2025  
**Tipo**: Diagnostic & Debug