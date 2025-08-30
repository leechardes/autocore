# 🤖 A99-DOC-UPDATER - Agente Atualizador de Documentação

## 📋 Objetivo

Agente autônomo para análise, padronização e atualização da documentação de projetos AutoCore seguindo o padrão oficial definido em `/docs/standards/DOCUMENTATION-STANDARD.md`.

## 🎯 Missão

Garantir que toda documentação do projeto siga o padrão oficial AutoCore, criando estrutura completa, renomeando arquivos e gerando templates quando necessário.

## ⚙️ Configuração

```yaml
tipo: maintenance
frequência: sob demanda
prioridade: alta
autônomo: true
projeto_escopo: pasta_atual_apenas
```

## 📍 Escopo de Atuação

**IMPORTANTE**: Este agente atua APENAS no projeto onde está localizado.
- Analisa apenas a pasta `docs/` do projeto atual
- Não acessa outros projetos
- Não modifica código fonte
- Foco exclusivo em documentação

## 🔄 Fluxo de Execução

### Fase 1: Análise (10%)
1. Identificar tipo de projeto (backend/frontend/firmware/gateway)
2. Mapear estrutura atual de docs/
3. Listar todos os arquivos .md existentes
4. Verificar nomenclatura atual

### Fase 2: Planejamento (20%)
1. Comparar com padrão oficial
2. Identificar pastas faltantes
3. Identificar arquivos para renomear
4. Planejar criação de novos arquivos

### Fase 3: Estrutura (40%)
1. Criar estrutura base obrigatória
2. Criar estruturas específicas por tipo
3. Criar pastas faltantes
4. Manter conteúdo existente

### Fase 4: Padronização (60%)
1. Renomear arquivos para MAIÚSCULAS
2. Preservar README.md (exceção)
3. Ajustar agentes para padrão AXX-
4. Adicionar sufixo -TEMPLATE onde aplicável

### Fase 5: Conteúdo (80%)
1. Criar arquivos base faltantes
2. Gerar templates mínimos
3. Atualizar índices (README.md)
4. Preservar conteúdo existente

### Fase 6: Validação (100%)
1. Executar checklist de conformidade
2. Gerar relatório de mudanças
3. Criar CHANGELOG.md atualizado
4. Atualizar VERSION.md

## 📊 Detecção de Tipo de Projeto

### Backend (API/Service)
- Presença de `main.py`, `app.py`
- Pasta `api/` ou `routes/`
- Arquivo `requirements.txt`
- Framework: FastAPI, Flask, Django

### Frontend Web
- Presença de `package.json`
- Pasta `src/components/`
- Framework: React, Vue, Angular
- Build tools: Vite, Webpack

### Flutter Mobile
- Presença de `pubspec.yaml`
- Pasta `lib/`
- Arquivos `.dart`

### Firmware ESP32
- Presença de `platformio.ini`
- Pasta `src/` com `.cpp`
- Configurações ESP-IDF

### Gateway/Bridge
- Características mistas
- Serviços MQTT
- Bridge HTTP/WebSocket

## 📁 Estruturas por Tipo

### Estrutura Base (Todos)
```
docs/
├── README.md                    # Preservar ou criar
├── CHANGELOG.md                 # Criar se não existir
├── VERSION.md                   # Criar com v1.0.0
├── agents/                      # Criar estrutura
│   ├── README.md
│   ├── DOC-UPDATER.md          # Este arquivo (copiar)
│   └── templates/
└── architecture/
    └── README.md
```

### Adicional Backend
```
├── api/
│   ├── README.md
│   ├── endpoints/
│   └── schemas/
├── database/
├── services/
└── deployment/
```

### Adicional Frontend
```
├── components/
│   └── README.md
├── screens/
├── state/
├── hooks/         # React
├── widgets/       # Flutter
└── user-help/
```

### Adicional Firmware
```
├── hardware/
│   ├── PINOUT.md
│   └── COMPONENTS.md
├── protocols/
└── flashing/
```

### Adicional Gateway
```
├── api/
│   ├── MQTT-TOPICS.md
│   ├── WEBSOCKET.md
│   └── HTTP-BRIDGE.md
├── integration/
└── protocols/
```

## 🔧 Regras de Nomenclatura

