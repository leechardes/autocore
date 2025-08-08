# 🤖 Instruções para Claude - AutoCore Config App

## 📋 Contexto do Projeto

O **AutoCore Config App** é uma aplicação web moderna para configuração completa do sistema AutoCore - um gateway veicular baseado em Raspberry Pi Zero 2W que gerencia dispositivos ESP32, relés, telas LCD/OLED, sinais CAN e telemetria em tempo real.

### 🎯 Missão
Interface profissional e ultra-leve (< 100MB RAM) para configuração visual de todo o ecossistema AutoCore, permitindo que usuários configurem facilmente seus sistemas veiculares sem conhecimento técnico.

### 🚗 Sistema AutoCore Completo
- **Gateway Central**: Raspberry Pi Zero 2W rodando este config-app
- **Dispositivos**: Múltiplos ESP32 (relés, displays, sensores)
- **Comunicação**: MQTT broker para coordenação
- **Telemetria**: Integração CAN Bus com ECU FuelTech
- **Interface**: Esta aplicação web responsiva

## 📚 Documentação de Referência

**IMPORTANTE**: Sempre consulte estas documentações antes de implementar:

### Documentação Principal
- 📘 **[README.md](README.md)** - Visão completa do projeto, features, API endpoints
- 📙 **[docs/architecture/ARCHITECTURE.md](docs/architecture/ARCHITECTURE.md)** - Decisões arquiteturais e padrões
- 📗 **[backend/CLAUDE.md](backend/CLAUDE.md)** - Instruções específicas do backend
- 📕 **[frontend/CLAUDE.md](frontend/CLAUDE.md)** - Instruções específicas do frontend

### Documentação Técnica
- 📓 [backend/docs/API.md](backend/docs/API.md) - Documentação completa da API
- 📔 [docs/database/SCHEMA.md](docs/database/SCHEMA.md) - Schema do banco de dados
- 📒 [docs/planning/](docs/planning/) - Cronogramas e planejamento

## ✨ Características Únicas

### Performance Extrema
- **RAM < 80MB** - Testado no Raspberry Pi Zero 2W
- **Load Time < 200ms** - Interface instantânea
- **API < 100ms** - Responses ultrarrápidas
- **Zero Build Process** - Frontend via CDN (Tailwind + Alpine.js)

### Visual Profissional
- **Inspirado shadcn/ui** - Design system moderno
- **Totalmente Responsivo** - Mobile-first approach
- **Temas Dinâmicos** - Dark/Light/Custom com persistência
- **Real-time Updates** - WebSocket + MQTT integration

### Funcionalidades Avançadas
- **Editor Drag-and-Drop** - Configuração visual de telas
- **Descoberta Automática** - ESP32 auto-discovery via MQTT
- **OTA Updates** - Firmware updates remotos
- **CAN Bus Integration** - Telemetria FuelTech ECU
- **Proteção Avançada** - Relés com senha/confirmação

## 🛠️ Stack Tecnológica

### Frontend
- **HTML5** - Estrutura semântica
- **Tailwind CSS (CDN)** - Estilização e visual shadcn-like
- **Alpine.js** - Reatividade sem build process
- **Lucide Icons** - Ícones consistentes
- **Chart.js** - Gráficos (opcional)

### Backend
- **FastAPI** - Framework Python moderno e rápido
- **SQLite** - Banco de dados leve e confiável
- **Uvicorn** - Servidor ASGI de alta performance
- **Pydantic** - Validação de dados

### Infraestrutura
- **Raspberry Pi Zero 2W** - Hardware alvo
- **MQTT Mosquitto** - Comunicação com dispositivos
- **PM2** - Gerenciador de processos
- **Nginx** - Proxy reverso (opcional)

## 📁 Estrutura do Projeto

```
config-app/
├── backend/          # API FastAPI
├── frontend/         # Interface web
├── config/          # Configurações e temas
├── docs/            # Documentação completa
└── database/        # Schema e migrações
```

## 🎨 Padrões de Desenvolvimento

### Frontend

#### Componentes Reutilizáveis
- Todos os componentes devem ser modulares e estar em `frontend/components/`
- Usar Alpine.js para reatividade
- Seguir padrão de nomenclatura: `nome-componente.js`

#### Estilização
- Usar classes Tailwind para styling
- Customizações em `frontend/assets/css/custom.css`
- Variáveis de tema em CSS custom properties

#### Exemplo de Componente:
```javascript
// frontend/components/ui/button.js
Alpine.data('button', () => ({
    variant: 'primary',
    disabled: false,
    loading: false,
    // ... lógica do componente
}))
```

### Backend

