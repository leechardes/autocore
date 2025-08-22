"""
Template para testes de database no AutoCore
Este template cobre testes de models, repositories e migrations

ESTRUTURA DE TESTES:
- test_models.py: Testes dos SQLAlchemy models
- test_repositories.py: Testes dos repositories  
- test_migrations.py: Testes das migrations Alembic
- conftest.py: Fixtures compartilhadas

EXECUTAR TESTES:
pytest database/tests/
pytest database/tests/test_models.py -v
pytest database/tests/test_repositories.py::TestNewModelRepository -v
"""

import pytest
import tempfile
import os
from datetime import datetime, timedelta
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import IntegrityError

# Imports do projeto
from src.models.models import Base, get_engine, get_session
# from src.repositories.new_model_repository import NewModelRepository

# ====================================
# FIXTURES (conftest.py)
# ====================================

@pytest.fixture(scope="session")
def test_engine():
    """
    Create test database engine
    
    Usa SQLite em memória para testes rápidos
    """
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        echo=False  # True para debug SQL
    )
    
    # Criar todas as tabelas
    Base.metadata.create_all(engine)
    
    return engine

@pytest.fixture(scope="function")
def test_session(test_engine):
    """
    Create test session with rollback
    
    Cada teste roda em uma transação que é revertida
    """
    Session = sessionmaker(bind=test_engine)
    session = Session()
    
    # Start transaction
    transaction = session.begin()
    
    yield session
    
    # Rollback transaction (cleanup)
    transaction.rollback()
    session.close()

@pytest.fixture
def sample_data(test_session):
    """
    Create sample data for tests
    
    Dados de exemplo que podem ser usados em múltiplos testes
    """
    from src.models.models import NewModel
    
    items = []
    
    # Create sample items
    for i in range(3):
        item = NewModel(
            name=f"test_item_{i}",
            title=f"Test Item {i}",
            type="type_a",
            description=f"Description for item {i}",
            is_active=True
        )
        test_session.add(item)
        items.append(item)
    
    # Create inactive item
    inactive_item = NewModel(
        name="inactive_item",
        title="Inactive Item",
        type="type_b",
        is_active=False
    )
    test_session.add(inactive_item)
    items.append(inactive_item)
    
    test_session.flush()  # Get IDs without committing
    return items

# ====================================
# MODEL TESTS
# ====================================

class TestNewModel:
    """
    Testes para o model NewModel
    
    Testa criação, validação, constraints e relationships
    """
    
    def test_create_model(self, test_session):
        """Test basic model creation"""
        from src.models.models import NewModel
        
        item = NewModel(
            name="test_create",
            title="Test Create",
            type="type_a",
            is_active=True
        )
        
        test_session.add(item)
        test_session.flush()
        
        assert item.id is not None
        assert item.name == "test_create"
        assert item.title == "Test Create"
        assert item.type == "type_a"
        assert item.is_active is True
        assert item.created_at is not None
        assert item.updated_at is not None
    
    def test_unique_constraint(self, test_session):
        """Test unique constraint on name"""
        from src.models.models import NewModel
        
        # First item
        item1 = NewModel(name="duplicate_name", title="Item 1", type="type_a")
        test_session.add(item1)
        test_session.flush()
        
        # Second item with same name should fail
        item2 = NewModel(name="duplicate_name", title="Item 2", type="type_a")
        test_session.add(item2)
        
        with pytest.raises(IntegrityError):
            test_session.flush()
    
    def test_check_constraint(self, test_session):
        """Test check constraint on type field"""
        from src.models.models import NewModel
        
        # Valid type should work
        valid_item = NewModel(name="valid_type", title="Valid", type="type_a")
        test_session.add(valid_item)
        test_session.flush()  # Should not raise
        
        # Invalid type should fail
        invalid_item = NewModel(name="invalid_type", title="Invalid", type="invalid_type")
        test_session.add(invalid_item)
        
        with pytest.raises(IntegrityError):
            test_session.flush()
    
    def test_soft_delete(self, test_session):
        """Test soft delete functionality"""
        from src.models.models import NewModel
        
        item = NewModel(name="to_delete", title="To Delete", type="type_a", is_active=True)
        test_session.add(item)
        test_session.flush()
        
        # Soft delete
        item.is_active = False
        test_session.flush()
        
        # Verify still exists but inactive
        found = test_session.get(NewModel, item.id)
        assert found is not None
        assert found.is_active is False
    
    def test_auto_timestamps(self, test_session):
        """Test automatic timestamp generation"""
        from src.models.models import NewModel
        
        # Create item
        item = NewModel(name="timestamp_test", title="Timestamp", type="type_a")
        test_session.add(item)
        test_session.flush()
        
        created_at = item.created_at
        updated_at = item.updated_at
        
        assert created_at is not None
        assert updated_at is not None
        assert created_at == updated_at  # Should be same on creation
        
        # Update item
        import time
        time.sleep(0.1)  # Ensure different timestamp
        item.title = "Updated Title"
        test_session.flush()
        
        assert item.updated_at > updated_at  # Should be newer
        assert item.created_at == created_at  # Should not change
    
    def test_relationships(self, test_session):
        """Test model relationships"""
        from src.models.models import NewModel
        
        # Create parent
        parent = NewModel(name="parent", title="Parent", type="type_a")
        test_session.add(parent)
        test_session.flush()
        
        # Create children
        child1 = NewModel(name="child1", title="Child 1", type="type_a", parent_id=parent.id)
        child2 = NewModel(name="child2", title="Child 2", type="type_a", parent_id=parent.id)
        test_session.add_all([child1, child2])
        test_session.flush()
        
        # Test relationships
        assert len(parent.children) == 2
        assert child1.parent == parent
        assert child2.parent == parent