### Renomeação Automática
```
Antes                    →  Depois
─────────────────────────────────────
api-endpoints.md        →  API-ENDPOINTS.md
user_guide.md          →  USER-GUIDE.md
mqtt-topics.md         →  MQTT-TOPICS.md
changelog.md           →  CHANGELOG.md
version.md             →  VERSION.md

EXCEÇÕES (não renomear):
- README.md (sempre minúsculo)
- openapi.yaml (não é .md)
- *.json, *.yml (outros formatos)
```

### Agentes
```
Antes                    →  Depois
─────────────────────────────────────
documentation.md        →  A01-DOCUMENTATION.md
agent-executor.md      →  A02-AGENT-EXECUTOR.md
doc-updater.md         →  A99-DOC-UPDATER.md
```

## 📝 Templates Mínimos

### README.md Base
```markdown
# 📚 Documentação [Nome do Projeto]

## 🎯 Visão Geral
[Breve descrição do projeto]

## 📁 Estrutura
[Lista de pastas principais]

## 🚀 Quick Start
[Como começar rapidamente]

## 📖 Documentação Detalhada
[Links para docs específicas]
```

### CHANGELOG.md Base
```markdown
# 📝 Changelog

## [1.0.0] - 2025-01-27
### Added
- Estrutura inicial de documentação
- Padronização conforme DOCUMENTATION-STANDARD.md

### Changed
- Nomenclatura atualizada para padrão MAIÚSCULAS

### Fixed
- Organização de arquivos
```

### VERSION.md Base
```markdown
# 📌 Versão da Documentação

**Versão Atual**: 1.0.0
**Data**: 2025-01-27
**Status**: Atualizado

## Histórico
- 1.0.0 - Padronização inicial
```

## ✅ Checklist de Validação

- [ ] README.md presente e atualizado
- [ ] CHANGELOG.md criado/atualizado
- [ ] VERSION.md com versão atual
- [ ] Pasta agents/ com estrutura completa
- [ ] Pasta architecture/ criada
- [ ] Nomenclatura 100% em MAIÚSCULAS
- [ ] Agentes com prefixo AXX-
- [ ] Templates com sufixo -TEMPLATE
- [ ] Estrutura específica do tipo criada
- [ ] Índices atualizados
- [ ] Conteúdo preservado
- [ ] Sem arquivos duplicados

## 📊 Relatório de Execução

Ao final, gerar relatório em `agents/executed/DOC-UPDATE-REPORT-[DATA].md`:

```markdown
# Relatório de Atualização de Documentação

**Data**: [DATA]
**Projeto**: [NOME]
**Tipo Detectado**: [TIPO]

## Mudanças Realizadas
- [X] arquivos renomeados
- [Y] pastas criadas
- [Z] templates gerados

## Arquivos Renomeados
[Lista antes → depois]

## Estruturas Criadas
[Lista de pastas novas]

## Conformidade
[Checklist completo]
```

## 🚀 Como Executar

### Execução Manual
```bash
# Na pasta do projeto
cd /caminho/do/projeto
# Executar: "Execute o agente DOC-UPDATER"
```

### Execução Via Task
```python
Task(
    description="Atualizar documentação",
    subagent_type="general-purpose",
    prompt="""
    Execute o agente A99-DOC-UPDATER localizado em docs/agents/DOC-UPDATER.md
    para padronizar toda a documentação do projeto atual.
    
    IMPORTANTE:
    - Analise APENAS a pasta docs/ do projeto atual
    - Siga rigorosamente o padrão em DOCUMENTATION-STANDARD.md
    - Preserve todo conteúdo existente
    - Gere relatório completo ao final
    """
)
```

## ⚠️ Avisos Importantes

1. **NUNCA** delete conteúdo existente, apenas reorganize
2. **SEMPRE** faça backup mental antes de renomear
3. **PRESERVE** customizações específicas do projeto
4. **MANTENHA** links e referências funcionando
5. **ATUALIZE** referências após renomeação
6. **TESTE** navegação após mudanças

## 🎯 Resultado Esperado

Após execução bem-sucedida:
- ✅ Documentação 100% padronizada
- ✅ Estrutura completa e organizada
- ✅ Nomenclatura consistente
- ✅ Templates básicos criados
- ✅ Índices atualizados
- ✅ Relatório de execução gerado
- ✅ Fácil navegação e manutenção

---

**Versão do Agente**: 1.0.0  
**Autor**: Sistema AutoCore  
**Data**: 27/01/2025

## 🔄 Auto-Atualização

Este agente deve ser copiado para `docs/agents/` de cada projeto e executado localmente.