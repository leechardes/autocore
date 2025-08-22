# Sistema de Agentes Frontend - AutoCore Config App

## Visão Geral

Sistema de agentes automatizados para desenvolvimento, otimização e manutenção do frontend React/TypeScript. Cada agente tem uma responsabilidade específica e opera de forma autônoma.

## Arquitetura dos Agentes

```
Sistema de Agentes Frontend
┌───────────────────────────────────────────┐
│ Dashboard de Controle                            │
│ ┌───────────────────────────────────────┐ │
│ │ Metrics | Logs | Checkpoints | Config     │ │
│ └───────────────────────────────────────┘ │
└───────────────────────────────────────────┘
                    │
    ┌─────────────┼───────────────┐
    │             │                │
┌───┴───┐   ┌───┴───┐   ┌───┴───┐   ┌───┴───┐
│ A01   │   │ A02   │   │ A03   │   │ A04   │
│ Comp  │   │ Hook  │   │ Test  │   │ Perf  │
│ Gen   │   │ Crt   │   │ Wrt   │   │ Opt   │
└───────┘   └───────┘   └───────┘   └───────┘
```

## Agentes Ativos

### A01 - Component Generator
**Propósito**: Gerar novos componentes React com template padrão
**Status**: ✅ Ativo
**Localização**: `docs/agents/active-agents/A01-component-generator/`

**Funcionalidades**:
- Gerar componentes com template TypeScript
- Aplicar padrões de naming AutoCore
- Integrar com shadcn/ui automaticamente
- Criar props interfaces
- Adicionar error handling
- Gerar documentação inline

**Comando**:
```bash
npm run agent:component -- --name="DeviceCard" --type="display"
```

### A02 - Hook Creator
**Propósito**: Criar custom hooks com padrões AutoCore
**Status**: ✅ Ativo
**Localização**: `docs/agents/active-agents/A02-hook-creator/`

**Funcionalidades**:
- Gerar hooks com template TypeScript
- Integração automática com API
- Error handling e loading states
- Cache e otimizações
- Documentação JSDoc
- Testes unitários básicos

**Comando**:
```bash
npm run agent:hook -- --name="useDevices" --endpoint="/devices"
```

### A03 - Test Writer
**Propósito**: Escrever testes automatizados para componentes e hooks
**Status**: ✅ Ativo
**Localização**: `docs/agents/active-agents/A03-test-writer/`

**Funcionalidades**:
- Gerar testes Jest/Testing Library
- Cobertura de casos principais
- Mocks para API calls
- Testes de acessibilidade
- Testes de integração
- Snapshot testing

**Comando**:
```bash
npm run agent:test -- --target="DeviceCard" --type="component"
```

### A04 - Performance Optimizer
**Propósito**: Otimizar performance do bundle e componentes
**Status**: ✅ Ativo
**Localização**: `docs/agents/active-agents/A04-performance-optimizer/`

**Funcionalidades**:
- Analisar bundle size
- Identificar componentes pesados
- Sugerir lazy loading
- Otimizar imports
- Code splitting automático
- Métricas de performance

**Comando**:
```bash
npm run agent:optimize -- --analyze --fix
```

## Sistema de Logs

### Estrutura de Logs

```
logs/
├── 2025-08-22/                    # Por data
│   ├── A01-component-generator.log
│   ├── A02-hook-creator.log
│   ├── A03-test-writer.log
│   └── A04-performance-optimizer.log
├── agent-activity.log             # Log geral
├── errors.log                     # Erros consolidados
└── metrics.json                   # Métricas diárias
```

### Formato de Log

```
[2025-08-22 14:30:15] 🚀 [A01] Iniciando geração de componente
[2025-08-22 14:30:16] 🔄 [A01] Analisando template base
[2025-08-22 14:30:17] ✅ [A01] Template aplicado: ComponentName.tsx
[2025-08-22 14:30:18] 📊 [A01] Métrica: 156 linhas geradas em 3.2s
[2025-08-22 14:30:19] ✅ [A01] CONCLUÍDO - Componente criado com sucesso
```

## Sistema de Checkpoints

### Estrutura

```json
// checkpoints/A01-component-generator-2025-08-22.json
{
  "agentId": "A01",
  "date": "2025-08-22",
  "executions": 12,
  "successRate": 0.95,
  "avgDuration": 4.2,
  "lastExecution": "2025-08-22T14:30:19Z",
  "components": [
    {
      "name": "DeviceCard",
      "timestamp": "2025-08-22T14:30:19Z",
      "duration": 3.2,
      "linesGenerated": 156,
      "status": "success"
    }
  ],
  "metrics": {
    "totalLines": 1847,
    "totalFiles": 12,
    "errorRate": 0.05
  }
}
```

## Sistema de Métricas

### Métricas por Agente

| Agente | Execuções | Taxa Sucesso | Tempo Médio | Última Execução |
|--------|-------------|--------------|-------------|------------------|
| A01    | 45          | 96%          | 4.2s        | 22/08 14:30     |
| A02    | 23          | 98%          | 2.8s        | 22/08 13:15     |
| A03    | 67          | 89%          | 12.4s       | 22/08 14:45     |
| A04    | 8           | 100%         | 45.2s       | 22/08 12:00     |

### Métricas Globais

```json
{
  "totalExecutions": 143,
  "globalSuccessRate": 0.94,
  "totalFilesGenerated": 89,
  "totalLinesOfCode": 12847,
  "totalTestsCovered": 67,
  "averageResponseTime": 8.7,
  "uptime": "99.2%",
  "lastUpdate": "2025-08-22T14:45:30Z"
}
```

## Configuração dos Agentes

### Arquivo de Configuração Global

