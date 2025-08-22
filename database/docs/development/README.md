# 🛠️ Development Guide

Guia completo para desenvolvimento com o banco de dados AutoCore - setup, workflows e melhores práticas.

## 📋 Visão Geral

Este guia orienta desenvolvedores no uso eficiente do sistema de banco de dados AutoCore, desde o setup inicial até workflows avançados com SQLAlchemy e Alembic.

### 🎯 Para Quem é Este Guia
- Desenvolvedores novos no projeto
- Contributors externos
- Equipe de desenvolvimento
- DevOps engineers

## 🚀 Quick Start

### 1. Environment Setup
```bash
# Clone do projeto
git clone https://github.com/leechardes/AutoCore
cd AutoCore/database

# Setup do ambiente virtual
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# ou .venv\Scripts\activate  # Windows

# Instalar dependências
pip install -r requirements.txt
```

### 2. Database Initialization
```bash
# Aplicar migrations
alembic upgrade head

# Popular dados de desenvolvimento
python seeds/seed_development.py

# Verificar setup
python -c "from src.models.models import get_session; print('✅ Database OK')"
```

### 3. Verification
```bash
# Verificar tabelas criadas
python scripts/test_repositories.py

# Ver dados populados
sqlite3 autocore.db ".tables"
sqlite3 autocore.db "SELECT COUNT(*) FROM devices;"
```

## 📚 Development Workflows

### 🔄 [Alembic Workflow](./alembic-workflow.md)
Processo completo para criar e gerenciar migrations:
- Model changes → Migration generation
- Testing migrations
- Rollback procedures

### 🏗️ [SQLAlchemy Guide](./sqlalchemy-guide.md)
Padrões e melhores práticas:
- Model definition patterns
- Query optimization
- Session management
- Repository patterns

### 🌱 [Seed Data](./seed-data.md)
Gerenciamento de dados de teste:
- Development seeds
- Test data generation
- Environment-specific data

### 🧪 [Testing Database](./testing-database.md)
Estratégias de teste:
- Unit tests para models
- Integration tests
- Migration testing
- Performance testing

### 🔧 [Getting Started](./getting-started.md)
Setup detalhado passo-a-passo:
- Prerequisites
- Installation guide
- Configuration
- First steps

## 🎯 Development Patterns

### Model Development
```python
# 1. Definir model seguindo template
class NewModel(Base):
    __tablename__ = 'new_models'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100), unique=True, nullable=False)
    # ... outros campos

# 2. Gerar migration
alembic revision --autogenerate -m "add new_model table"

# 3. Revisar e ajustar migration
# 4. Aplicar migration
alembic upgrade head

# 5. Criar repository
class NewModelRepository(BaseRepository):
    # Implementar métodos específicos
    pass

# 6. Escrever testes
class TestNewModel:
    def test_create_model(self):
        # Implementar testes
        pass
```

### Query Development
```python
# Prefer repository patterns
repo = DeviceRepository(session)
devices = repo.get_active_devices()

# Avoid direct model queries in business logic
# devices = session.query(Device).filter_by(is_active=True).all()  # ❌

# Use eager loading for relationships
devices = session.query(Device).options(
    joinedload(Device.relay_boards).joinedload(RelayBoard.channels)
).all()

# Monitor query performance
from sqlalchemy import event
from sqlalchemy.engine import Engine
import time

@event.listens_for(Engine, "before_cursor_execute")
def receive_before_cursor_execute(conn, cursor, statement, parameters, context, executemany):
    context._query_start_time = time.time()

@event.listens_for(Engine, "after_cursor_execute") 
def receive_after_cursor_execute(conn, cursor, statement, parameters, context, executemany):
    total = time.time() - context._query_start_time
    if total > 0.1:  # Log slow queries
        logger.warning(f"Slow query: {total:.2f}s - {statement[:100]}")
```

### Migration Development
```python
# Always use batch_alter_table for SQLite
def upgrade() -> None:
    with op.batch_alter_table('table_name') as batch_op:
        batch_op.add_column(Column('new_field', String(50)))
        batch_op.create_index('idx_new_field', ['new_field'])

def downgrade() -> None:
    with op.batch_alter_table('table_name') as batch_op:
        batch_op.drop_index('idx_new_field')
        batch_op.drop_column('new_field')

# Test both upgrade and downgrade
# alembic upgrade head
# alembic downgrade -1
# alembic upgrade head
```

## 🔧 Development Tools

