# A05 - Agente de Documentação Database (SQLite → PostgreSQL)

## 📋 Objetivo
Criar documentação completa para o sistema de banco de dados do AutoCore, focando em SQLite com migração planejada para PostgreSQL, usando Alembic para migrations e SQLAlchemy como ORM. NUNCA usar comandos SQL diretos.

## 🎯 Tarefas Específicas
1. Analisar estrutura atual do database
2. Documentar models SQLAlchemy existentes
3. Mapear migrations Alembic
4. Criar guia de migração SQLite → PostgreSQL
5. Documentar relationships e constraints
6. Gerar diagramas ER
7. Criar templates para novos models
8. Documentar índices e otimizações
9. Configurar sistema de agentes database
10. Criar guias de backup e restore

## 📁 Estrutura Específica Database
```
database/docs/
├── README.md                        # Visão geral do database
├── CHANGELOG.md                     
├── VERSION.md                       
├── .doc-version                     
│
├── models/                          # Documentação dos Models
│   ├── README.md
│   ├── device-models.md
│   ├── screen-models.md
│   ├── relay-models.md
│   ├── user-models.md
│   └── relationships.md
│
├── migrations/                      # Alembic migrations
│   ├── README.md
│   ├── migration-guide.md
│   ├── migration-history.md
│   ├── rollback-procedures.md
│   └── sqlite-to-postgres.md
│
├── schemas/                         # Database schemas
│   ├── README.md
│   ├── er-diagram.md
│   ├── table-definitions.md
│   ├── indexes.md
│   └── constraints.md
│
├── api/                             # Database API/ORM
│   ├── README.md
│   ├── sqlalchemy-patterns.md
│   ├── query-optimization.md
│   ├── connection-pooling.md
│   └── transactions.md
│
├── architecture/                    
│   ├── README.md
│   ├── database-design.md
│   ├── normalization.md
│   ├── partitioning-strategy.md
│   └── replication-setup.md
│
├── deployment/                      
│   ├── README.md
│   ├── docker-postgres.md
│   ├── sqlite-setup.md
│   ├── backup-strategy.md
│   └── monitoring.md
│
├── development/                     
│   ├── README.md
│   ├── getting-started.md
│   ├── alembic-workflow.md
│   ├── sqlalchemy-guide.md
│   ├── testing-database.md
│   └── seed-data.md
│
├── security/                        
│   ├── README.md
│   ├── access-control.md
│   ├── encryption.md
│   ├── sql-injection-prevention.md
│   └── audit-logging.md
│
├── performance/                     # Otimização
│   ├── README.md
│   ├── query-optimization.md
│   ├── indexing-strategy.md
│   ├── caching.md
│   └── connection-pooling.md
│
├── troubleshooting/                 
│   ├── README.md
│   ├── common-errors.md
│   ├── migration-issues.md
│   ├── performance-problems.md
│   └── connection-issues.md
│
├── templates/                       
│   ├── model-template.py
│   ├── migration-template.py
│   ├── repository-template.py
│   └── test-template.py
│
└── agents/                          
    ├── README.md
    ├── dashboard.md
    ├── active-agents/
    │   ├── A01-migration-creator/
    │   ├── A02-model-generator/
    │   ├── A03-seed-runner/
    │   ├── A04-backup-manager/
    │   └── A05-performance-analyzer/
    ├── logs/
    ├── checkpoints/
    └── metrics/
```

## 🔧 Comandos de Análise
```bash
# Navegação
cd /Users/leechardes/Projetos/AutoCore/database

# Análise de models
find . -name "*.py" | xargs grep -l "Base\|declarative_base\|SQLAlchemy"
find . -name "models.py" -o -name "*model*.py"

# Análise de migrations
find . -path "*/alembic/versions/*.py"
ls -la alembic/versions/ 2>/dev/null

# Verificar configuração Alembic
cat alembic.ini 2>/dev/null | grep -A 5 -B 5 "sqlalchemy.url"

# Analisar schemas
grep -r "Table\|Column\|Integer\|String\|ForeignKey" --include="*.py"

# Verificar documentação existente
find . -name "*.md"
```

## 📝 Documentação Específica a Criar

### Models Documentation
- Todos os models SQLAlchemy
- Campos e tipos de dados
- Relationships (1:1, 1:N, N:N)
- Constraints e validações
- Índices definidos

### Migrations Guide
- Workflow com Alembic
- Comandos essenciais
- Auto-generate vs Manual
- Rollback procedures
- Migration testing

### SQLite to PostgreSQL
- Diferenças principais
- Plano de migração
- Data types mapping
- Features PostgreSQL
- Timeline estimado

### SQLAlchemy Patterns
- Session management
- Query optimization
- Lazy loading strategies
- Bulk operations
- Raw SQL (quando necessário)

### Performance Optimization
- Index strategy
- Query analysis
- Connection pooling
- Caching strategy
- Partitioning (PostgreSQL)

## ⚠️ Regras Importantes
1. **NUNCA** usar comandos SQL diretos
2. **SEMPRE** usar Alembic para migrations
3. **SEMPRE** usar SQLAlchemy ORM
4. **DOCUMENTAR** todas as migrations
5. **TESTAR** rollback de migrations

## ✅ Checklist de Validação
- [ ] Models documentados
- [ ] Migrations catalogadas
- [ ] ER Diagram criado
- [ ] Guia SQLite → PostgreSQL
- [ ] Alembic workflow documentado
- [ ] SQLAlchemy patterns
- [ ] Backup procedures
- [ ] Performance guides
- [ ] Templates funcionais
- [ ] Agentes database criados

## 📊 Métricas Esperadas
- Models documentados: 15+
- Migrations existentes: 10+
- Relationships mapeados: 20+
- Templates criados: 4
- Agentes configurados: 5
- Guias de migração: 3+

## 🚀 Agentes Database Específicos
1. **A01-migration-creator**: Cria migrations com Alembic
2. **A02-model-generator**: Gera models SQLAlchemy
3. **A03-seed-runner**: Popula dados de teste
4. **A04-backup-manager**: Gerencia backups automatizados
5. **A05-performance-analyzer**: Analisa queries lentas

## 🔄 Migração SQLite → PostgreSQL
### Fase 1: Preparação
- Audit de features SQLite específicas
- Mapeamento de tipos de dados
- Identificação de incompatibilidades

### Fase 2: Migration
- Setup PostgreSQL com Docker
- Alembic migrations adaptadas
- Data migration scripts

### Fase 3: Validação
- Testes de integridade
- Performance comparison
- Rollback plan