# ====================================
# REPOSITORY TESTS
# ====================================

class TestNewModelRepository:
    """
    Testes para NewModelRepository
    
    Testa operações CRUD e métodos específicos do domínio
    """
    
    @pytest.fixture
    def repository(self, test_session):
        """Create repository instance for tests"""
        return NewModelRepository(test_session)
    
    def test_create(self, repository):
        """Test repository create method"""
        item = repository.create(
            name="repo_create",
            title="Repository Create",
            type="type_a",
            is_active=True
        )
        
        assert item.id is not None
        assert item.name == "repo_create"
        assert item.title == "Repository Create"
    
    def test_get_by_id(self, repository, sample_data):
        """Test get by ID"""
        item = sample_data[0]
        found = repository.get_by_id(item.id)
        
        assert found is not None
        assert found.id == item.id
        assert found.name == item.name
    
    def test_get_by_name(self, repository, sample_data):
        """Test get by unique name"""
        item = sample_data[0]
        found = repository.get_by_name(item.name)
        
        assert found is not None
        assert found.id == item.id
        assert found.name == item.name
    
    def test_get_by_type(self, repository, sample_data):
        """Test get by type"""
        type_a_items = repository.get_by_type("type_a")
        type_b_items = repository.get_by_type("type_b")
        
        # Should include active items only by default
        assert len(type_a_items) == 3  # 3 active type_a items
        assert len(type_b_items) == 0  # 1 type_b item but inactive
        
        # Test with inactive included
        type_b_all = repository.get_by_type("type_b", active_only=False)
        assert len(type_b_all) == 1
    
    def test_get_active(self, repository, sample_data):
        """Test get active items only"""
        active_items = repository.get_active()
        
        # Should only return active items (3 out of 4)
        assert len(active_items) == 3
        for item in active_items:
            assert item.is_active is True
    
    def test_update(self, repository, sample_data):
        """Test update method"""
        item = sample_data[0]
        original_updated_at = item.updated_at
        
        import time
        time.sleep(0.1)
        
        updated = repository.update(item.id, title="Updated Title")
        
        assert updated is not None
        assert updated.title == "Updated Title"
        assert updated.updated_at > original_updated_at
    
    def test_delete(self, repository, sample_data):
        """Test hard delete"""
        item = sample_data[0]
        item_id = item.id
        
        result = repository.delete(item_id)
        assert result is True
        
        # Should not be found after deletion
        found = repository.get_by_id(item_id)
        assert found is None
    
    def test_soft_delete(self, repository, sample_data):
        """Test soft delete"""
        item = sample_data[0]
        item_id = item.id
        
        result = repository.soft_delete(item_id)
        assert result is True
        
        # Should still exist but inactive
        found = repository.get_by_id(item_id)
        assert found is not None
        assert found.is_active is False
    
    def test_search_by_name(self, repository, sample_data):
        """Test name search functionality"""
        results = repository.search_by_name("test_item")
        
        # Should find items with "test_item" in name
        assert len(results) >= 3
        for item in results:
            assert "test_item" in item.name.lower()
    
    def test_statistics(self, repository, sample_data):
        """Test statistics generation"""
        stats = repository.get_statistics()
        
        assert stats['total'] == 4  # 4 items total
        assert stats['active'] == 3  # 3 active items
        assert stats['inactive'] == 1  # 1 inactive item
        assert 'by_type' in stats
        assert stats['by_type']['type_a'] == 3
        assert stats['by_type']['type_b'] == 1
    
    def test_bulk_operations(self, repository):
        """Test bulk create and update"""
        # Bulk create
        bulk_data = [
            {"name": "bulk_1", "title": "Bulk 1", "type": "type_a"},
            {"name": "bulk_2", "title": "Bulk 2", "type": "type_a"},
            {"name": "bulk_3", "title": "Bulk 3", "type": "type_b"},
        ]
        
        created = repository.bulk_create(bulk_data)
        assert len(created) == 3
        
        # Bulk update by type
        updated_count = repository.bulk_update_by_type("type_a", description="Bulk updated")
        assert updated_count == 2  # 2 type_a items
        
        # Verify updates
        type_a_items = repository.get_by_type("type_a")
        for item in type_a_items:
            assert item.description == "Bulk updated"
    
    def test_validation(self, repository, sample_data):
        """Test validation methods"""
        item = sample_data[0]
        
        # Test unique name validation
        assert repository.validate_unique_name("new_unique_name") is True
        assert repository.validate_unique_name(item.name) is False
        assert repository.validate_unique_name(item.name, exclude_id=item.id) is True
        
        # Test can delete
        can_delete, reason = repository.can_delete(item.id)
        assert can_delete is True
        assert reason == "Can be deleted"

