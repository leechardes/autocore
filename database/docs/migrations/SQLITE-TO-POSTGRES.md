# 🐘 SQLite to PostgreSQL Migration Guide

Guia completo para migração do AutoCore de SQLite para PostgreSQL com Alembic e SQLAlchemy.

## 📋 Visão Geral

Esta migração visa aproveitar recursos avançados do PostgreSQL mantendo 100% de compatibilidade com o código existente através do SQLAlchemy ORM.

### 🎯 Objetivos
- **Performance**: Melhor handling de concorrência e queries complexas
- **Scalability**: Suporte a conexões simultâneas e partitioning
- **Features**: JSONB, full-text search, advanced indexing
- **Production Ready**: Backup, replication, monitoring

### 📊 Current vs Target

| Feature | SQLite | PostgreSQL | Impact |
|---------|--------|------------|--------|
| **Concurrency** | Limited | Full MVCC | ✅ Multiple users |
| **Data Types** | Basic | Rich types + JSONB | ✅ Better configs |
| **Indexes** | Basic | Advanced (GIN, GIST) | ✅ Performance |
| **Full-text Search** | Limited | Native | ✅ Search features |
| **Partitioning** | None | Native | ✅ Large datasets |
| **Replication** | None | Native | ✅ High availability |

## 📋 Migration Phases

### Phase 1: Analysis & Preparation ✅
- [x] Audit SQLite-specific features
- [x] Map data types compatibility
- [x] Identify potential issues
- [x] Plan migration strategy

### Phase 2: Environment Setup 🔄
- [ ] Docker PostgreSQL setup
- [ ] Connection configuration
- [ ] Test environment validation
- [ ] Performance baseline

### Phase 3: Schema Migration 📋
- [ ] Alembic PostgreSQL migrations
- [ ] Data type optimizations
- [ ] Index recreations
- [ ] Constraint adaptations

### Phase 4: Data Migration 📋
- [ ] Export SQLite data
- [ ] Transform and load to PostgreSQL
- [ ] Data integrity validation
- [ ] Performance testing

### Phase 5: Application Updates 📋
- [ ] Connection string updates
- [ ] Feature enhancements (JSONB)
- [ ] Query optimizations
- [ ] Monitoring setup

### Phase 6: Production Cutover 📋
- [ ] Blue-green deployment
- [ ] Data synchronization
- [ ] Rollback planning
- [ ] Post-migration validation

## 🔍 SQLite Features Analysis

### Compatible Features ✅
```sql
-- Basic data types (seamless)
INTEGER → INTEGER/BIGINT
TEXT → TEXT/VARCHAR
REAL → REAL/NUMERIC
BLOB → BYTEA

-- Constraints
PRIMARY KEY → PRIMARY KEY
FOREIGN KEY → FOREIGN KEY
UNIQUE → UNIQUE
CHECK → CHECK (enhanced)

-- Indexes
CREATE INDEX → CREATE INDEX (enhanced)
```

### SQLite-Specific Issues ⚠️

#### Dynamic Typing
```python
# SQLite: Flexible typing
Column('flexible_field', String)  # Can store any type

# PostgreSQL: Strict typing  
Column('flexible_field', String)  # Must be string
# Solution: Use proper SQLAlchemy types
```

#### Case Sensitivity
```sql
-- SQLite: Case insensitive by default
WHERE name = 'VALUE' OR name = 'value'

-- PostgreSQL: Case sensitive
WHERE name ILIKE 'value'  -- Case insensitive
WHERE LOWER(name) = 'value'  -- Normalized
```

#### Boolean Storage
```python
# SQLite: Stores as INTEGER (0/1)
is_active = Column(Boolean)

# PostgreSQL: Native boolean
is_active = Column(Boolean)  # True/False
# SQLAlchemy handles conversion automatically ✅
```

## 🎯 Data Type Mapping

