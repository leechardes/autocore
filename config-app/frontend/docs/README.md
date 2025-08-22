# 📖 Documentação Frontend - AutoCore Config App

## 🎯 Visão Geral

Documentação completa do frontend React/TypeScript do AutoCore Config App, construído com Vite, shadcn/ui e TailwindCSS.

## 🛠️ Tecnologias

- **React 18** - Biblioteca de UI
- **TypeScript** - Tipagem estática
- **Vite** - Build tool e dev server
- **TailwindCSS** - Framework CSS utility-first
- **shadcn/ui** - Componentes UI acessíveis
- **Radix UI** - Primitivos de componentes
- **Lucide Icons** - Sistema de ícones
- **React Router** - Roteamento (implícito no App.jsx)
- **Sonner** - Sistema de notificações toast

## 📁 Estrutura da Documentação

```
docs/
├── README.md                    # Este arquivo
├── CHANGELOG.md                 # Histórico de mudanças
├── VERSION.md                   # Controle de versão
├── .doc-version                 # Versão da documentação
│
├── components/                  # Componentes React
│   ├── README.md               # Visão geral dos componentes
│   ├── ui-components.md        # Componentes shadcn/ui
│   ├── layout-components.md    # Componentes de layout
│   ├── form-components.md      # Componentes de formulário
│   └── shared-components.md    # Componentes compartilhados
│
├── hooks/                       # Custom hooks
│   ├── README.md               # Visão geral dos hooks
│   ├── data-hooks.md           # Hooks de dados/API
│   ├── ui-hooks.md             # Hooks de UI/UX
│   └── utility-hooks.md        # Hooks utilitários
│
├── state/                       # Gerenciamento de estado
│   ├── README.md               # Arquitetura de estado
│   ├── context-providers.md    # Context providers
│   ├── stores.md               # Stores locais
│   └── actions.md              # Actions e reducers
│
├── api/                         # Integração com backend
│   ├── README.md               # Visão geral da API
│   ├── endpoints.md            # Endpoints disponíveis
│   ├── websocket.md            # WebSocket/MQTT
│   └── error-handling.md       # Tratamento de erros
│
├── architecture/                # Arquitetura do sistema
│   ├── README.md               # Visão arquitetural
│   ├── component-hierarchy.md  # Hierarquia de componentes
│   ├── data-flow.md            # Fluxo de dados
│   └── routing-structure.md    # Estrutura de rotas
│
├── styling/                     # Sistema de estilos
│   ├── README.md               # Visão geral dos estilos
│   ├── theme-system.md         # Sistema de temas
│   ├── css-modules.md          # Módulos CSS/TailwindCSS
│   └── responsive-design.md    # Design responsivo
│
├── deployment/                  # Deploy e build
│   ├── README.md               # Visão geral do deploy
│   ├── vite-config.md          # Configuração Vite
│   ├── docker-setup.md         # Configuração Docker
│   └── nginx-config.md         # Configuração Nginx
│
├── development/                 # Desenvolvimento
│   ├── README.md               # Guia de desenvolvimento
│   ├── getting-started.md      # Como começar
│   ├── coding-standards.md     # Padrões de código
│   ├── typescript-guide.md     # Guia TypeScript
│   └── testing-guide.md        # Guia de testes
│
├── security/                    # Segurança
│   ├── README.md               # Visão geral de segurança
│   ├── authentication.md       # Autenticação
│   ├── csrf-protection.md      # Proteção CSRF
│   └── xss-prevention.md       # Prevenção XSS
│
├── troubleshooting/             # Solução de problemas
│   ├── README.md               # Guia de troubleshooting
│   ├── common-errors.md        # Erros comuns
│   ├── performance-issues.md   # Problemas de performance
│   └── build-problems.md       # Problemas de build
│
├── templates/                   # Templates de código
│   ├── component-template.tsx  # Template de componente
│   ├── hook-template.ts        # Template de hook
│   ├── test-template.spec.tsx  # Template de teste
│   └── story-template.stories.tsx # Template Storybook
│
└── agents/                      # Sistema de agentes
    ├── README.md               # Visão geral dos agentes
    ├── dashboard.md            # Dashboard de agentes
    ├── active-agents/          # Agentes ativos
    ├── logs/                   # Logs dos agentes
    ├── checkpoints/            # Checkpoints de progresso
    └── metrics/                # Métricas de performance
```

## 🚀 Início Rápido

### Lendo a Documentação

1. **Novo no projeto?** Comece com [development/getting-started.md](development/getting-started.md)
2. **Desenvolvendo componentes?** Veja [components/README.md](components/README.md)
3. **Trabalhando com dados?** Consulte [hooks/data-hooks.md](hooks/data-hooks.md)
4. **Problemas?** Acesse [troubleshooting/README.md](troubleshooting/README.md)

### Navegação Rápida

| Tópico | Link Direto |
|--------|-------------|
| Componentes UI | [ui-components.md](components/ui-components.md) |
| Custom Hooks | [hooks/README.md](hooks/README.md) |
| API Integration | [api/README.md](api/README.md) |
| Styling Guide | [styling/README.md](styling/README.md) |
| Deploy Guide | [deployment/README.md](deployment/README.md) |

## 📊 Estatísticas do Projeto

- **Componentes React**: 35+ componentes catalogados
- **Custom Hooks**: 8+ hooks documentados
- **Páginas**: 10+ páginas principais
- **Cobertura de Testes**: Em implementação
- **Componentes shadcn/ui**: 15+ componentes

## 🤖 Sistema de Agentes

O projeto inclui um sistema de agentes automatizados para:

- **A01-component-generator**: Gera novos componentes
- **A02-hook-creator**: Cria custom hooks
- **A03-test-writer**: Escreve testes automatizados
- **A04-performance-optimizer**: Otimiza performance

## 📝 Contribuindo

1. **Atualizando documentação**: Edite os arquivos .md relevantes
2. **Novos componentes**: Use os templates em `templates/`
3. **Reportando problemas**: Use `troubleshooting/common-errors.md`
4. **Sugestões**: Crie issues no repositório

## 🔗 Links Relacionados

- [Backend Documentation](../../backend/docs/README.md)
- [App Flutter Documentation](../../app-flutter/docs/README.md)
- [Sistema Gateway](../../gateway/README.md)

---

**Versão da Documentação**: 1.0.0  
**Última Atualização**: 22 de Agosto de 2025  
**Mantido por**: Equipe AutoCore
