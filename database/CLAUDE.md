# 🤖 Instruções para Claude - Database AutoCore

Este documento contém instruções específicas para assistentes IA trabalharem com o projeto Database do AutoCore.

## 🎯 Visão Geral

O projeto Database é o **owner** do banco de dados SQLite do sistema AutoCore. Ele fornece:
- Schema e migrations centralizadas
- Repository Pattern compartilhado
- Scripts de manutenção automática
- Ferramentas CLI para gerenciamento

## 📁 Estrutura do Projeto

```
database/
├── src/                 # Código fonte organizado
│   ├── cli/            # Ferramentas de linha de comando
│   ├── models/         # Modelos SQLAlchemy (fonte de verdade)
│   └── migrations/     # Auto-migration com Alembic
├── shared/              # Repository Pattern (usado por gateway e config-app)
├── migrations/          # Migrations SQL manuais
├── seeds/               # Dados iniciais
├── scripts/             # Scripts de manutenção
└── docs/                # Documentação completa
```

## 🛠️ Tecnologias

- **SQLite 3**: Banco de dados leve e embutido
- **SQLAlchemy**: ORM e definição de models
- **Alembic**: Auto-migration baseada em models
- **Python 3.9+**: Linguagem principal
- **Click**: CLI framework

## 📝 Convenções de Código

### Models (SQLAlchemy)

```python
class Device(Base):
    """Dispositivos ESP32 do sistema"""
    __tablename__ = 'devices'
    
    id = Column(Integer, primary_key=True)
    uuid = Column(String(36), unique=True, nullable=False)
    # ...
    
    # Índices para performance
    __table_args__ = (
        Index('idx_devices_uuid', 'uuid'),
    )
```

### Repository Pattern

```python
class DeviceRepository(BaseRepository):
    def get_all(self) -> List[Dict]:
        """Retorna todos os dispositivos"""
        # Implementação com tratamento de erros
        
    def update_status(self, device_id: int, status: str):
        """Atualiza status do dispositivo"""
        # Validação + update + commit
```

## 🔄 Workflow de Desenvolvimento

### 1. Modificar Models

```python
# src/models/models.py
class Device(Base):
    # Adicionar novo campo
    new_field = Column(String(100), nullable=True)
```

### 2. Gerar Migration Automática

```bash
# Gerar migration baseada nas mudanças dos models
python src/migrations/auto_migrate.py generate -m "Add new_field to devices"

# Ou gerar e aplicar diretamente
python src/migrations/auto_migrate.py auto -m "Add new_field"
```

### 3. Atualizar Repositories

```python
# shared/repositories.py
class DeviceRepository:
    def update_new_field(self, device_id: int, value: str):
        # Implementar método
```

## ⚠️ Regras Importantes

### SEMPRE

1. **Models são a fonte de verdade** - Toda mudança de schema começa nos models
2. **Use auto-migration** - Para mudanças de schema, use o sistema de auto-migration
3. **Mantenha retrocompatibilidade** - Repositories devem funcionar com versões antigas
4. **Documente mudanças** - Adicione comentários explicativos nos models
5. **Teste localmente** - Use `sync` para testar antes de gerar migrations

### NUNCA

1. **Não edite migrations aplicadas** - Crie novas migrations para correções
2. **Não delete models sem migration** - Sempre faça migration para remover
3. **Não faça queries diretas** - Use sempre os repositories
4. **Não commite autocore.db** - O banco é gerado localmente
5. **Não ignore erros de foreign key** - Mantenha integridade referencial

## 📊 Performance

### Otimizações para Raspberry Pi Zero 2W

1. **Índices estratégicos** - Crie índices apenas onde necessário
2. **WAL mode** - Já configurado para concorrência
3. **Batch operations** - Agrupe inserts/updates quando possível
4. **Limpeza automática** - Scripts removem dados antigos
5. **VACUUM periódico** - Desfragmentação automática

### Limites

- Tamanho máximo do banco: 50MB (com limpeza automática)
- Telemetria mantida: 7 dias (configurável)
- Logs mantidos: 30 dias
- Backup diário: Últimos 7 backups

## 🔧 Comandos Úteis

### Desenvolvimento

```bash
# Sincronizar banco com models (dev only)
python src/migrations/auto_migrate.py sync

# Ver status do banco
python src/cli/manage.py status

# Console SQL interativo
python src/cli/manage.py console
```

### Manutenção

```bash
# Limpeza manual
python src/cli/manage.py clean --days 3

# Ver estatísticas
python scripts/maintenance.py stats

# Manutenção completa
python scripts/maintenance.py full
```

### Backup

```bash
# Criar backup
python src/cli/manage.py backup

# Restaurar
python src/cli/manage.py restore --file backup.gz
```

## 📦 Integração com Outros Projetos

### Gateway e Config-App

Ambos projetos importam o Repository Pattern:

```python
# gateway/main.py ou config-app/backend/main.py
import sys
sys.path.append('../database')  # ou '../../database'

from shared.repositories import devices, telemetry, events

# Usar repositories
devices.update_status(1, 'online')
```

### Responsabilidades

| Projeto | Acesso | Operações |
|---------|--------|------------|
| Database | Owner | Migrations, schema, manutenção |
| Gateway | Read/Write | Telemetria, status, eventos |
| Config-App | Read/Write | Configurações, usuários, UI |

## 🔍 Debug e Troubleshooting

### Verificar Integridade

```bash
sqlite3 autocore.db "PRAGMA integrity_check"
```

### Ver Queries em Execução

```python
# Em src/models/models.py
engine = create_engine(..., echo=True)  # Ativa log de SQL
```

### Analisar Performance

```bash
sqlite3 autocore.db "EXPLAIN QUERY PLAN SELECT ..."
```

## 📖 Documentação Adicional

- `docs/architecture/DATABASE.md` - Arquitetura detalhada
- `docs/architecture/DATA_FLOW.md` - Fluxo de dados
- `docs/api/repositories.md` - API dos repositories
- `docs/guides/setup.md` - Guia de configuração
- `docs/guides/MAINTENANCE.md` - Guia de manutenção

## 💡 Dicas para IA

1. **Sempre verifique os models primeiro** - Eles definem a estrutura
2. **Use os repositories existentes** - Não reimplemente lógica
3. **Teste com dados pequenos** - Pi Zero tem recursos limitados
4. **Documente mudanças breaking** - Avise sobre incompatibilidades
5. **Mantenha simplicidade** - SQLite é simples por design

## 🆘 Suporte

Em caso de dúvidas:
1. Consulte a documentação em `docs/`
2. Verifique os logs em `event_logs`
3. Use o console SQL para investigação
4. Faça backup antes de mudanças críticas

---

**Última Atualização:** 07 de agosto de 2025  
**Versão:** 1.0.0  
**Maintainer:** Lee Chardes