### Core AutoCore Types
| SQLAlchemy Type | SQLite | PostgreSQL | Notes |
|----------------|--------|------------|-------|
| `Integer` | INTEGER | INTEGER | ✅ Direct |
| `String(50)` | TEXT | VARCHAR(50) | ✅ Enhanced |
| `Text` | TEXT | TEXT | ✅ Direct |
| `Boolean` | INTEGER | BOOLEAN | ✅ Auto-convert |
| `DateTime` | TEXT | TIMESTAMP | ✅ Enhanced |
| `Float` | REAL | REAL | ✅ Direct |

### Enhanced PostgreSQL Types
| Field | Current | PostgreSQL Enhancement |
|-------|---------|----------------------|
| `configuration_json` | TEXT | JSONB | Query JSON fields |
| `capabilities_json` | TEXT | JSONB | Index JSON keys |
| `payload` (EventLog) | TEXT | JSONB | Structured logs |
| `tags` (Icon) | TEXT | TEXT[] | Array operations |
| `uuid` (Device) | TEXT | UUID | Native UUID type |

## 🔧 Schema Migration Strategy

### Step 1: Create PostgreSQL Schemas
```python
# New Alembic environment for PostgreSQL
def upgrade():
    # Enhanced data types
    op.create_table('devices',
        Column('id', Integer, primary_key=True),
        Column('uuid', postgresql.UUID(as_uuid=True), unique=True),  # Enhanced
        Column('configuration_json', postgresql.JSONB),  # Enhanced
        Column('capabilities_json', postgresql.JSONB),   # Enhanced
        # ... outros campos
    )
    
    # Advanced indexes
    op.create_index('idx_devices_config_gin', 'devices', 
                   ['configuration_json'], postgresql_using='gin')
```

### Step 2: Migration Scripts
```python
# alembic/versions/postgres_migration.py
def upgrade():
    # Create all tables with PostgreSQL enhancements
    create_enhanced_tables()
    
    # Create advanced indexes
    create_gin_indexes()
    
    # Create partitioned tables for telemetry
    create_partitioned_telemetry()

def create_enhanced_tables():
    """Create tables with PostgreSQL-specific features"""
    # Devices with UUID and JSONB
    # TelemetryData with partitioning
    # EventLog with JSONB payload
```

### Step 3: Data Transformation
```python
def transform_sqlite_to_postgres():
    """Transform SQLite export for PostgreSQL"""
    
    # UUID conversion
    for device in sqlite_devices:
        device['uuid'] = str(uuid4()) if not device['uuid'] else device['uuid']
    
    # JSON parsing
    for device in sqlite_devices:
        if device['configuration_json']:
            device['configuration_json'] = json.loads(device['configuration_json'])
    
    # Boolean conversion (SQLAlchemy handles automatically)
    
    # Timestamp conversion
    for log in sqlite_events:
        log['timestamp'] = datetime.fromisoformat(log['timestamp'])
```

## 📊 Performance Enhancements

### Advanced Indexing
```sql
-- Current SQLite indexes
CREATE INDEX idx_devices_uuid ON devices(uuid);
CREATE INDEX idx_events_timestamp ON event_logs(timestamp);

-- Enhanced PostgreSQL indexes
CREATE INDEX CONCURRENTLY idx_devices_uuid ON devices USING btree(uuid);
CREATE INDEX CONCURRENTLY idx_devices_config_gin ON devices USING gin(configuration_json);
CREATE INDEX CONCURRENTLY idx_events_timestamp_brin ON event_logs USING brin(timestamp);
CREATE INDEX CONCURRENTLY idx_telemetry_device_time ON telemetry_data(device_id, timestamp DESC);

-- Full-text search
CREATE INDEX CONCURRENTLY idx_events_search ON event_logs 
USING gin(to_tsvector('english', event_type || ' ' || COALESCE(error_message, '')));
```

### JSONB Configuration Queries
```python
# Enhanced queries with JSONB
def find_devices_with_wifi():
    return session.query(Device).filter(
        Device.configuration_json['wifi']['enabled'].astext.cast(Boolean) == True
    ).all()

def find_mqtt_devices():
    return session.query(Device).filter(
        Device.configuration_json.has_key('mqtt')
    ).all()

def update_mqtt_broker(old_ip: str, new_ip: str):
    session.query(Device).filter(
        Device.configuration_json['mqtt']['broker'].astext == old_ip
    ).update({
        Device.configuration_json: func.jsonb_set(
            Device.configuration_json,
            ['mqtt', 'broker'],
            f'"{new_ip}"'
        )
    }, synchronize_session=False)
```