#### Estrutura de Rotas
- Uma rota por arquivo em `backend/api/routes/`
- Usar prefixos consistentes: `/api/v1/{recurso}`
- Documentação automática via FastAPI

#### Modelos Pydantic
- Definir em `backend/api/models/`
- Validação rigorosa de tipos
- Exemplos claros na documentação

#### Serviços
- Lógica de negócio em `backend/api/services/`
- Separar responsabilidades claramente
- Tratamento de erros consistente

## 🔧 Configuração e Ambiente

### Variáveis de Ambiente
```env
# Backend
DATABASE_URL=sqlite:///./database/autocore.db
MQTT_BROKER=localhost
MQTT_PORT=1883
API_PORT=8000

# Frontend
API_BASE_URL=http://localhost:8000
```

### Temas
- Temas definidos em `config/themes/`
- Suporte para dark, light e custom themes
- Troca dinâmica via JavaScript

## 📝 Convenções de Código

### Python (Backend)
- PEP 8 compliance
- Type hints em todas as funções
- Docstrings em formato Google
- Async/await para operações I/O

### JavaScript (Frontend)
- ES6+ features
- Camel case para variáveis
- Kebab case para arquivos
- Comentários JSDoc quando necessário

### HTML
- Semantic HTML5
- Atributos Alpine.js com x-prefix
- IDs em kebab-case
- Classes Tailwind organizadas

## 🚀 Workflow de Desenvolvimento

1. **Planejamento** - Revisar documentação e TODO.md
2. **Desenvolvimento** - Seguir estrutura estabelecida
3. **Testes** - Testar em ambiente local
4. **Deploy** - Usar scripts de deploy para Raspberry Pi

## 🧪 Testes

### Frontend
- Testes manuais de responsividade
- Verificar em múltiplos dispositivos
- Performance em hardware limitado

### Backend
- Unit tests com pytest
- Testes de integração para API
- Testes de carga para Raspberry Pi

## 🔒 Segurança

- **Nunca** commitar credenciais
- Usar variáveis de ambiente
- Validar todos os inputs
- Rate limiting nas APIs
- CORS configurado corretamente

## 📊 Performance

### Otimizações Obrigatórias
- Lazy loading de componentes pesados
- Cache agressivo de assets estáticos
- Queries SQLite otimizadas
- Minificação de CSS/JS para produção
- Compressão gzip habilitada

### Limites de Performance
- Página inicial < 200ms
- API responses < 100ms
- RAM total < 100MB
- CPU idle < 10%

## 🎯 Checklist de Qualidade

Antes de qualquer commit, verificar:

- [ ] Código segue os padrões estabelecidos
- [ ] Documentação atualizada
- [ ] Testes passando
- [ ] Performance adequada para Pi Zero
- [ ] Responsividade testada
- [ ] Sem credenciais hardcoded
- [ ] TODO.md atualizado

## 🆘 Problemas Comuns

### Frontend não carrega
- Verificar se API está rodando
- Checar CORS settings
- Confirmar paths dos CDNs

### Performance ruim
- Verificar queries N+1
- Reduzir JavaScript desnecessário
- Habilitar cache do navegador

### Erro de conexão MQTT
- Verificar se Mosquitto está rodando
- Checar credenciais MQTT
- Confirmar porta e host

## 🔧 Comandos e Workflow

### Quick Start
```bash
# Backend
cd backend && make install && make run

# Frontend (servidor estático)
cd frontend && python3 -m http.server 8080

# Database (se necessário reinicializar)
cd ../../database && make reset
```

### API Endpoints (conforme README.md)
```
GET    /api/devices          # Lista dispositivos ESP32
GET    /api/relays/boards    # Lista placas de relé  
GET    /api/relays/channels  # Lista canais individuais
GET    /api/screens          # Lista telas configuradas
GET    /api/themes/default   # Tema padrão do sistema
GET    /api/config/generate/{uuid}  # Gera config JSON para ESP32
```

## 📚 Recursos e Referências

