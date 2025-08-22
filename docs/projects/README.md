# 📍 Hub de Navegação - Projetos AutoCore

## 🗺️ Mapa de Documentação dos Projetos

Este hub centraliza o acesso à documentação de todos os componentes do sistema AutoCore.

## 🚀 Projetos Principais

### 🖥️ Backend (Config App)
**[→ Acessar Documentação](../../config-app/backend/docs/README.md)**
- API REST FastAPI
- Sistema de dispositivos ESP32
- Gerenciamento de telas e relés
- Integração MQTT
- Status: ✅ Documentação completa

### 🎨 Frontend (Config App)
**[→ Acessar Documentação](../../config-app/frontend/docs/README.md)**
- Interface React/TypeScript
- Componentes shadcn/ui
- Sistema de ajuda integrado
- Dashboard de controle
- Status: ✅ Documentação completa

### 🗄️ Database
**[→ Acessar Documentação](../../database/docs/README.md)**
- SQLite (migrando para PostgreSQL)
- SQLAlchemy ORM
- Migrations com Alembic
- Models e relacionamentos
- Status: ✅ Documentação completa

### 📱 App Flutter
**[→ Acessar Documentação](../../app-flutter/docs/README.md)**
- Aplicativo mobile multiplataforma
- Controle remoto de dispositivos
- Interface nativa iOS/Android
- Integração MQTT em tempo real
- Status: ✅ Documentação completa

### 🔧 Firmware ESP32
**[→ Acessar Documentação](../../firmware/platformio/esp32-display/docs/README.md)**
- Firmware para ESP32 com display
- Interface LVGL touch
- Protocolo MQTT v2.2.0
- Sistema NavButtons
- Status: ✅ Documentação completa

### 🌐 Gateway
**[→ Acessar Documentação](../../gateway/docs/)**
- Ponte entre MQTT e HTTP
- Processamento de comandos
- Cache e buffer
- Status: 🔄 Documentação em progresso

### 🥧 Raspberry Pi
**[→ Acessar Documentação](../../raspberry-pi/docs/)**
- Sistema embarcado principal
- MQTT Broker (Mosquitto)
- Coordenação de dispositivos
- Status: 🔄 Documentação em progresso

## 📊 Status da Documentação

| Projeto | Cobertura | Agente | Status |
|---------|-----------|--------|--------|
| Backend | 100% | A01 | ✅ Completo |
| Frontend | 100% | A04 | ✅ Completo |
| Database | 100% | A05 | ✅ Completo |
| Flutter | 100% | A06 | ✅ Completo |
| Firmware | 100% | A07 | ✅ Completo |
| Gateway | 30% | - | 🔄 Em progresso |
| Raspberry | 20% | - | 🔄 Em progresso |

## 🔗 Links Rápidos

### Documentação Técnica
- [Arquitetura MQTT](../architecture/mqtt-architecture.md)
- [Estrutura do Projeto](../architecture/project-structure.md)
- [Visão Geral](../architecture/project-overview.md)

### Guias de Desenvolvimento
- [Plano de Desenvolvimento](../standards/development-plan.md)
- [Segurança](../standards/security.md)
- [Papéis e Responsabilidades](../standards/roles-responsibilities.md)

### Hardware ESP32
- [Análise ESP32 Display](../hardware/esp32-display-analysis.md)
- [Análise ESP32 Relay](../hardware/esp32-relay-analysis.md)

### Deployment
- [Guia de Deployment](../deployment/deployment-guide.md)
- [Configuração de Portas](../deployment/ports-configuration.md)
- [Deploy com Venv](../deployment/venv-deployment.md)

## 🤖 Sistema de Agentes

Todos os projetos foram documentados usando agentes automatizados:

- **[Agentes Executados](../agents/executed/)** - Histórico de agentes
- **[Templates de Agentes](../agents/templates/)** - Para criar novos agentes
- **[Dashboard de Agentes](../agents/dashboard.md)** - Controle e monitoramento

## 📈 Métricas Globais

- **Total de Documentos**: 109+ arquivos
- **Projetos Documentados**: 7 componentes
- **Agentes Executados**: 8 agentes
- **Templates Criados**: 16 templates (TypeScript, Python, Dart, C++)
- **Cobertura Total**: ~85% do sistema

## 🚀 Como Navegar

1. **Por Projeto**: Use os links diretos acima
2. **Por Categoria**: Explore as pastas temáticas em `docs/`
3. **Por Tecnologia**: Cada projeto tem documentação específica
4. **Por Função**: Consulte os guias e padrões

## 🔄 Atualizações Recentes

- ✅ **2025-08-22**: Reorganização completa da documentação
- ✅ **2025-08-22**: Documentação de 5 projetos principais
- ✅ **2025-08-22**: Sistema de agentes implementado
- ✅ **2025-08-22**: Hub de navegação criado

---

**Dica**: Para voltar a este hub de qualquer documentação, use o caminho:
```
../../../docs/projects/README.md
```