### Partitioned Telemetry
```sql
-- Partition telemetry by month for performance
CREATE TABLE telemetry_data (
    id BIGSERIAL,
    timestamp TIMESTAMP NOT NULL,
    device_id INTEGER NOT NULL,
    data_type VARCHAR(50) NOT NULL,
    data_value JSONB NOT NULL,
    FOREIGN KEY (device_id) REFERENCES devices(id)
) PARTITION BY RANGE (timestamp);

-- Monthly partitions
CREATE TABLE telemetry_data_2025_08 PARTITION OF telemetry_data
    FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');

CREATE TABLE telemetry_data_2025_09 PARTITION OF telemetry_data
    FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');
```

## 🐳 Docker PostgreSQL Setup

### docker-compose.yml
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: autocore
      POSTGRES_USER: autocore_user
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init.sql:/docker-entrypoint-initdb.d/init.sql
    command: >
      postgres
      -c shared_preload_libraries=pg_stat_statements
      -c pg_stat_statements.track=all
      -c max_connections=100
      -c shared_buffers=256MB
      -c effective_cache_size=1GB

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@autocore.local
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD}
    ports:
      - "8080:80"
    depends_on:
      - postgres

volumes:
  postgres_data:
```

### Connection Configuration
```python
# database/config.py
import os
from sqlalchemy import create_engine

def get_database_url():
    """Get database URL based on environment"""
    if os.getenv('DATABASE_TYPE') == 'postgresql':
        return (
            f"postgresql://{os.getenv('DB_USER', 'autocore_user')}:"
            f"{os.getenv('DB_PASSWORD')}@"
            f"{os.getenv('DB_HOST', 'localhost')}:"
            f"{os.getenv('DB_PORT', '5432')}/"
            f"{os.getenv('DB_NAME', 'autocore')}"
        )
    else:
        return f"sqlite:///{os.getenv('DB_PATH', 'autocore.db')}"

def get_engine():
    """Create database engine with appropriate settings"""
    url = get_database_url()
    
    if url.startswith('postgresql'):
        return create_engine(
            url,
            pool_size=10,
            max_overflow=20,
            pool_pre_ping=True,
            echo=False
        )
    else:
        return create_engine(
            url,
            connect_args={'check_same_thread': False},
            echo=False
        )
```

## 📊 Data Migration Process

### Export from SQLite
```python
# scripts/export_sqlite.py
def export_sqlite_data():
    """Export all data from SQLite to JSON"""
    sqlite_engine = create_engine('sqlite:///autocore.db')
    
    tables = [
        'devices', 'relay_boards', 'relay_channels',
        'screens', 'screen_items', 'users', 'event_logs',
        'telemetry_data', 'icons', 'themes', 'macros', 'can_signals'
    ]
    
    exported_data = {}
    
    with sqlite_engine.connect() as conn:
        for table in tables:
            result = conn.execute(text(f"SELECT * FROM {table}"))
            exported_data[table] = [dict(row) for row in result]
    
    # Save to JSON with timestamp
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    with open(f'sqlite_export_{timestamp}.json', 'w') as f:
        json.dump(exported_data, f, indent=2, default=str)
    
    return exported_data
```

### Import to PostgreSQL
```python
# scripts/import_postgres.py
def import_to_postgres(json_file: str):
    """Import JSON data to PostgreSQL"""
    postgres_engine = get_engine()  # PostgreSQL engine
    
    with open(json_file, 'r') as f:
        data = json.load(f)
    
    # Import em ordem (respecting FK constraints)
    import_order = [
        'users', 'themes', 'icons', 'devices', 'relay_boards',
        'relay_channels', 'screens', 'screen_items', 'macros',
        'can_signals', 'telemetry_data', 'event_logs'
    ]
    
    with postgres_engine.connect() as conn:
        for table in import_order:
            if table in data and data[table]:
                import_table_data(conn, table, data[table])
