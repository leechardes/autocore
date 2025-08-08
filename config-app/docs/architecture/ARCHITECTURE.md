# 🏛️ Arquitetura - AutoCore Config App

## 📐 Visão Geral da Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend                             │
│  HTML5 + Tailwind CSS + Alpine.js (No Build Process)        │
├─────────────────────────────────────────────────────────────┤
│                      API Gateway                             │
│                    FastAPI + Uvicorn                         │
├─────────────────────────────────────────────────────────────┤
│                     Business Logic                           │
│              Services + Models + Validators                  │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                              │
│                   SQLite + SQLAlchemy                        │
├─────────────────────────────────────────────────────────────┤
│                    Communication Layer                       │
│              MQTT (Mosquitto) + WebSocket                    │
├─────────────────────────────────────────────────────────────┤
│                     Hardware Layer                           │
│           Raspberry Pi Zero 2W + ESP32 Devices               │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Princípios Arquiteturais

### 1. Simplicidade
- Sem build process no frontend
- Mínimas dependências
- Código claro e manutenível

### 2. Performance
- Otimizado para hardware limitado
- Cache agressivo
- Lazy loading de recursos

### 3. Modularidade
- Componentes independentes
- Baixo acoplamento
- Alta coesão

### 4. Escalabilidade
- Horizontal para múltiplos dispositivos
- Vertical limitada pelo hardware

## 🔧 Componentes Principais

### Frontend Layer

```
frontend/
├── pages/              # Páginas HTML estáticas
├── components/         # Componentes Alpine.js reutilizáveis
│   ├── ui/            # Componentes base (button, modal, etc)
│   ├── layout/        # Layout components (navbar, sidebar)
│   └── modules/       # Componentes específicos do domínio
├── assets/
│   ├── css/           # Estilos customizados e temas
│   ├── js/            # Lógica JavaScript e Alpine.js
│   └── images/        # Assets visuais
└── templates/         # Templates HTML base
```

**Tecnologias:**
- HTML5 semântico
- Tailwind CSS via CDN
- Alpine.js para reatividade
- Lucide Icons
- Chart.js (opcional)

### Backend Layer

```
backend/
├── api/
│   ├── routes/        # Endpoints REST organizados por recurso
│   ├── models/        # Modelos Pydantic para validação
│   ├── services/      # Lógica de negócio
│   ├── middleware/    # CORS, Auth, Rate Limiting
│   └── utils/         # Funções auxiliares
├── database/
│   ├── models.py      # Modelos SQLAlchemy
│   ├── migrations/    # Alembic migrations
│   └── seeds/         # Dados iniciais
└── config/           # Configurações e variáveis de ambiente
```

**Tecnologias:**
- FastAPI framework
- Pydantic para validação
- SQLAlchemy ORM
- Uvicorn ASGI server

### Data Layer

```sql
-- Tabelas Principais
devices              -- Dispositivos ESP32
relay_boards         -- Placas de relé
relay_channels       -- Canais individuais
screens              -- Configuração de telas
screen_items         -- Itens das telas
can_signals          -- Sinais CAN mapeados
users                -- Usuários do sistema
themes               -- Temas visuais
event_logs           -- Logs de eventos
```

**Tecnologias:**
- SQLite database
- SQLAlchemy ORM
- Alembic migrations

### Communication Layer

```
MQTT Broker (Mosquitto)
├── autocore/devices/+/status     # Status dos dispositivos
├── autocore/devices/+/command    # Comandos para dispositivos
├── autocore/devices/+/telemetry  # Telemetria em tempo real
└── autocore/system/+             # Mensagens do sistema

WebSocket
├── /ws/devices                   # Updates de dispositivos
├── /ws/can                       # Telemetria CAN
└── /ws/logs                      # Logs em tempo real
```

## 🔄 Fluxo de Dados

### 1. Requisição do Usuário
```
User → Browser → HTTP Request → FastAPI → Service → Database
                                    ↓
                              MQTT Command → ESP32 Device
```

### 2. Atualização em Tempo Real
```
ESP32 → MQTT Publish → Mosquitto Broker
                            ↓
                     FastAPI Subscribe
                            ↓
                     WebSocket Broadcast
                            ↓
                     Browser (Alpine.js)
```

### 3. Telemetria CAN
```
FuelTech ECU → CAN Bus → ESP32 CAN Interface
                              ↓
                        MQTT Publish
                              ↓
                        FastAPI Process
                              ↓
                        Store in SQLite
                              ↓
                        WebSocket to UI
```