```json
// docs/agents/config.json
{
  "agents": {
    "A01": {
      "name": "Component Generator",
      "enabled": true,
      "priority": 1,
      "maxExecutions": 100,
      "timeout": 30000,
      "retries": 3,
      "templates": {
        "component": "component-template.tsx",
        "page": "page-template.tsx",
        "hook": "hook-template.ts"
      }
    },
    "A02": {
      "name": "Hook Creator",
      "enabled": true,
      "priority": 2,
      "maxExecutions": 50,
      "timeout": 20000,
      "retries": 2,
      "apiEndpoints": ["/devices", "/relays", "/screens", "/themes"]
    },
    "A03": {
      "name": "Test Writer",
      "enabled": true,
      "priority": 3,
      "maxExecutions": 200,
      "timeout": 60000,
      "retries": 1,
      "coverage": {
        "minimum": 80,
        "target": 95
      }
    },
    "A04": {
      "name": "Performance Optimizer",
      "enabled": true,
      "priority": 4,
      "maxExecutions": 10,
      "timeout": 300000,
      "retries": 1,
      "thresholds": {
        "bundleSize": "500kb",
        "componentSize": "50kb",
        "renderTime": "16ms"
      }
    }
  },
  "global": {
    "logLevel": "info",
    "enableMetrics": true,
    "enableCheckpoints": true,
    "maxLogSize": "10mb",
    "retentionDays": 30
  }
}
```

## Scripts NPM

### Package.json - Scripts dos Agentes

```json
{
  "scripts": {
    "agent:component": "node scripts/agents/A01-component-generator.js",
    "agent:hook": "node scripts/agents/A02-hook-creator.js",
    "agent:test": "node scripts/agents/A03-test-writer.js",
    "agent:optimize": "node scripts/agents/A04-performance-optimizer.js",
    "agents:dashboard": "node scripts/agents/dashboard.js",
    "agents:metrics": "node scripts/agents/metrics.js",
    "agents:logs": "node scripts/agents/logs.js",
    "agents:health": "node scripts/agents/health-check.js",
    "agents:cleanup": "node scripts/agents/cleanup.js"
  }
}
```

## Dashboard de Agentes

### Interface Web

**URL**: `http://localhost:8080/agents-dashboard`

**Seções**:
1. **Status Geral** - Visão geral de todos os agentes
2. **Métricas** - Gráficos e estatísticas
3. **Logs em Tempo Real** - Stream de logs
4. **Checkpoints** - Histórico de execuções
5. **Configuração** - Ajustar parâmetros
6. **Ações** - Executar agentes manualmente

### Dashboard CLI

```bash
# Status geral
npm run agents:dashboard

# Métricas detalhadas
npm run agents:metrics -- --agent=A01 --date=today

# Logs em tempo real
npm run agents:logs -- --follow --agent=all

# Health check
npm run agents:health

# Limpeza de logs antigos
npm run agents:cleanup -- --older-than=30d
```

## Monitoramento e Alertas

### Alertas Automáticos

```javascript
// Sistema de alertas
const alerts = {
  highErrorRate: {
    threshold: 0.1, // 10%
    message: 'Taxa de erro alta no agente {agent}',
    action: 'disable_agent'
  },
  slowExecution: {
    threshold: 60000, // 1 minuto
    message: 'Agente {agent} executando muito lentamente',
    action: 'investigate'
  },
  diskUsage: {
    threshold: 0.9, // 90%
    message: 'Uso de disco alto nos logs dos agentes',
    action: 'cleanup_logs'
  }
}
```

### Notificações

```javascript
// Via toast no frontend
toast.warning('Agente A01 com alta taxa de erro', {
  description: 'Verificar logs para mais detalhes',
  action: {
    label: 'Ver Logs',
    onClick: () => window.open('/agents-dashboard/logs?agent=A01')
  }
})

// Via console em desenvolvimento
console.warn('⚠️ [AGENTS] Alto uso de CPU no agente A04')
```

## Integração com Desenvolvimento

### Git Hooks

```bash
# .git/hooks/pre-commit
#!/bin/bash
# Executar testes automáticos antes do commit
npm run agent:test -- --changed-only

# .git/hooks/post-commit
#!/bin/bash
# Otimizar performance após commit
npm run agent:optimize -- --silent
```

### CI/CD Integration

```yaml
# .github/workflows/agents.yml
name: Frontend Agents
on: [push, pull_request]

jobs:
  agents:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm install
      - run: npm run agent:test -- --coverage
      - run: npm run agent:optimize -- --analyze
      - run: npm run agents:metrics -- --export
```

## Roadmap dos Agentes

### Fase 1 (Atual) - Básicos
- [x] A01 - Component Generator
- [x] A02 - Hook Creator  
- [x] A03 - Test Writer
- [x] A04 - Performance Optimizer

### Fase 2 (Próxima) - Avançados
- [ ] A05 - Documentation Generator
- [ ] A06 - API Integration Tester
- [ ] A07 - Accessibility Auditor
- [ ] A08 - Bundle Analyzer

### Fase 3 (Futura) - Inteligência
- [ ] A09 - Code Reviewer (AI)
- [ ] A10 - Bug Predictor
- [ ] A11 - Performance Predictor
- [ ] A12 - Auto Refactor

## Links Relacionados

- [Dashboard](dashboard.md) - Interface de controle
- [A01 - Component Generator](active-agents/A01-component-generator/README.md)
- [A02 - Hook Creator](active-agents/A02-hook-creator/README.md)
- [A03 - Test Writer](active-agents/A03-test-writer/README.md)
- [A04 - Performance Optimizer](active-agents/A04-performance-optimizer/README.md)
- [Templates](../templates/) - Templates utilizados
- [Development](../development/README.md) - Guias de desenvolvimento
