# 📚 Development - Gateway AutoCore

## 🎯 Visão Geral

Guias de desenvolvimento para o Gateway AutoCore.

## 📖 Conteúdo

### Getting Started
- [GETTING-STARTED.md](GETTING-STARTED.md) - Como começar
- [ARCHITECTURE.md](ARCHITECTURE.md) - Arquitetura do sistema
- [CODING-STANDARDS.md](CODING-STANDARDS.md) - Padrões de código

### Componentes
- [MQTT-DEVELOPMENT.md](MQTT-DEVELOPMENT.md) - Desenvolvimento MQTT
- [API-DEVELOPMENT.md](API-DEVELOPMENT.md) - Desenvolvimento de APIs
- [DATABASE-DEVELOPMENT.md](DATABASE-DEVELOPMENT.md) - Trabalho com banco

### Testing
- [TESTING.md](TESTING.md) - Estratégia de testes
- [UNIT-TESTS.md](UNIT-TESTS.md) - Testes unitários
- [INTEGRATION-TESTS.md](INTEGRATION-TESTS.md) - Testes de integração

## 🛠️ Ambiente de Desenvolvimento

```bash
# Setup ambiente virtual
python -m venv venv
source venv/bin/activate

# Instalar em modo dev
pip install -e .
pip install -r requirements-dev.txt

# Rodar testes
pytest tests/

# Rodar com hot reload
python main.py --dev
```

## 📝 Workflow

1. Crie branch da feature
2. Desenvolva com TDD
3. Garanta 80%+ coverage
4. Documente mudanças
5. Abra PR com testes

---

**Última atualização**: 27/01/2025