## 🔐 Segurança

### Autenticação e Autorização
```python
# JWT Token Flow
Login → Validate Credentials → Generate JWT → Return Token
Request → Validate JWT → Check Permissions → Process Request
```

### Camadas de Segurança
1. **Network Level** - Firewall, VPN opcional
2. **Application Level** - JWT, CORS, Rate Limiting
3. **Data Level** - Input validation, SQL injection prevention
4. **Communication Level** - MQTT auth, WebSocket auth

## ⚡ Performance

### Otimizações Implementadas

1. **Frontend**
   - CDN para bibliotecas
   - Lazy loading de componentes
   - Cache de assets estáticos
   - Minificação em produção

2. **Backend**
   - Connection pooling
   - Query optimization
   - Response caching
   - Async operations

3. **Database**
   - Índices estratégicos
   - Query optimization
   - WAL mode para SQLite
   - Batch operations

### Métricas Alvo

| Componente | Métrica | Alvo |
|------------|---------|------|
| Page Load | Time to Interactive | < 200ms |
| API Response | p95 latency | < 100ms |
| WebSocket | Message latency | < 50ms |
| MQTT | Publish latency | < 30ms |
| RAM Usage | Total consumption | < 100MB |
| CPU Usage | Idle percentage | > 80% |

## 🔌 Integrações

### ESP32 Devices
```json
{
  "protocol": "MQTT",
  "format": "JSON",
  "topics": {
    "discovery": "autocore/devices/announce",
    "status": "autocore/devices/{id}/status",
    "command": "autocore/devices/{id}/command",
    "config": "autocore/devices/{id}/config"
  }
}
```

### FuelTech ECU
```json
{
  "protocol": "CAN Bus",
  "baudrate": 500000,
  "format": "Binary",
  "signals": "Mapped via DBC file"
}
```

## 📦 Deployment

### Desenvolvimento
```bash
# Local development
make dev
# Acessa em http://localhost:8000
```

### Produção
```bash
# Deploy to Raspberry Pi
make deploy
# Gerenciado por PM2
# Proxy reverso com Nginx (opcional)
```

### Containerização (Opcional)
```dockerfile
# Multi-stage build
FROM python:3.11-slim as backend
FROM nginx:alpine as frontend
```

## 🔄 Padrões de Design

### Frontend Patterns
- **Component-based** - Componentes reutilizáveis
- **State Management** - Alpine.store para estado global
- **Event-driven** - Comunicação via eventos

### Backend Patterns
- **Repository Pattern** - Abstração do data access
- **Service Layer** - Lógica de negócio isolada
- **Dependency Injection** - FastAPI DI system
- **Factory Pattern** - Criação de objetos complexos

### Communication Patterns
- **Pub/Sub** - MQTT para comunicação assíncrona
- **Request/Response** - REST API para operações CRUD
- **Push Notifications** - WebSocket para real-time

## 🎨 Decisões Arquiteturais

### ADR-001: SQLite como Database
**Decisão:** Usar SQLite em vez de PostgreSQL/MySQL
**Razão:** Simplicidade, zero configuração, adequado para Pi Zero
**Consequências:** Limitado a um servidor, mas adequado para o caso de uso

### ADR-002: Sem Build Process no Frontend
**Decisão:** Usar CDNs e evitar bundlers
**Razão:** Simplicidade de desenvolvimento e deploy
**Consequências:** Menos otimização, mas desenvolvimento mais rápido

### ADR-003: MQTT para Comunicação com Dispositivos
**Decisão:** MQTT em vez de HTTP direto
**Razão:** Protocolo leve, suporta pub/sub, reconexão automática
**Consequências:** Necessita broker MQTT, mas oferece melhor confiabilidade

### ADR-004: Alpine.js para Reatividade
**Decisão:** Alpine.js em vez de React/Vue
**Razão:** Sem build, leve, simples de aprender
**Consequências:** Menos recursos que frameworks maiores, mas adequado

## 📚 Referências

- [FastAPI Best Practices](https://fastapi.tiangolo.com/tutorial/best-practices/)
- [Alpine.js Documentation](https://alpinejs.dev/start-here)
- [MQTT Essentials](https://www.hivemq.com/mqtt-essentials/)
- [SQLite Optimization](https://www.sqlite.org/optoverview.html)

---

**Última Atualização:** 07 de Agosto de 2025  
**Arquiteto:** Lee Chardes  
**Versão:** 1.0.0