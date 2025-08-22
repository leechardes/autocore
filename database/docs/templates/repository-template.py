"""
Template para criação de Repository classes no AutoCore
Este template implementa o Repository Pattern com SQLAlchemy

PROPÓSITO:
- Separar lógica de acesso a dados dos models
- Centralizar queries complexas
- Facilitar testes com mocks
- Padronizar operações CRUD

USO:
1. Herde de BaseRepository
2. Implemente métodos específicos do domínio
3. Use type hints para melhor IDE support
"""

from typing import List, Optional, Dict, Any, Type, TypeVar
from sqlalchemy.orm import Session, Query
from sqlalchemy.exc import IntegrityError
from sqlalchemy import and_, or_, desc, asc, func
from datetime import datetime, timedelta

# Import base classes
from src.models.models import Base

# Type variable para generic repository
T = TypeVar('T', bound=Base)

class BaseRepository:
    """
    Repository base com operações CRUD padrão
    
    Fornece funcionalidades básicas que podem ser herdadas
    por repositories específicos de cada model.
    """
    
    def __init__(self, session: Session, model_class: Type[T]):
        """
        Initialize repository with session and model class
        
        Args:
            session: SQLAlchemy session
            model_class: Model class (e.g., Device, RelayChannel)
        """
        self.session = session
        self.model_class = model_class
    
    # ====================================
    # BASIC CRUD OPERATIONS
    # ====================================
    
    def create(self, **kwargs) -> T:
        """
        Create new record
        
        Args:
            **kwargs: Field values for the new record
            
        Returns:
            Created model instance
            
        Raises:
            IntegrityError: If constraints are violated
        """
        instance = self.model_class(**kwargs)
        self.session.add(instance)
        try:
            self.session.flush()  # Get ID without committing
            return instance
        except IntegrityError as e:
            self.session.rollback()
            raise e
    
    def get_by_id(self, id: int) -> Optional[T]:
        """Get record by primary key"""
        return self.session.get(self.model_class, id)
    
    def get_all(self, limit: Optional[int] = None, offset: int = 0) -> List[T]:
        """
        Get all records with optional pagination
        
        Args:
            limit: Maximum number of records
            offset: Number of records to skip
            
        Returns:
            List of model instances
        """
        query = self.session.query(self.model_class)
        
        if offset > 0:
            query = query.offset(offset)
        
        if limit:
            query = query.limit(limit)
            
        return query.all()
    
    def update(self, id: int, **kwargs) -> Optional[T]:
        """
        Update record by ID
        
        Args:
            id: Record ID
            **kwargs: Fields to update
            
        Returns:
            Updated instance or None if not found
        """
        instance = self.get_by_id(id)
        if not instance:
            return None
        
        for key, value in kwargs.items():
            if hasattr(instance, key):
                setattr(instance, key, value)
        
        # Update timestamp if model has updated_at
        if hasattr(instance, 'updated_at'):
            instance.updated_at = datetime.now()
        
        self.session.flush()
        return instance
    
    def delete(self, id: int) -> bool:
        """
        Delete record by ID
        
        Args:
            id: Record ID
            
        Returns:
            True if deleted, False if not found
        """
        instance = self.get_by_id(id)
        if not instance:
            return False
        
        self.session.delete(instance)
        self.session.flush()
        return True
    
    def soft_delete(self, id: int) -> bool:
        """
        Soft delete (set is_active=False) if model supports it
        
        Args:
            id: Record ID
            
        Returns:
            True if soft deleted, False if not found or not supported
        """
        instance = self.get_by_id(id)
        if not instance or not hasattr(instance, 'is_active'):
            return False
        
        instance.is_active = False
        if hasattr(instance, 'updated_at'):
            instance.updated_at = datetime.now()
        
        self.session.flush()
        return True
    
    # ====================================
    # QUERY HELPERS
    # ====================================
    
    def get_active(self) -> List[T]:
        """Get all active records (if model has is_active field)"""
        if not hasattr(self.model_class, 'is_active'):
            return self.get_all()
        
        return self.session.query(self.model_class).filter_by(is_active=True).all()
    
    def count(self, **filters) -> int:
        """Count records with optional filters"""
        query = self.session.query(self.model_class)
        
        for key, value in filters.items():
            if hasattr(self.model_class, key):
                query = query.filter(getattr(self.model_class, key) == value)
        
        return query.count()
    
    def exists(self, **filters) -> bool:
        """Check if record exists with given filters"""
        query = self.session.query(self.model_class)
        
        for key, value in filters.items():
            if hasattr(self.model_class, key):
                query = query.filter(getattr(self.model_class, key) == value)
        
        return query.first() is not None
    
    def find_by(self, **filters) -> List[T]:
        """Find records by field filters"""
        query = self.session.query(self.model_class)
        
        for key, value in filters.items():
            if hasattr(self.model_class, key):
                if isinstance(value, list):
                    query = query.filter(getattr(self.model_class, key).in_(value))
                else:
                    query = query.filter(getattr(self.model_class, key) == value)
        
        return query.all()
    
    def find_one_by(self, **filters) -> Optional[T]:
        """Find single record by filters"""
        results = self.find_by(**filters)
        return results[0] if results else None

