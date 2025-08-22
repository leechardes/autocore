# 🤖 Database Agents System

Sistema de agentes autônomos para automação de tarefas de banco de dados no AutoCore.

## 📋 Visão Geral

Os Database Agents são agentes especializados que automatizam tarefas repetitivas e complexas relacionadas ao banco de dados, incluindo migrations, backup, performance analysis e geração de models.

### 🎯 Objetivos
- **Automação**: Reduzir tarefas manuais repetitivas
- **Qualidade**: Garantir consistência e boas práticas
- **Monitoramento**: Acompanhar performance e problemas
- **Produtividade**: Acelerar desenvolvimento

## 🤖 Agentes Disponíveis

### 🔄 A01 - Migration Creator
**Responsabilidade**: Criação automatizada de migrations Alembic
- Analisa mudanças nos models SQLAlchemy
- Gera migrations com boas práticas
- Valida syntax e reversibilidade
- Testa upgrade/downgrade

**Triggers**:
- Model changes detectados
- Manual request via CLI
- CI/CD pipeline trigger

**Outputs**:
- Migration files válidos
- Relatório de mudanças
- Testes de validação

### 🏗️ A02 - Model Generator  
**Responsabilidade**: Geração de SQLAlchemy models
- Cria models a partir de especificações
- Segue templates e convenções
- Gera relacionamentos automaticamente
- Inclui validações e constraints

**Triggers**:
- New model specification
- Database schema import
- API schema conversion

**Outputs**:
- Model files Python
- Relationship documentation
- Validation tests

### 🌱 A03 - Seed Runner
**Responsabilidade**: Gerenciamento de dados de teste/iniciais
- Executa scripts de seed
- Popula dados de desenvolvimento
- Gerencia ambientes (dev/staging/prod)
- Valida integridade dos dados

**Triggers**:
- Environment setup
- Test preparation  
- Manual seed execution

**Outputs**:
- Database populada
- Seed execution log
- Data validation report

### 💾 A04 - Backup Manager
**Responsabilidade**: Automação de backups
- Backup automatizado scheduled
- Compressão e armazenamento
- Retention policy enforcement
- Restore procedures

**Triggers**:
- Scheduled intervals
- Pre-migration backup
- Manual backup request

**Outputs**:
- Backup files
- Backup verification
- Storage management

### 📊 A05 - Performance Analyzer
**Responsabilidade**: Análise de performance
- Identifica queries lentas
- Sugere otimizações de índices
- Monitora crescimento de dados
- Gera relatórios de performance

**Triggers**:
- Scheduled analysis
- Performance threshold alerts
- Manual analysis request

**Outputs**:
- Performance reports
- Optimization suggestions
- Index recommendations

## 📁 Estrutura do Sistema

```
agents/
├── README.md                    # Este arquivo
├── dashboard.md                 # Dashboard de monitoramento
├── active-agents/              # Agentes ativos
│   ├── A01-migration-creator/
│   │   ├── agent.py            # Implementação do agente
│   │   ├── config.yaml         # Configuração
│   │   ├── templates/          # Templates específicos
│   │   └── logs/               # Logs do agente
│   ├── A02-model-generator/
│   ├── A03-seed-runner/
│   ├── A04-backup-manager/
│   └── A05-performance-analyzer/
├── logs/                       # Logs centralizados
│   ├── agents.log              # Log geral
│   ├── migrations.log          # Log de migrations
│   ├── performance.log         # Log de performance
│   └── backups.log             # Log de backups
├── checkpoints/               # Checkpoints de estado
│   ├── last_migration.json
│   ├── last_backup.json
│   └── performance_baseline.json
└── metrics/                   # Métricas e relatórios
    ├── daily_reports/
    ├── performance_trends/
    └── agent_statistics/
```

## 🚀 Agent Framework

### Base Agent Class
```python
from abc import ABC, abstractmethod
from datetime import datetime
from typing import Dict, Any, List
import logging
import yaml

class DatabaseAgent(ABC):
    """
    Base class para todos os database agents
    """
    
    def __init__(self, name: str, config_path: str):
        self.name = name
        self.config = self._load_config(config_path)
        self.logger = self._setup_logging()
        self.metrics = {}
        
    @abstractmethod
    def execute(self) -> Dict[str, Any]:
        """Execute agent main task"""
        pass
    
    @abstractmethod
    def validate(self) -> bool:
        """Validate agent prerequisites"""
        pass
    
    def _load_config(self, path: str) -> Dict[str, Any]:
        """Load agent configuration"""
        with open(path, 'r') as f:
            return yaml.safe_load(f)
    
    def _setup_logging(self) -> logging.Logger:
        """Setup agent logging"""
        logger = logging.getLogger(f"database.agent.{self.name}")
        # Configure handlers, formatters, etc.
        return logger
    
    def checkpoint(self, data: Dict[str, Any]):
        """Save checkpoint data"""
        checkpoint_file = f"docs/agents/checkpoints/{self.name}_checkpoint.json"
        # Save data to checkpoint file
        
    def report_metrics(self, metrics: Dict[str, Any]):
        """Report agent metrics"""
        self.metrics.update(metrics)
        # Send to metrics system
```

