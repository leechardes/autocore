# AutoCore Config-App Backend - Documentação

Documentação completa do backend da aplicação de configuração do sistema AutoCore.

## 📋 Sobre o Projeto

O **Config-App Backend** é uma API REST desenvolvida em **FastAPI** que serve como interface de configuração e gerenciamento para o ecossistema AutoCore. O sistema permite configurar dispositivos ESP32, gerenciar interfaces de usuário, monitorar telemetria e controlar relés de forma centralizada.

### Versão da API: 2.0.0
### Versão da Documentação: 1.0.0

## 🚀 Características Principais

- **API REST Completa**: 50+ endpoints para gerenciamento completo
- **WebSocket em Tempo Real**: Streaming de dados MQTT e telemetria
- **Suporte Multi-Dispositivo**: ESP32 Display, ESP32 Relay, HMI
- **Interface de Configuração**: Telas, temas e componentes UI
- **Sistema de Relés**: Controle de placas e canais
- **Monitoramento MQTT**: Cliente integrado para comunicação IoT
- **Telemetria Avançada**: Coleta e análise de dados em tempo real
- **Banco Compartilhado**: Integração com database centralizado

## 🛠️ Tecnologias

- **Python 3.10+**
- **FastAPI 0.104.1** - Framework web moderno
- **SQLAlchemy 2.0.23** - ORM para banco de dados
- **Pydantic 2.5.2** - Validação de dados
- **MQTT (paho-mqtt)** - Comunicação IoT
- **WebSocket** - Streaming em tempo real
- **Uvicorn** - Servidor ASGI
- **Docker** - Containerização

## 📖 Documentação

### 🏗️ Arquitetura
- [Visão Geral do Sistema](architecture/system-overview.md)
- [Schema do Banco de Dados](architecture/database-schema.md)
- [Diagrama de Componentes](architecture/component-diagram.md)
- [Diagramas de Sequência](architecture/sequence-diagrams.md)

### 🔌 API
- [Documentação da API](api/README.md)
- [Endpoints - Autenticação](api/endpoints/auth.md)
- [Endpoints - Dispositivos](api/endpoints/devices.md)
- [Endpoints - Telas](api/endpoints/screens.md)
- [Endpoints - Comandos](api/endpoints/commands.md)
- [Schemas de Request](api/schemas/request-schemas.md)
- [Schemas de Response](api/schemas/response-schemas.md)

### 🚀 Deployment
- [Configuração Docker](deployment/docker-setup.md)
- [Deploy com Kubernetes](deployment/kubernetes.md)
- [Variáveis de Ambiente](deployment/environment-variables.md)
- [Checklist de Produção](deployment/production-checklist.md)

### 👩‍💻 Desenvolvimento
- [Como Começar](development/getting-started.md)
- [Setup Local](development/local-setup.md)
- [Padrões de Código](development/coding-standards.md)
- [Guia de Testes](development/testing-guide.md)
- [Como Contribuir](development/contributing.md)

### 📘 Guias
- [Guia de Autenticação](guides/authentication-guide.md)
- [WebSocket e Streaming](guides/websocket-guide.md)
- [Integração MQTT](guides/mqtt-integration.md)
- [Migrações de Banco](guides/database-migrations.md)

### 🔒 Segurança
- [Políticas de Segurança](security/security-policies.md)
- [Autenticação](security/authentication.md)
- [Autorização](security/authorization.md)
- [Melhores Práticas](security/best-practices.md)

### 🔧 Troubleshooting
- [Erros Comuns](troubleshooting/common-errors.md)
- [Guia de Debug](troubleshooting/debugging-guide.md)
- [FAQ](troubleshooting/faq.md)

## 🏃‍♂️ Início Rápido

```bash
# Instalar dependências
pip install -r requirements.txt

# Configurar variáveis de ambiente
cp .env.example .env

# Executar servidor de desenvolvimento
uvicorn main:app --host 0.0.0.0 --port 8081 --reload
```

A API estará disponível em `http://localhost:8081`

### Documentação Interativa
- **Swagger UI**: http://localhost:8081/docs
- **ReDoc**: http://localhost:8081/redoc

## 📊 Endpoints Principais

| Grupo | Endpoint | Descrição |
|-------|----------|-----------|
| **Sistema** | `GET /api/status` | Status do sistema |
| **Dispositivos** | `GET /api/devices` | Lista dispositivos |
| **Telas** | `GET /api/screens` | Configuração de UI |
| **Relés** | `GET /api/relays/channels` | Controle de relés |
| **Telemetria** | `GET /api/telemetry/{id}` | Dados de sensores |
| **MQTT** | `WebSocket /ws/mqtt` | Streaming em tempo real |

## 🤝 Contribuição

Para contribuir com o projeto:

1. Leia o [Guia de Contribuição](development/contributing.md)
2. Siga os [Padrões de Código](development/coding-standards.md)
3. Execute os testes com `pytest`
4. Documente suas mudanças

## 📄 Licença

Este projeto faz parte do ecossistema AutoCore e segue as políticas de licenciamento internas.

## 📞 Suporte

- **Documentação**: Consulte os guias específicos
- **Issues**: Reporte bugs e sugestões no sistema interno
- **Contato**: Equipe AutoCore

---

*Última atualização: 22/01/2025*
*Versão da documentação: 1.0.0*