class NewModelRepository(BaseRepository):
    """
    Repository específico para NewModel
    
    Herda funcionalidades básicas e adiciona métodos específicos
    do domínio de negócio.
    """
    
    def __init__(self, session: Session):
        from src.models.models import NewModel  # Import do model específico
        super().__init__(session, NewModel)
    
    # ====================================
    # DOMAIN-SPECIFIC METHODS
    # ====================================
    
    def get_by_name(self, name: str) -> Optional['NewModel']:
        """Get record by unique name"""
        return self.session.query(self.model_class).filter_by(name=name).first()
    
    def get_by_type(self, type: str, active_only: bool = True) -> List['NewModel']:
        """
        Get records by type
        
        Args:
            type: Record type
            active_only: Filter only active records
            
        Returns:
            List of records matching type
        """
        query = self.session.query(self.model_class).filter_by(type=type)
        
        if active_only and hasattr(self.model_class, 'is_active'):
            query = query.filter_by(is_active=True)
        
        return query.order_by(self.model_class.name).all()
    
    def get_by_category(self, category: str) -> List['NewModel']:
        """Get records by category"""
        return self.session.query(self.model_class).filter_by(
            category=category,
            is_active=True
        ).order_by(self.model_class.name).all()
    
    def search_by_name(self, search_term: str, limit: int = 10) -> List['NewModel']:
        """
        Search records by name (partial match)
        
        Args:
            search_term: Text to search for
            limit: Maximum results
            
        Returns:
            List of matching records
        """
        return self.session.query(self.model_class).filter(
            self.model_class.name.like(f'%{search_term}%'),
            self.model_class.is_active == True
        ).limit(limit).all()
    
    def get_children(self, parent_id: int) -> List['NewModel']:
        """Get child records for hierarchical models"""
        if not hasattr(self.model_class, 'parent_id'):
            return []
        
        return self.session.query(self.model_class).filter_by(
            parent_id=parent_id,
            is_active=True
        ).order_by(self.model_class.name).all()
    
    def get_statistics(self) -> Dict[str, Any]:
        """
        Get statistics for the model
        
        Returns:
            Dictionary with various statistics
        """
        total = self.count()
        active = self.count(is_active=True) if hasattr(self.model_class, 'is_active') else total
        
        # Count by type
        type_counts = {}
        if hasattr(self.model_class, 'type'):
            type_results = self.session.query(
                self.model_class.type,
                func.count(self.model_class.id).label('count')
            ).group_by(self.model_class.type).all()
            
            type_counts = {result.type: result.count for result in type_results}
        
        # Recent activity (if has created_at)
        recent_count = 0
        if hasattr(self.model_class, 'created_at'):
            since = datetime.now() - timedelta(days=7)
            recent_count = self.session.query(self.model_class).filter(
                self.model_class.created_at >= since
            ).count()
        
        return {
            'total': total,
            'active': active,
            'inactive': total - active,
            'recent_week': recent_count,
            'by_type': type_counts
        }
    
    # ====================================
    # BULK OPERATIONS
    # ====================================
    
    def bulk_create(self, records_data: List[Dict[str, Any]]) -> List['NewModel']:
        """
        Create multiple records efficiently
        
        Args:
            records_data: List of dictionaries with record data
            
        Returns:
            List of created instances
        """
        instances = []
        for data in records_data:
            instance = self.model_class(**data)
            self.session.add(instance)
            instances.append(instance)
        
        self.session.flush()
        return instances
    
    def bulk_update_by_type(self, type: str, **updates) -> int:
        """
        Update multiple records by type
        
        Args:
            type: Record type to update
            **updates: Fields to update
            
        Returns:
            Number of records updated
        """
        if hasattr(self.model_class, 'updated_at'):
            updates['updated_at'] = datetime.now()
        
        result = self.session.query(self.model_class).filter_by(type=type).update(updates)
        self.session.flush()
        return result
    
    def bulk_activate(self, ids: List[int]) -> int:
        """Activate multiple records"""
        if not hasattr(self.model_class, 'is_active'):
            return 0
        
        result = self.session.query(self.model_class).filter(
            self.model_class.id.in_(ids)
        ).update({
            'is_active': True,
            'updated_at': datetime.now()
        }, synchronize_session=False)
        
        self.session.flush()
        return result
    
    # ====================================
    # VALIDATION HELPERS
    # ====================================
    
    def validate_unique_name(self, name: str, exclude_id: Optional[int] = None) -> bool:
        """
        Validate that name is unique
        
        Args:
            name: Name to validate
            exclude_id: ID to exclude from check (for updates)
            
        Returns:
            True if name is unique
        """
        query = self.session.query(self.model_class).filter_by(name=name)
        
        if exclude_id:
            query = query.filter(self.model_class.id != exclude_id)
        
        return query.first() is None
    
    def can_delete(self, id: int) -> tuple[bool, str]:
        """
        Check if record can be safely deleted
        
        Args:
            id: Record ID
            
        Returns:
            Tuple of (can_delete, reason)
        """
        instance = self.get_by_id(id)
        if not instance:
            return False, "Record not found"
        
        # Check for child records (if hierarchical)
        if hasattr(self.model_class, 'parent_id'):
            children = self.get_children(id)
            if children:
                return False, f"Has {len(children)} child records"
        
        # Add other business logic checks here
        # e.g., check if referenced by other models
        
        return True, "Can be deleted"