### CLI Commands
```bash
# Database management
python src/cli/manage.py init-db          # Initialize database
python src/cli/manage.py seed-dev         # Populate dev data
python src/cli/manage.py backup           # Create backup
python src/cli/manage.py validate         # Validate schema

# Migration helpers
python src/cli/manage.py check-models     # Check for model changes
python src/cli/manage.py test-migration   # Test migration rollback
```

### Debug Tools
```python
# Enable SQL logging
engine = create_engine(
    'sqlite:///autocore.db',
    echo=True  # Shows all SQL queries
)

# Query profiling
from sqlalchemy.orm import Query
original_all = Query.__iter__

def debug_sql(self):
    print(f"Executing: {self}")
    return original_all(self)

Query.__iter__ = debug_sql
```

### Performance Monitoring
```python
# Query performance middleware
class QueryTimer:
    def __init__(self, threshold=0.1):
        self.threshold = threshold
    
    def __enter__(self):
        self.start = time.time()
        return self
    
    def __exit__(self, *args):
        duration = time.time() - self.start
        if duration > self.threshold:
            print(f"⚠️ Slow query detected: {duration:.3f}s")

# Usage
with QueryTimer():
    devices = session.query(Device).all()
```

## 📋 Code Quality

### Linting & Formatting
```bash
# Code formatting
black src/ --line-length 100
isort src/ --profile black

# Type checking
mypy src/ --ignore-missing-imports

# Code quality
flake8 src/ --max-line-length 100
pylint src/ --disable=missing-docstring
```

### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/psf/black
    rev: 22.3.0
    hooks:
      - id: black
        language_version: python3
        
  - repo: https://github.com/pycqa/isort
    rev: 5.10.1
    hooks:
      - id: isort
        
  - repo: https://github.com/pycqa/flake8
    rev: 4.0.1
    hooks:
      - id: flake8
```

### Testing Standards
```python
# Test naming convention
def test_create_device_with_valid_data():
    """Test device creation with all required fields"""
    pass

def test_create_device_missing_uuid_raises_error():
    """Test device creation fails without UUID"""
    pass

# Test organization
class TestDeviceModel:
    """Tests for Device model"""
    
    def test_creation(self):
        pass
    
    def test_validation(self):
        pass
    
    def test_relationships(self):
        pass

class TestDeviceRepository:
    """Tests for Device repository"""
    
    def test_crud_operations(self):
        pass
    
    def test_query_methods(self):
        pass
```

## 🐛 Debugging

### Common Issues
```python
# Issue: N+1 Query Problem
# Bad
devices = session.query(Device).all()
for device in devices:
    print(device.relay_boards)  # N+1 queries

# Good
devices = session.query(Device).options(
    joinedload(Device.relay_boards)
).all()

# Issue: Session Management
# Bad
def get_device():
    session = get_session()
    device = session.query(Device).first()
    # Session never closed
    return device

# Good
def get_device():
    session = get_session()
    try:
        device = session.query(Device).first()
        return device
    finally:
        session.close()

# Or use context manager
with get_session() as session:
    device = session.query(Device).first()
```

### Debug Techniques
```python
# SQL query inspection
query = session.query(Device).filter_by(status='online')
print(str(query))  # Shows compiled SQL

# Relationship loading inspection
from sqlalchemy import inspect
device = session.query(Device).first()
state = inspect(device)
print(state.attrs.relay_boards.loaded_value)  # Check if loaded

# Transaction state
print(session.dirty)      # Modified objects
print(session.new)        # New objects
print(session.deleted)    # Deleted objects
```

## 🔗 External Resources

### Documentation
- [SQLAlchemy 2.0 Documentation](https://docs.sqlalchemy.org/en/20/)
- [Alembic Documentation](https://alembic.sqlalchemy.org/)
- [SQLite Documentation](https://sqlite.org/docs.html)
- [PostgreSQL Documentation](https://postgresql.org/docs/)

### Tools
- [DB Browser for SQLite](https://sqlitebrowser.org/)
- [pgAdmin](https://pgadmin.org/) (for PostgreSQL)
- [DataGrip](https://jetbrains.com/datagrip/) (IDE)
- [DBeaver](https://dbeaver.io/) (Free DB client)

### Learning Resources
- [SQLAlchemy Tutorial](https://docs.sqlalchemy.org/en/20/tutorial/)
- [Alembic Tutorial](https://alembic.sqlalchemy.org/en/latest/tutorial.html)
- [Database Design Principles](https://en.wikipedia.org/wiki/Database_design)

---

**Next Steps**: 
1. [Getting Started](./getting-started.md) - Detailed setup
2. [Alembic Workflow](./alembic-workflow.md) - Migration process
3. [SQLAlchemy Guide](./sqlalchemy-guide.md) - ORM patterns