### Agent Configuration Template
```yaml
# A01-migration-creator/config.yaml
agent:
  name: "A01-migration-creator"
  version: "1.0.0"
  enabled: true
  
schedule:
  type: "event"  # "cron", "event", "manual"
  triggers:
    - "model_change"
    - "manual_request"
  
settings:
  models_path: "src/models/"
  migrations_path: "alembic/versions/"
  auto_generate: true
  validate_rollback: true
  
notifications:
  email: ["admin@autocore.local"]
  slack: "#database-alerts"
  
limits:
  max_execution_time: 300  # seconds
  max_file_size: "10MB"
```

## 📊 Agent Dashboard

### Status Overview
```
🤖 DATABASE AGENTS STATUS

┌─────────────────────────────────────────────────────────────┐
│ 🔄 A01-Migration-Creator      ✅ Active    Last: 2h ago     │
│ 🏗️ A02-Model-Generator        ✅ Active    Last: 1d ago     │  
│ 🌱 A03-Seed-Runner           ⏸️ Idle      Last: 3d ago     │
│ 💾 A04-Backup-Manager        ✅ Active    Last: 6h ago     │
│ 📊 A05-Performance-Analyzer  ✅ Active    Last: 1h ago     │
└─────────────────────────────────────────────────────────────┘

🔥 RECENT ACTIVITY (Last 24h)
• Migration created: add_user_preferences_table (A01)
• Backup completed: autocore_20250822_120000.db (A04)  
• Performance alert: slow query detected (A05)
• 3 models generated from API specs (A02)

⚠️ ALERTS
• Performance threshold exceeded: query avg >100ms
• Backup storage 85% full - cleanup recommended
```

### Metrics Dashboard
```
📊 AGENT PERFORMANCE METRICS

Executions (Last 7 days):
A01: ████████████████████░ 85% success (23/27)
A02: ███████████████████░░ 95% success (19/20)
A03: ████████████████████░ 100% success (5/5)
A04: ████████████████████░ 98% success (168/171)
A05: ███████████████████░░ 92% success (46/50)

Execution Times (Average):
A01: 45s (Migration generation)
A02: 12s (Model creation)
A03: 180s (Seed execution)
A04: 25s (Backup creation)
A05: 90s (Performance analysis)

Database Health:
Schema Version: v2.1.0 ✅
Migration Status: Up to date ✅
Backup Status: Current (6h ago) ✅
Performance: 92% queries <100ms ⚠️
```

## 🔧 Agent Implementation Examples

### A01 - Migration Creator
```python
class MigrationCreatorAgent(DatabaseAgent):
    """
    Agent para criação automatizada de migrations
    """
    
    def execute(self) -> Dict[str, Any]:
        """Execute migration creation"""
        self.logger.info("🔄 [A01] Iniciando criação de migration")
        
        # 1. Detect model changes
        changes = self._detect_model_changes()
        if not changes:
            return {"status": "no_changes", "message": "No model changes detected"}
        
        # 2. Generate migration
        migration_file = self._generate_migration(changes)
        
        # 3. Validate migration
        validation_result = self._validate_migration(migration_file)
        
        # 4. Test upgrade/downgrade
        test_result = self._test_migration(migration_file)
        
        # 5. Report results
        result = {
            "status": "success",
            "migration_file": migration_file,
            "changes": changes,
            "validation": validation_result,
            "test_result": test_result
        }
        
        self.logger.info(f"✅ [A01] Migration criada: {migration_file}")
        return result
    
    def _detect_model_changes(self) -> List[Dict[str, Any]]:
        """Detect changes in SQLAlchemy models"""
        # Compare current models with last known state
        # Return list of changes detected
        pass
    
    def _generate_migration(self, changes: List[Dict[str, Any]]) -> str:
        """Generate Alembic migration file"""
        # Use Alembic autogenerate with custom logic
        # Return migration file path
        pass
    
    def _validate_migration(self, migration_file: str) -> Dict[str, Any]:
        """Validate migration syntax and logic"""
        # Check for common issues
        # Validate reversibility
        # Return validation results
        pass
```

