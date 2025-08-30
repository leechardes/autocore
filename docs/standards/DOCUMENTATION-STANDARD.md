# 📚 Padrão de Documentação AutoCore

## 🎯 Objetivo

Este documento define o padrão oficial de estrutura e nomenclatura para toda a documentação do ecossistema AutoCore.

## 📁 Estrutura Base Obrigatória

Toda pasta `docs/` de qualquer projeto DEVE conter:

```
docs/
├── README.md                    # Visão geral do projeto
├── CHANGELOG.md                 # Histórico de mudanças
├── VERSION.md                   # Versão atual da documentação
├── agents/                      # Sistema de agentes
│   ├── README.md               # Índice de agentes
│   ├── DOC-UPDATER.md         # Agente atualizador de docs
│   └── templates/              # Templates de agentes
└── architecture/                # Arquitetura do projeto
    └── README.md               # Visão geral arquitetural
```

## 📂 Estruturas Específicas por Tipo

### Backend (API/Services)
```
docs/
├── [BASE]
├── api/                         # Documentação de APIs
│   ├── README.md               # Índice de endpoints
│   ├── endpoints/              # Endpoints detalhados
│   ├── schemas/                # Schemas de request/response
│   └── openapi.yaml            # Spec OpenAPI (opcional)
├── database/                    # Banco de dados
│   ├── SCHEMA.md              # Schema do banco
│   └── MIGRATIONS.md          # Histórico de migrations
├── services/                    # Serviços e integrações
└── deployment/                  # Deploy e configuração
    ├── SETUP.md
    └── CONFIGURATION.md
```

### Frontend (Web/Mobile)
```
docs/
├── [BASE]
├── components/                  # Componentes UI
│   ├── README.md
│   └── UI-COMPONENTS.md
├── screens/                     # Telas/Páginas
│   └── README.md
├── state/                       # Gerenciamento de estado
├── hooks/                       # Custom hooks (React)
├── widgets/                     # Widgets (Flutter)
└── user-help/                   # Documentação para usuário
    └── README.md
```

### Firmware (ESP32/Embedded)
```
docs/
├── [BASE]
├── hardware/                    # Especificações de hardware
│   ├── PINOUT.md
│   └── COMPONENTS.md
├── protocols/                   # Protocolos de comunicação
│   ├── MQTT.md
│   └── SERIAL.md
├── configuration/              # Configuração do firmware
└── flashing/                   # Guias de flash
    └── SETUP.md
```

### Gateway/Bridge
```
docs/
├── [BASE]
├── api/                        # APIs e bridges
│   ├── MQTT-TOPICS.md
│   ├── WEBSOCKET.md
│   └── HTTP-BRIDGE.md
├── integration/                # Integrações
│   └── README.md
└── protocols/                  # Protocolos suportados
    └── README.md
```

## 📝 Nomenclatura

### Regras Gerais
1. **Arquivos .md**: MAIÚSCULAS com hífens (exceto README.md)
   - ✅ `API-ENDPOINTS.md`
   - ✅ `USER-GUIDE.md`
   - ❌ `api-endpoints.md`

2. **Pastas**: minúsculas com hífens
   - ✅ `user-help/`
   - ✅ `api-endpoints/`
   - ❌ `UserHelp/`

3. **Agentes**: Prefixo AXX- em MAIÚSCULAS
   - ✅ `A01-DOCUMENTATION.md`
   - ✅ `A99-DOC-UPDATER.md`
   - ❌ `a01-documentation.md`

4. **Templates**: Sufixo -TEMPLATE
   - ✅ `API-ENDPOINT-TEMPLATE.md`
   - ✅ `AGENT-TEMPLATE.md`

## 📋 Estrutura Completa Ideal

```
projeto/docs/
├── README.md                    # Visão geral principal
├── CHANGELOG.md                 # Histórico de mudanças  
├── VERSION.md                   # Versão da documentação
├── .doc-version                 # Arquivo de controle (auto)
│
├── agents/                      # Sistema de agentes
│   ├── README.md               # Catálogo de agentes
│   ├── DOC-UPDATER.md         # Agente atualizador
│   ├── active/                # Agentes ativos
│   ├── executed/              # Histórico de execução
│   └── templates/             # Templates
│
├── api/                        # APIs e endpoints
│   ├── README.md              # Índice de APIs
│   ├── endpoints/             # Detalhamento
│   ├── schemas/               # Modelos de dados
│   └── examples/              # Exemplos de uso
│
├── architecture/               # Decisões arquiteturais
│   ├── README.md              # Visão geral
│   ├── DIAGRAMS.md           # Diagramas
│   └── DECISIONS.md          # ADRs
│
├── deployment/                 # Implantação
│   ├── README.md
│   ├── SETUP-GUIDE.md
│   ├── CONFIGURATION.md
│   └── TROUBLESHOOTING.md
│
├── development/                # Guias de desenvolvimento
│   ├── README.md
│   ├── GETTING-STARTED.md
│   ├── CONTRIBUTING.md
│   └── TESTING.md
│
├── guides/                     # Tutoriais e how-tos
│   ├── README.md
│   └── QUICKSTART.md
│
├── security/                   # Segurança
│   ├── README.md
│   ├── AUTHENTICATION.md
│   └── BEST-PRACTICES.md
│
├── templates/                  # Templates gerais
│   ├── COMPONENT-TEMPLATE.md
│   └── SERVICE-TEMPLATE.md
│
└── troubleshooting/           # Solução de problemas
    ├── README.md
    ├── COMMON-ISSUES.md
    └── FAQ.md
```

## ✅ Checklist de Conformidade

Para verificar se a documentação está em conformidade:

- [ ] Existe `README.md` na raiz de docs/
- [ ] Existe `CHANGELOG.md` com histórico
- [ ] Existe `VERSION.md` com versão atual
- [ ] Pasta `agents/` com DOC-UPDATER.md
- [ ] Pasta `architecture/` com visão geral
- [ ] Nomenclatura segue padrão MAIÚSCULAS
- [ ] Pastas em minúsculas
- [ ] Agentes com prefixo AXX-
- [ ] Templates com sufixo -TEMPLATE

## 🔄 Processo de Atualização

1. **Análise**: Verificar estrutura atual
2. **Identificação**: Mapear arquivos existentes
3. **Padronização**: Renomear conforme regras
4. **Criação**: Adicionar estruturas faltantes
5. **Conteúdo**: Preencher templates básicos
6. **Validação**: Executar checklist

## 🤖 Automação

Use o agente `DOC-UPDATER.md` em cada projeto para:
- Analisar estrutura atual
- Criar pastas faltantes
- Renomear arquivos para o padrão
- Gerar templates básicos
- Atualizar índices

---

**Versão**: 1.0.0  
**Data**: 27/01/2025  
**Autor**: Sistema AutoCore