# ====================================
# MIGRATION TESTS
# ====================================

class TestMigrations:
    """
    Testes para migrations Alembic
    
    Testa aplicação e rollback das migrations
    """
    
    def test_migration_up_down(self):
        """Test migration upgrade and downgrade"""
        # Este teste requer setup especial com Alembic
        # Exemplo de estrutura:
        
        # 1. Create temporary database
        # 2. Run migration upgrade
        # 3. Verify schema changes
        # 4. Run migration downgrade  
        # 5. Verify rollback
        
        pass  # Implementar conforme necessário
    
    def test_data_migration(self):
        """Test data transformation in migrations"""
        # Teste específico para migrations que transformam dados
        pass

# ====================================
# INTEGRATION TESTS
# ====================================

class TestDatabaseIntegration:
    """
    Testes de integração com database real
    
    Estes testes usam database temporário real
    """
    
    @pytest.fixture
    def real_db_session(self):
        """Create session with real SQLite file"""
        with tempfile.NamedTemporaryFile(suffix='.db', delete=False) as tmp:
            db_path = tmp.name
        
        try:
            engine = create_engine(f"sqlite:///{db_path}")
            Base.metadata.create_all(engine)
            
            Session = sessionmaker(bind=engine)
            session = Session()
            
            yield session
            
            session.close()
        finally:
            os.unlink(db_path)
    
    def test_concurrent_access(self, real_db_session):
        """Test concurrent database access"""
        # Teste de concorrência (limitado no SQLite)
        pass
    
    def test_large_dataset(self, real_db_session):
        """Test performance with large dataset"""
        from src.models.models import NewModel
        
        # Create many records
        records = []
        for i in range(1000):
            record = NewModel(
                name=f"perf_test_{i}",
                title=f"Performance Test {i}",
                type="type_a" if i % 2 == 0 else "type_b"
            )
            records.append(record)
        
        real_db_session.add_all(records)
        real_db_session.commit()
        
        # Test query performance
        import time
        start = time.time()
        
        result = real_db_session.query(NewModel).filter_by(type="type_a").count()
        
        duration = time.time() - start
        
        assert result == 500  # Half should be type_a
        assert duration < 1.0  # Should be fast

# ====================================
# UTILITY FUNCTIONS
# ====================================

def assert_model_equal(model1, model2, exclude_fields=None):
    """
    Helper to compare two model instances
    
    Args:
        model1: First model instance
        model2: Second model instance  
        exclude_fields: Fields to exclude from comparison
    """
    exclude_fields = exclude_fields or ['id', 'created_at', 'updated_at']
    
    for column in model1.__table__.columns:
        field_name = column.name
        if field_name in exclude_fields:
            continue
        
        value1 = getattr(model1, field_name)
        value2 = getattr(model2, field_name)
        
        assert value1 == value2, f"Field {field_name} differs: {value1} != {value2}"

def create_test_data(session, model_class, count=5, **defaults):
    """
    Helper to create test data
    
    Args:
        session: Database session
        model_class: Model class to create
        count: Number of instances to create
        **defaults: Default field values
        
    Returns:
        List of created instances
    """
    instances = []
    
    for i in range(count):
        data = defaults.copy()
        data.update({
            'name': f"test_{model_class.__name__.lower()}_{i}",
            'title': f"Test {model_class.__name__} {i}"
        })
        
        instance = model_class(**data)
        session.add(instance)
        instances.append(instance)
    
    session.flush()
    return instances

# ====================================
# PERFORMANCE HELPERS
# ====================================

def measure_query_time(session, query_func):
    """
    Measure query execution time
    
    Args:
        session: Database session
        query_func: Function that executes query
        
    Returns:
        Tuple of (result, duration_seconds)
    """
    import time
    
    start = time.time()
    result = query_func(session)
    duration = time.time() - start
    
    return result, duration

# ====================================
# RUNNING TESTS
# ====================================

if __name__ == '__main__':
    """
    Run tests directly
    
    Para executar testes completos, use:
    pytest database/tests/ -v
    """
    import subprocess
    import sys
    
    try:
        result = subprocess.run([
            sys.executable, '-m', 'pytest', 
            'database/tests/', '-v'
        ], capture_output=True, text=True)
        
        print(result.stdout)
        if result.stderr:
            print(result.stderr)
            
        sys.exit(result.returncode)
        
    except FileNotFoundError:
        print("pytest not found. Install with: pip install pytest")
        sys.exit(1)

# ====================================
# PYTEST CONFIGURATION
# ====================================

"""
pytest.ini example:

[tool:pytest]
testpaths = database/tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = 
    -v
    --tb=short
    --strict-markers
    --disable-warnings
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    integration: marks tests as integration tests
    unit: marks tests as unit tests
"""