### 🎨 Design System
- **Inspiração Principal**: [shadcn/ui Dashboard](https://ui.shadcn.com/examples/dashboard)
- **Implementação**: HTML + Tailwind CSS + Alpine.js (zero build)
- **Variáveis CSS**: Sistema de cores shadcn em `custom.css`
- **Componentes**: Recriar em HTML puro com mesmo visual

### 📖 Documentação Técnica
- **[FastAPI Best Practices](https://fastapi.tiangolo.com/tutorial/best-practices/)**
- **[Alpine.js Documentation](https://alpinejs.dev/start-here)**
- **[Tailwind CSS](https://tailwindcss.com/docs)** - Utility classes
- **[Lucide Icons](https://lucide.dev/icons/)** - Icon library

### 🏗️ Arquitetura de Referência
- **Backend**: Repository Pattern + SQLAlchemy ORM (já implementado)
- **Frontend**: Component-based + Alpine.js stores
- **Database**: Compartilhado com projeto `database/` (não duplicar)
- **Deploy**: Raspberry Pi Zero 2W otimizado

## 🎓 Dicas para Desenvolvimento

1. **Sempre teste no Raspberry Pi** antes de considerar pronto
2. **Componentes primeiro** - Crie componentes reutilizáveis
3. **Mobile-first** - Design para mobile, adapte para desktop
4. **Documentação inline** - Comente código complexo
5. **Commits pequenos** - Facilita revisão e rollback

## 🏁 Comandos Úteis

```bash
# Desenvolvimento
make dev         # Inicia servidor de desenvolvimento
make test        # Roda testes
make lint        # Verifica código

# Deploy
make build       # Build para produção
make deploy      # Deploy para Raspberry Pi
make rollback    # Volta versão anterior

# Database
make db-migrate  # Roda migrações
make db-seed     # Popula dados iniciais
make db-reset    # Reset completo
```

## 🎯 Prioridades de Implementação

### ✅ Concluído
- Backend FastAPI completo + SQLAlchemy ORM
- Database schema + repositories funcionando
- API endpoints testados (devices, relays, screens)
- Documentação arquitetural completa

### 🚧 Em Andamento
- Frontend: Estrutura HTML base + componentes Alpine.js

### 📋 Próximos Passos
1. **Frontend Base** - HTML + Tailwind + Alpine.js setup
2. **Dashboard** - Métricas e status em tempo real
3. **Gestão Dispositivos** - CRUD interface
4. **Editor Relés** - Configuração visual
5. **Editor Telas** - Drag-and-drop interface

## ✅ Status Atual do Projeto - BETA COMPLETO

### 🎯 O AutoCore Config App está **COMPLETO** para a fase BETA!

#### ✅ **TOTALMENTE IMPLEMENTADO** (100%)

**🏗️ Arquitetura**
- ✅ Backend FastAPI completo (1100+ linhas, 50+ endpoints)
- ✅ Frontend React + shadcn/ui (8 páginas funcionais)
- ✅ Database SQLAlchemy + Repository Pattern
- ✅ Sistema de build e deploy

**🖥️ Interface Completa**
- ✅ Dashboard com métricas em tempo real
- ✅ Gerenciamento completo de dispositivos ESP32
- ✅ Sistema avançado de relés (placas + canais)
- ✅ Editor drag & drop de telas com preview
- ✅ Gerador multi-formato de configs (JSON/C++/YAML)
- ✅ Sistema de temas dinâmico (3 temas × 7 cores)
- ✅ Páginas de configuração (Settings + Device Themes)
- ✅ **Sistema CAN Bus completo e dinâmico**

**🚗 CAN Bus - Funcionalidade Premium**
- ✅ CRUD completo de sinais CAN
- ✅ 14 sinais padrão FuelTech pré-configurados
- ✅ Telemetria dinâmica baseada no banco
- ✅ Simulador inteligente (scale, offset, can_id reais)
- ✅ Visualização avançada (gauges, gráficos, raw data)
- ✅ Categorização profissional
- ✅ Mensagens CAN raw geradas automaticamente

**📊 Qualidade**
- ✅ Interface 100% responsiva
- ✅ Performance otimizada para Raspberry Pi Zero 2W
- ✅ Validações e tratamento de erros
- ✅ Documentação completa e atualizada
- ✅ Sistema de navegação fluido

#### 🚧 **PRÓXIMAS ETAPAS** (Gateway Integration)

**🔄 Integração Real**
- 🚧 Gateway MQTT para comunicação com ESP32
- 🚧 WebSocket para updates em tempo real  
- 🚧 Autenticação JWT com roles
- 🚧 Deploy scripts para produção

### 🎉 **MARCO ALCANÇADO**

O **AutoCore Config App** é agora uma aplicação **COMPLETA** e **PROFISSIONAL** que oferece:

1. **Interface moderna** comparable a aplicações comerciais
2. **Funcionalidades avançadas** para configuração automotiva
3. **Sistema CAN Bus** dinâmico e flexível
4. **Performance otimizada** para hardware embarcado
5. **Documentação completa** para uso e desenvolvimento

### 🚀 **READY FOR GATEWAY**

Com toda a base configurada, estamos prontos para implementar o **AutoCore Gateway** que fará a ponte entre o Config App e os dispositivos ESP32 reais via MQTT.

---

**Estado:** 🎯 **BETA COMPLETO** - Ready for Gateway Integration  
**Última Atualização:** 08 de Agosto de 2025  
**Maintainer:** Lee Chardes | **Versão:** 2.0.0-beta