### A04 - Backup Manager
```python
class BackupManagerAgent(DatabaseAgent):
    """
    Agent para gerenciamento automatizado de backups
    """
    
    def execute(self) -> Dict[str, Any]:
        """Execute backup creation"""
        self.logger.info("💾 [A04] Iniciando backup do database")
        
        # 1. Pre-backup validation
        if not self._validate_database_state():
            return {"status": "error", "message": "Database not in valid state"}
        
        # 2. Create backup
        backup_file = self._create_backup()
        
        # 3. Verify backup integrity
        verification = self._verify_backup(backup_file)
        
        # 4. Manage retention policy
        self._cleanup_old_backups()
        
        # 5. Update metrics
        self._update_backup_metrics(backup_file)
        
        result = {
            "status": "success",
            "backup_file": backup_file,
            "size": self._get_file_size(backup_file),
            "verification": verification,
            "retention_cleaned": True
        }
        
        self.logger.info(f"✅ [A04] Backup criado: {backup_file}")
        return result
```

## 🎯 Agent Orchestration

### Agent Manager
```python
class AgentManager:
    """
    Coordena execução dos database agents
    """
    
    def __init__(self):
        self.agents = self._load_agents()
        self.scheduler = self._setup_scheduler()
    
    def run_agent(self, agent_name: str, context: Dict[str, Any] = None) -> Dict[str, Any]:
        """Execute specific agent"""
        if agent_name not in self.agents:
            raise ValueError(f"Agent {agent_name} not found")
        
        agent = self.agents[agent_name]
        
        if not agent.validate():
            return {"status": "validation_failed"}
        
        return agent.execute()
    
    def run_scheduled_agents(self):
        """Execute agents based on schedule"""
        for agent_name, agent in self.agents.items():
            if self._should_run_agent(agent):
                self.run_agent(agent_name)
    
    def get_dashboard_data(self) -> Dict[str, Any]:
        """Get data for agent dashboard"""
        return {
            "agents_status": self._get_agents_status(),
            "recent_activity": self._get_recent_activity(),
            "metrics": self._get_metrics(),
            "alerts": self._get_alerts()
        }
```

## 🔍 Monitoring & Alerting

### Alert System
```python
class AgentAlertSystem:
    """
    Sistema de alertas para os agents
    """
    
    def __init__(self):
        self.alert_rules = self._load_alert_rules()
        self.notification_channels = self._setup_channels()
    
    def check_alerts(self, agent_metrics: Dict[str, Any]):
        """Check if any alert conditions are met"""
        for rule in self.alert_rules:
            if self._evaluate_rule(rule, agent_metrics):
                self._send_alert(rule, agent_metrics)
    
    def _evaluate_rule(self, rule: Dict[str, Any], metrics: Dict[str, Any]) -> bool:
        """Evaluate alert rule against metrics"""
        # Examples:
        # - Execution time > threshold
        # - Success rate < threshold  
        # - Backup size > threshold
        # - Performance degradation detected
        pass
```

### Performance Tracking
```yaml
# metrics/agent_kpis.yaml
kpis:
  migration_creator:
    execution_time: "< 60s"
    success_rate: "> 95%"
    rollback_success: "> 99%"
    
  backup_manager:
    execution_time: "< 30s"
    backup_size_growth: "< 10% per week"
    verification_success: "100%"
    
  performance_analyzer:
    detection_accuracy: "> 90%"
    false_positive_rate: "< 5%"
    analysis_coverage: "> 95%"
```

## 🚀 Getting Started

### Enable Agents
```bash
# Enable all agents
python database/agents/manager.py --enable-all

# Enable specific agent
python database/agents/manager.py --enable A01-migration-creator

# Run agent manually
python database/agents/manager.py --run A04-backup-manager

# View dashboard
python database/agents/dashboard.py --serve
```

### Configuration
```python
# database/agents/config.py
AGENTS_CONFIG = {
    "enabled": True,
    "log_level": "INFO",
    "metrics_retention": "30d",
    "checkpoint_interval": "1h",
    "alert_channels": ["email", "slack"],
    "dashboard_port": 8090
}
```

---

**Dashboard URL**: http://localhost:8090  
**Logs Location**: `/database/docs/agents/logs/`  
**Metrics API**: http://localhost:8090/api/metrics  
**Agent Status**: `python database/agents/status.py`