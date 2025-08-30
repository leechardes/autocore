# 🗄️ Database Documentation

## 📋 Overview
Database schema, migrations, and data management documentation for AutoCore Backend.

## 📁 Structure
```
database/
├── README.md              # This file
├── SCHEMA.md             # Database schema documentation  
├── MIGRATIONS.md         # Migration history and procedures
├── QUERIES.md            # Common queries and optimizations
├── BACKUP.md             # Backup and restore procedures
└── PERFORMANCE.md        # Performance tuning and monitoring
```

## 🚀 Quick Links
- [Schema Documentation](./SCHEMA.md) - Tables, relationships, and constraints
- [Migration Guide](./MIGRATIONS.md) - How to manage database changes
- [Query Examples](./QUERIES.md) - Common patterns and optimizations
- [Backup Procedures](./BACKUP.md) - Data protection strategies
- [Performance Tuning](./PERFORMANCE.md) - Optimization guidelines

## 📊 Database Components
- **Users Management** - Authentication and profiles
- **Device Registry** - ESP32 device management
- **Relay Control** - Relay states and configurations
- **Screen Management** - UI layout and themes
- **Telemetry Storage** - Historical data and analytics
- **System Configuration** - Global settings and preferences

## 🔧 Tools and Technologies
- **SGBD**: PostgreSQL 15+
- **ORM**: SQLAlchemy 2.0+
- **Migrations**: Alembic
- **Connection Pool**: SQLAlchemy Engine Pool
- **Monitoring**: Built-in health checks

## 📝 Documentation Standards
All database documentation should include:
- Clear table descriptions
- Column specifications with types
- Relationship diagrams
- Index strategies
- Example queries
- Performance considerations

---
*Last updated: 2025-01-28*