# ====================================
# REPOSITORY FACTORY
# ====================================

class RepositoryFactory:
    """
    Factory para criar repositories com session compartilhada
    
    Uso:
        repo_factory = RepositoryFactory(session)
        new_model_repo = repo_factory.get_new_model_repository()
        device_repo = repo_factory.get_device_repository()
    """
    
    def __init__(self, session: Session):
        self.session = session
        self._repositories = {}
    
    def get_new_model_repository(self) -> NewModelRepository:
        """Get NewModel repository"""
        if 'new_model' not in self._repositories:
            self._repositories['new_model'] = NewModelRepository(self.session)
        return self._repositories['new_model']
    
    # Adicionar métodos para outros repositories conforme necessário
    # def get_device_repository(self) -> DeviceRepository:
    #     if 'device' not in self._repositories:
    #         self._repositories['device'] = DeviceRepository(self.session)
    #     return self._repositories['device']

# ====================================
# USAGE EXAMPLES
# ====================================

if __name__ == '__main__':
    """
    Exemplos de uso do repository
    """
    from src.models.models import get_session
    
    session = get_session()
    repo = NewModelRepository(session)
    
    try:
        # Criar novo record
        new_record = repo.create(
            name="example_item",
            title="Item de Exemplo",
            type="type_a",
            is_active=True
        )
        print(f"✅ Criado: {new_record.name}")
        
        # Buscar por nome
        found = repo.get_by_name("example_item")
        print(f"✅ Encontrado: {found.title}")
        
        # Buscar por tipo
        type_records = repo.get_by_type("type_a")
        print(f"✅ Tipo A: {len(type_records)} records")
        
        # Estatísticas
        stats = repo.get_statistics()
        print(f"✅ Estatísticas: {stats}")
        
        # Bulk operations
        bulk_data = [
            {"name": "bulk_1", "title": "Bulk 1", "type": "type_b"},
            {"name": "bulk_2", "title": "Bulk 2", "type": "type_b"},
        ]
        bulk_records = repo.bulk_create(bulk_data)
        print(f"✅ Bulk create: {len(bulk_records)} records")
        
        # Commit all changes
        session.commit()
        print("✅ Todas as operações commitadas")
        
    except Exception as e:
        session.rollback()
        print(f"❌ Erro: {e}")
    finally:
        session.close()

# ====================================
# TESTING HELPER
# ====================================

class MockRepository(NewModelRepository):
    """
    Mock repository para testes
    
    Simula operações sem acessar o banco de dados
    """
    
    def __init__(self):
        # Não chama super().__init__() para evitar session
        self._data = {}
        self._next_id = 1
    
    def create(self, **kwargs):
        """Mock create operation"""
        instance = type('MockModel', (), kwargs)
        instance.id = self._next_id
        self._data[self._next_id] = instance
        self._next_id += 1
        return instance
    
    def get_by_id(self, id: int):
        """Mock get by ID"""
        return self._data.get(id)
    
    def get_all(self, limit=None, offset=0):
        """Mock get all"""
        items = list(self._data.values())[offset:]
        if limit:
            items = items[:limit]
        return items
    
    # Adicionar outros métodos conforme necessário para testes