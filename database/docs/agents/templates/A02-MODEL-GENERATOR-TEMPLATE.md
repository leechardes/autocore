# 🤖 A02-MODEL-GENERATOR - Template para Gerador de Models

## 📋 Objetivo

Template para criação de agentes que geram automaticamente models SQLAlchemy baseados em especificações.

## 🎯 Tarefas

1. Analisar especificação de entidade
2. Gerar model SQLAlchemy
3. Criar relacionamentos apropriados
4. Adicionar validações necessárias
5. Gerar repository correspondente
6. Criar testes unitários

## 🔧 Comandos

```python
# Estrutura base do model
class EntityModel(BaseModel):
    __tablename__ = 'entities'
    
    # Campos da entidade
    name = Column(String(100), nullable=False)
    
    # Relacionamentos
    items = relationship("ItemModel", back_populates="entity")

# Repository correspondente
class EntityRepository(BaseRepository[EntityModel]):
    pass
```

## ✅ Checklist de Validação

- [ ] Especificação analisada
- [ ] Model gerado com campos corretos
- [ ] Relacionamentos configurados
- [ ] Validações implementadas
- [ ] Repository criado
- [ ] Testes unitários gerados
- [ ] Documentação atualizada

## 📊 Resultado Esperado

Model SQLAlchemy completo e funcional com repository e testes.