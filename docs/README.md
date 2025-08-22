# 📚 Documentação AutoCore

## 🎯 Navegação Rápida

### [🚀 Hub de Projetos](projects/README.md)
Acesso direto à documentação de todos os componentes do sistema.

### [🤖 Sistema de Agentes](agents/README.md)
Agentes automatizados para documentação e desenvolvimento.

### [🏗️ Arquitetura](architecture/)
Visão geral, estrutura e design do sistema.

### [📋 Padrões e Guias](standards/)
Convenções, segurança e boas práticas.

## 📁 Estrutura da Documentação

```
docs/
├── agents/              # Sistema de agentes automatizados
│   ├── executed/        # Histórico de agentes executados
│   ├── templates/       # Templates para novos agentes
│   └── active/          # Agentes recorrentes ativos
│
├── projects/            # Hub de navegação dos projetos
│   └── README.md        # Links para todas as documentações
│
├── architecture/        # Arquitetura e design
│   ├── mqtt-architecture.md
│   ├── project-overview.md
│   └── project-structure.md
│
├── hardware/            # Documentação de hardware ESP32
│   ├── esp32-display-analysis.md
│   └── esp32-relay-analysis.md
│
├── deployment/          # Guias de deployment
│   ├── deployment-guide.md
│   ├── ports-configuration.md
│   └── venv-deployment.md
│
├── standards/           # Padrões e convenções
│   ├── development-plan.md
│   ├── security.md
│   ├── macros-security.md
│   └── roles-responsibilities.md
│
└── guides/              # Guias gerais
    ├── storage-reference.md
    ├── sd-optimization-guide.md
    └── telegram-notifications.md
```

## 🔍 Como Encontrar Informações

### Por Tipo de Informação

#### 💻 Desenvolvimento
- [Plano de Desenvolvimento](standards/development-plan.md)
- [Papéis e Responsabilidades](standards/roles-responsibilities.md)
- [Templates de Agentes](agents/templates/)

#### 🏗️ Arquitetura
- [Visão Geral do Projeto](architecture/project-overview.md)
- [Estrutura do Projeto](architecture/project-structure.md)
- [Arquitetura MQTT](architecture/mqtt-architecture.md)

#### 🔧 Hardware ESP32
- [ESP32 Display - Análise Completa](hardware/esp32-display-analysis.md)
- [ESP32 Relay - Configuração](hardware/esp32-relay-analysis.md)

#### 🚀 Deploy e Operações
- [Guia de Deployment](deployment/deployment-guide.md)
- [Configuração de Portas](deployment/ports-configuration.md)
- [Deploy com Ambiente Virtual](deployment/venv-deployment.md)

#### 🔒 Segurança
- [Políticas de Segurança](standards/security.md)
- [Segurança de Macros](standards/macros-security.md)

#### 📖 Guias e Referências
- [Referência de Armazenamento](guides/storage-reference.md)
- [Otimização de Cartão SD](guides/sd-optimization-guide.md)
- [Notificações Telegram](guides/telegram-notifications.md)

### Por Projeto Específico

Acesse o [Hub de Projetos](projects/README.md) para documentação específica de:
- 🖥️ **Backend** - API FastAPI
- 🎨 **Frontend** - Interface React
- 🗄️ **Database** - SQLite/PostgreSQL
- 📱 **Flutter** - App Mobile
- 🔧 **Firmware** - ESP32
- 🌐 **Gateway** - Bridge MQTT/HTTP
- 🥧 **Raspberry** - Sistema embarcado

## 🤖 Agentes de Documentação

### Agentes Executados
Histórico completo dos agentes que geraram a documentação atual:

| Agente | Função | Status |
|--------|--------|--------|
| [A01](agents/executed/A01-doc-backend.md) | Documentação Backend | ✅ Completo |
| [A02](agents/executed/A02-agents-docs.md) | Sistema de Agentes | ✅ Completo |
| [A03](agents/executed/A03-master-docs.md) | Coordenador Master | ✅ Completo |
| [A04](agents/executed/A04-frontend-docs.md) | Documentação Frontend | ✅ Completo |
| [A05](agents/executed/A05-database-docs.md) | Documentação Database | ✅ Completo |
| [A06](agents/executed/A06-flutter-docs.md) | Documentação Flutter | ✅ Completo |
| [A07](agents/executed/A07-firmware-docs.md) | Documentação Firmware | ✅ Completo |
| [A08](agents/executed/A08-root-docs-organizer.md) | Organizador Raiz | ✅ Completo |

### Como Usar Agentes
1. Consulte os [Templates](agents/templates/) disponíveis
2. Crie um novo agente seguindo o padrão
3. Execute com a ferramenta Task
4. Documente em `agents/executed/`

## 📊 Status da Documentação

### Cobertura por Componente
- ✅ **Backend**: 100% documentado
- ✅ **Frontend**: 100% documentado
- ✅ **Database**: 100% documentado
- ✅ **Flutter**: 100% documentado
- ✅ **Firmware**: 100% documentado
- 🔄 **Gateway**: Em progresso
- 🔄 **Raspberry**: Em progresso

### Métricas Globais
- **109+** arquivos de documentação
- **8** agentes executados
- **16** templates criados
- **7** projetos documentados
- **85%** cobertura total estimada

## 🔄 Changelog

### 2025-08-22
- ✅ Reorganização completa da estrutura de documentação
- ✅ Criação do hub de navegação de projetos
- ✅ Migração de agentes para estrutura organizada
- ✅ Categorização temática de documentos
- ✅ Padronização de nomenclatura (minúsculo com hífen)

### 2025-08-22 (Anterior)
- ✅ Documentação completa de 5 projetos principais
- ✅ Sistema de agentes implementado
- ✅ Templates funcionais criados

## 🚀 Próximos Passos

1. Completar documentação do Gateway
2. Completar documentação do Raspberry Pi
3. Criar agentes para manutenção contínua
4. Implementar geração automática de changelog
5. Adicionar diagramas e fluxogramas

## 📝 Convenções

### Nomenclatura de Arquivos
- Usar minúsculas com hífen: `nome-do-arquivo.md`
- Agentes: `AXX-nome-funcao.md`
- Templates: `nome-template.md`

### Estrutura de Documentos
- Sempre incluir título principal (#)
- Usar emojis para categorias principais
- Incluir índice para documentos longos
- Adicionar links de navegação

### Versionamento
- Manter `CHANGELOG.md` atualizado
- Usar versionamento semântico
- Documentar breaking changes

## 🆘 Suporte

Para questões sobre a documentação:
1. Consulte o [Hub de Projetos](projects/README.md)
2. Verifique os [Guias](guides/)
3. Revise os [Padrões](standards/)
4. Consulte os [Agentes](agents/executed/) para entender como foi gerado

---

**AutoCore Documentation System v1.0.0**  
*Última atualização: 2025-08-22*