```

### Data Validation
```python
def validate_migration():
    """Validate data integrity after migration"""
    sqlite_engine = create_engine('sqlite:///autocore.db')
    postgres_engine = get_engine()
    
    tables = ['devices', 'relay_channels', 'screen_items', 'users']
    
    for table in tables:
        # Count comparison
        sqlite_count = sqlite_engine.execute(
            text(f"SELECT COUNT(*) FROM {table}")
        ).scalar()
        
        postgres_count = postgres_engine.execute(
            text(f"SELECT COUNT(*) FROM {table}")
        ).scalar()
        
        assert sqlite_count == postgres_count, f"Count mismatch in {table}"
        
        # Sample data comparison
        validate_sample_data(table, sqlite_engine, postgres_engine)
    
    print("✅ Migration validation passed!")
```

## ⚡ Performance Testing

### Benchmark Queries
```python
# scripts/benchmark.py
def benchmark_database_performance():
    """Compare SQLite vs PostgreSQL performance"""
    
    queries = [
        # Device lookups
        "SELECT * FROM devices WHERE status = 'online'",
        
        # Complex joins
        """
        SELECT d.name, rb.total_channels, COUNT(rc.id) as active_channels
        FROM devices d
        JOIN relay_boards rb ON d.id = rb.device_id
        JOIN relay_channels rc ON rb.id = rc.board_id
        WHERE rc.is_active = true
        GROUP BY d.id, rb.id
        """,
        
        # Telemetry aggregation
        """
        SELECT device_id, COUNT(*) as data_points,
               AVG(CAST(data_value AS REAL)) as avg_value
        FROM telemetry_data
        WHERE timestamp >= NOW() - INTERVAL '1 hour'
        GROUP BY device_id
        """,
        
        # Event log search
        """
        SELECT * FROM event_logs
        WHERE event_type = 'relay_control'
        AND timestamp >= NOW() - INTERVAL '1 day'
        ORDER BY timestamp DESC
        LIMIT 100
        """
    ]
    
    sqlite_times = benchmark_engine(sqlite_engine, queries)
    postgres_times = benchmark_engine(postgres_engine, queries)
    
    return compare_performance(sqlite_times, postgres_times)
```

## 🔄 Rollback Strategy

### Prerequisites
```bash
# 1. Full backup before migration
pg_dump autocore > autocore_postgres_backup.sql

# 2. Keep SQLite backup
cp autocore.db autocore_backup_pre_postgres.db

# 3. Export PostgreSQL data
python scripts/export_postgres.py
```

### Rollback Process
```python
def rollback_to_sqlite():
    """Emergency rollback to SQLite"""
    
    # 1. Stop application
    # 2. Restore SQLite backup
    shutil.copy('autocore_backup_pre_postgres.db', 'autocore.db')
    
    # 3. Update configuration
    os.environ['DATABASE_TYPE'] = 'sqlite'
    
    # 4. Restart application
    # 5. Verify functionality
    
    print("✅ Rollback to SQLite completed")
```

## 📊 Migration Timeline

### Estimated Timeline: 4 weeks

#### Week 1: Environment & Testing
- [ ] Docker PostgreSQL setup
- [ ] Test data migration scripts
- [ ] Performance baseline
- [ ] Team training

#### Week 2: Development Updates
- [ ] Code compatibility testing
- [ ] JSONB feature implementation
- [ ] Enhanced query optimization
- [ ] Unit test updates

#### Week 3: Staging Migration
- [ ] Full staging migration
- [ ] Application testing
- [ ] Performance validation
- [ ] Rollback testing

#### Week 4: Production Migration
- [ ] Final backup creation
- [ ] Blue-green deployment
- [ ] Data migration execution
- [ ] Monitoring setup
- [ ] Performance validation

### Success Criteria
- ✅ Zero data loss
- ✅ <5% performance degradation initially
- ✅ >20% performance improvement after optimization
- ✅ All tests passing
- ✅ Successful rollback test

---

**Next Steps**: Phase 2 - Environment Setup  
**Owner**: Database Team  
**Timeline**: Q4 2025  
**Risk Level**: Medium (mitigation planned)