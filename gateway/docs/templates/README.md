# 📝 Templates - Gateway AutoCore

## 🎯 Visão Geral

Templates para documentação e código do Gateway AutoCore.

## 📖 Templates Disponíveis

### Documentação
- [SERVICE-TEMPLATE.md](SERVICE-TEMPLATE.md) - Template para documentar serviços
- [API-ENDPOINT-TEMPLATE.md](API-ENDPOINT-TEMPLATE.md) - Template para endpoints
- [INTEGRATION-TEMPLATE.md](INTEGRATION-TEMPLATE.md) - Template para integrações

### Código
- [MQTT-HANDLER-TEMPLATE.py](MQTT-HANDLER-TEMPLATE.py) - Template handler MQTT
- [SERVICE-CLASS-TEMPLATE.py](SERVICE-CLASS-TEMPLATE.py) - Template classe de serviço
- [API-ROUTE-TEMPLATE.py](API-ROUTE-TEMPLATE.py) - Template rota API

### Configuração
- [CONFIG-TEMPLATE.yaml](CONFIG-TEMPLATE.yaml) - Template de configuração
- [DOCKER-COMPOSE-TEMPLATE.yml](DOCKER-COMPOSE-TEMPLATE.yml) - Template Docker

## 🎨 Como Usar

1. Escolha o template apropriado
2. Copie para o local desejado
3. Substitua os placeholders
4. Adapte ao contexto específico
5. Revise antes de commitar

## 📋 Estrutura Padrão de Serviço

```python
class ServiceTemplate:
    """Template para novo serviço"""
    
    def __init__(self, config):
        self.config = config
        self.logger = get_logger(__name__)
        
    async def start(self):
        """Inicializa o serviço"""
        pass
        
    async def stop(self):
        """Para o serviço gracefully"""
        pass
        
    async def health_check(self):
        """Verifica saúde do serviço"""
        return {"status": "healthy"}
```

---

**Última atualização**: 27/01/2025