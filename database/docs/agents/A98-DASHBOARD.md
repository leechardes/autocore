# 📊 A98-DASHBOARD - Database Agents Dashboard

Dashboard de monitoramento em tempo real dos Database Agents do AutoCore.

## 🎯 Visão Geral

O Dashboard fornece uma interface centralizada para monitorar, controlar e analisar o desempenho dos Database Agents, incluindo métricas em tempo real, logs e alertas.

## 📱 Interface Principal

### Status Board
```
╔═══════════════════════════════════════════════════════════════════════╗
║                    🤖 AUTOCORE DATABASE AGENTS                       ║
║                        System Status: ✅ HEALTHY                      ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║  📊 OVERVIEW                          🔥 ALERTS (2)                  ║
║  ├─ Active Agents: 5/5               ├─ Performance degradation      ║
║  ├─ Success Rate: 94.2%              └─ Backup storage 85% full      ║
║  ├─ Avg Execution: 52s                                               ║
║  └─ Last Activity: 15min ago         📈 TRENDS                       ║
║                                       ├─ Migrations: ↗️ +12% (7d)    ║
║  ⏰ SCHEDULE                          ├─ Backups: ➡️ stable          ║
║  ├─ Next Backup: 3h 22min            ├─ Performance: ↘️ -5% (24h)   ║
║  ├─ Next Analysis: 47min             └─ Seeds: ↗️ +200% (7d)         ║
║  └─ Migration Check: 1h 15min                                        ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
```

### Agent Status Grid
```
┌─────────────────────────────────────────────────────────────────────┐
│                          🤖 AGENT STATUS                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│ 🔄 A01-MIGRATION-CREATOR                                           │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ Status: ✅ ACTIVE     Last Run: 2h 15min ago                   │ │
│ │ Success Rate: 🟢 96.2% (25/26)    Avg Time: 45s              │ │
│ │ Next: On model change             Triggers: model_change       │ │
│ │ Recent: Created user_roles migration (SUCCESS)                 │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│ 🏗️ A02-MODEL-GENERATOR                                            │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ Status: ⏸️ IDLE       Last Run: 1d 8h ago                      │ │
│ │ Success Rate: 🟢 100% (12/12)     Avg Time: 12s               │ │
│ │ Next: Manual trigger              Triggers: api_spec, manual   │ │
│ │ Recent: Generated UserSession model (SUCCESS)                  │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│ 🌱 A03-SEED-RUNNER                                                 │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ Status: ⏸️ IDLE       Last Run: 3d 12h ago                     │ │
│ │ Success Rate: 🟢 100% (3/3)       Avg Time: 180s              │ │
│ │ Next: Manual trigger              Triggers: env_setup, manual  │ │
│ │ Recent: Populated development icons (SUCCESS)                  │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│ 💾 A04-BACKUP-MANAGER                                              │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ Status: ✅ ACTIVE     Last Run: 6h 10min ago                   │ │
│ │ Success Rate: 🟡 91.7% (166/181)  Avg Time: 25s               │ │
│ │ Next: 5h 50min                    Triggers: schedule, pre_mig  │ │
│ │ Recent: Daily backup completed (SUCCESS)                       │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│ 📊 A05-PERFORMANCE-ANALYZER                                        │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ Status: 🔄 RUNNING    Started: 5min ago                        │ │
│ │ Success Rate: 🟡 88.9% (40/45)    Avg Time: 90s               │ │
│ │ Next: 55min                       Triggers: schedule, alert    │ │
│ │ Recent: Analyzing query performance... (IN PROGRESS)           │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## 📈 Performance Metrics

### Real-time Metrics
```
╔═══════════════════════════════════════════════════════════════════════╗
║                          📊 PERFORMANCE METRICS                      ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║ 🔄 EXECUTION METRICS (Last 7 days)                                   ║
║                                                                       ║
║ Total Executions: 287                                                ║
║ ┌─────────────────────────────────────────────────────────────────┐   ║
║ │ A01: ████████████████████░ 96.2% (25/26) - 45s avg             │   ║
║ │ A02: ████████████████████░ 100%  (12/12) - 12s avg             │   ║
║ │ A03: ████████████████████░ 100%  (3/3)   - 180s avg            │   ║
║ │ A04: ███████████████████░░ 91.7% (166/181) - 25s avg           │   ║
║ │ A05: ██████████████████░░░ 88.9% (40/45) - 90s avg             │   ║
║ └─────────────────────────────────────────────────────────────────┘   ║
║                                                                       ║
║ 📊 RESOURCE USAGE                                                     ║
║ CPU Usage:     ██████░░░░ 60% (peak: 85%)                           ║
║ Memory Usage:  ████░░░░░░ 40% (2.1GB / 8GB)                         ║
║ Disk I/O:      ███░░░░░░░ 30% (avg: 12MB/s)                         ║
║ DB Connections: ██░░░░░░░ 20% (4/20 pool)                           ║
║                                                                       ║
║ ⏱️ RESPONSE TIMES (p95)                                              ║
║ Database Queries: 45ms (target: <100ms) ✅                          ║
║ Migration Gen:    2.1s (target: <5s) ✅                             ║
║ Backup Creation:  8.5s (target: <30s) ✅                            ║
║ Performance Scan: 1.2min (target: <2min) ✅                         ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
```

### Historical Trends
```
┌─────────────────────────────────────────────────────────────────────┐
│                        📈 7-DAY TRENDS                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│ SUCCESS RATE TREND                                                  │
│ 100% ┤                                                             │
│  95% ┤ ●─●─●─●─●─●──●                                              │
│  90% ┤           ●─●─●                                             │
│  85% ┤                                                             │
│      └────────────────────────────────────────                    │
│       Mon Tue Wed Thu Fri Sat Sun                                  │
│                                                                     │
│ EXECUTION TIME TREND                                                │
│ 60s  ┤     ●                                                       │
│ 50s  ┤ ●─●─●─●─●─●──●                                              │
│ 40s  ┤                                                             │
│ 30s  ┤                                                             │
│      └────────────────────────────────────────                    │
│       Mon Tue Wed Thu Fri Sat Sun                                  │
│                                                                     │
│ DATABASE SIZE GROWTH                                                │
│ 1.4MB┤               ●                                             │
│ 1.3MB┤         ●─●─●─●                                             │
│ 1.2MB┤   ●─●─●─●                                                   │
│ 1.1MB┤ ●─●                                                         │
│      └────────────────────────────────────────                    │
│       Mon Tue Wed Thu Fri Sat Sun                                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## 🚨 Alert Management

### Active Alerts
```
╔═══════════════════════════════════════════════════════════════════════╗
║                            🚨 ACTIVE ALERTS                          ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║ ⚠️ HIGH PRIORITY (2)                                                  ║
║ ┌─────────────────────────────────────────────────────────────────┐   ║
║ │ Performance Degradation Detected                                │   ║
║ │ Agent: A05-Performance-Analyzer                                 │   ║
║ │ Triggered: 2h 30min ago                                         │   ║
║ │ Details: Query avg response time >100ms (current: 145ms)       │   ║
║ │ Impact: User experience degradation                             │   ║
║ │ Actions: [View Details] [Acknowledge] [Escalate]               │   ║
║ └─────────────────────────────────────────────────────────────────┘   ║
║                                                                       ║
║ ┌─────────────────────────────────────────────────────────────────┐   ║
║ │ Backup Storage Near Capacity                                    │   ║
║ │ Agent: A04-Backup-Manager                                       │   ║
║ │ Triggered: 6h 15min ago                                         │   ║
║ │ Details: Storage 85% full (8.5GB / 10GB)                       │   ║
║ │ Impact: Future backups may fail                                 │   ║
║ │ Actions: [Cleanup Old] [Expand Storage] [Acknowledge]          │   ║
║ └─────────────────────────────────────────────────────────────────┘   ║
║                                                                       ║
║ 🟡 MEDIUM PRIORITY (1)                                               ║
║ ┌─────────────────────────────────────────────────────────────────┐   ║
║ │ Backup Success Rate Below Threshold                             │   ║
║ │ Agent: A04-Backup-Manager                                       │   ║
║ │ Triggered: 1d 4h ago                                            │   ║
║ │ Details: Success rate 91.7% (target: >95%)                     │   ║
║ │ Impact: Backup reliability concerns                             │   ║
║ │ Actions: [Investigate] [View Logs] [Acknowledge]               │   ║
║ └─────────────────────────────────────────────────────────────────┘   ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
```

### Alert Rules Configuration
```yaml
# Alert rules for database agents
alert_rules:
  performance_degradation:
    condition: "avg_query_time > 100ms"
    severity: "high"
    cooldown: "30min"
    actions: ["email", "slack"]
    
  backup_failure:
    condition: "backup_success_rate < 95%"
    severity: "high"
    cooldown: "1h"
    actions: ["email", "pager"]
    
  storage_capacity:
    condition: "storage_usage > 80%"
    severity: "medium"
    cooldown: "6h"
    actions: ["email"]
    
  agent_failure:
    condition: "agent_down_time > 5min"
    severity: "critical"
    cooldown: "0min"
    actions: ["email", "pager", "slack"]
```

## 📋 Recent Activity

### Activity Stream
```
┌─────────────────────────────────────────────────────────────────────┐
│                        🔥 RECENT ACTIVITY                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│ 🕐 15:42:33  A05  📊 Performance analysis completed                │
│             └─ Found 3 slow queries, generated 2 optimization tips │
│                                                                     │
│ 🕐 15:38:15  A01  ✅ Migration validation passed                   │
│             └─ add_user_session_table.py ready for application     │
│                                                                     │
│ 🕐 15:35:22  A01  🔄 Auto-migration triggered                      │
│             └─ Detected changes in User model                      │
│                                                                     │
│ 🕐 14:20:10  A04  💾 Scheduled backup completed                    │
│             └─ autocore_20250822_142010.db (1.3MB, verified ✅)   │
│                                                                     │
│ 🕐 13:45:33  A05  ⚠️ Performance alert triggered                   │
│             └─ Query response time exceeded threshold (145ms)       │
│                                                                     │
│ 🕐 11:30:45  A02  🏗️ Model generation requested                    │
│             └─ UserSession model created from API specification    │
│                                                                     │
│ 🕐 09:15:22  A04  🧹 Old backup cleanup completed                  │
│             └─ Removed 5 backups older than 30 days (freed 6.2MB) │
│                                                                     │
│ 🕐 08:00:00  SYS  🚀 Daily agent health check                      │
│             └─ All agents operational, no issues detected          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## 🔧 Agent Control Panel

### Manual Controls
```
╔═══════════════════════════════════════════════════════════════════════╗
║                        🎮 AGENT CONTROL PANEL                        ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║ 🔄 QUICK ACTIONS                                                      ║
║ ┌─────────────────────────────────────────────────────────────────┐   ║
║ │ [🔄 Run Migration Check]     [💾 Create Backup Now]            │   ║
║ │ [📊 Run Performance Scan]    [🌱 Execute Seeds]                │   ║
║ │ [🧹 Cleanup Old Data]        [🔍 Validate All]                 │   ║
║ └─────────────────────────────────────────────────────────────────┘   ║
║                                                                       ║
║ ⚙️ AGENT MANAGEMENT                                                   ║
║ ┌─────────────────────────────────────────────────────────────────┐   ║
║ │ A01-Migration-Creator    [⏸️ Pause] [⚙️ Config] [📋 Logs]      │   ║
║ │ A02-Model-Generator      [▶️ Start] [⚙️ Config] [📋 Logs]      │   ║
║ │ A03-Seed-Runner          [⏸️ Pause] [⚙️ Config] [📋 Logs]      │   ║
║ │ A04-Backup-Manager       [⏸️ Pause] [⚙️ Config] [📋 Logs]      │   ║
║ │ A05-Performance-Analyzer [⏸️ Pause] [⚙️ Config] [📋 Logs]      │   ║
║ └─────────────────────────────────────────────────────────────────┘   ║
║                                                                       ║
║ 🔧 SYSTEM CONTROLS                                                    ║
║ ┌─────────────────────────────────────────────────────────────────┐   ║
║ │ [🔄 Restart All Agents]      [📊 Export Metrics]               │   ║
║ │ [⚠️ Emergency Stop All]      [🧹 Clear All Logs]               │   ║
║ │ [⚙️ Global Configuration]    [🔄 Reload Configs]               │   ║
║ └─────────────────────────────────────────────────────────────────┘   ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
```

## 📊 Detailed Reports

### Migration Report
```
📋 MIGRATION ANALYSIS REPORT
Generated: 2025-08-22 15:45:33

MIGRATIONS OVERVIEW:
├─ Total Migrations: 6
├─ Applied: 6 ✅
├─ Pending: 0
├─ Failed: 0
├─ Last Migration: 8cb7e8483fa4 (2025-08-17)
└─ Schema Version: v2.1.0

RECENT MIGRATION ACTIVITY:
├─ 2025-08-17: Added check constraints (8cb7e8483fa4)
├─ 2025-08-17: Standardized screen types (cc3149ee98bd)
├─ 2025-08-16: Added icons table (59042b38c022)
└─ 2025-08-08: Added macro permissions (79697777cf1e)

MIGRATION PERFORMANCE:
├─ Avg Generation Time: 45s
├─ Success Rate: 96.2%
├─ Rollback Success: 100%
└─ Validation Coverage: 100%

UPCOMING MIGRATIONS:
├─ PostgreSQL preparation scripts (planned)
├─ Performance optimization indexes
└─ Audit logging tables
```

### Performance Report
```
📊 PERFORMANCE ANALYSIS REPORT  
Generated: 2025-08-22 15:45:33

DATABASE PERFORMANCE:
├─ Query Response Time (avg): 45ms ✅
├─ Slow Queries (>100ms): 12 ⚠️
├─ Index Usage: 87% ✅
├─ Connection Pool: 4/20 (20%) ✅
└─ Database Size: 1.3MB

SLOW QUERIES DETECTED:
├─ SELECT * FROM event_logs WHERE timestamp... (145ms)
├─ SELECT device.*, relay_board.* FROM devices... (132ms)
└─ SELECT COUNT(*) FROM telemetry_data... (128ms)

OPTIMIZATION RECOMMENDATIONS:
├─ Add index on event_logs.timestamp ✅
├─ Optimize device joins with proper indexes
├─ Consider partitioning telemetry_data
└─ Review query patterns for N+1 problems

TRENDS (7 days):
├─ Performance: ↘️ -5% (degradation detected)
├─ Query Volume: ↗️ +15% (increased usage)
├─ Database Size: ↗️ +8% (normal growth)
└─ Connection Usage: ➡️ stable
```

## 🔗 API Endpoints

### Dashboard API
```python
# Dashboard REST API endpoints
GET  /api/agents/status           # Agent status overview
GET  /api/agents/{id}/details     # Detailed agent info
POST /api/agents/{id}/execute     # Manual agent execution
POST /api/agents/{id}/pause       # Pause agent
POST /api/agents/{id}/resume      # Resume agent

GET  /api/metrics/summary         # Metrics summary
GET  /api/metrics/{agent}/history # Historical metrics
GET  /api/metrics/trends          # Trend analysis

GET  /api/alerts/active           # Active alerts
POST /api/alerts/{id}/acknowledge # Acknowledge alert
POST /api/alerts/{id}/escalate    # Escalate alert

GET  /api/logs/{agent}            # Agent logs
GET  /api/activity/recent         # Recent activity
GET  /api/reports/{type}          # Generate reports
```

### WebSocket Events
```javascript
// Real-time updates via WebSocket
ws://localhost:8090/ws/dashboard

// Event types:
{
  "type": "agent_status_change",
  "agent": "A01-migration-creator", 
  "status": "running"
}

{
  "type": "new_alert",
  "alert": {
    "id": "alert_123",
    "severity": "high",
    "message": "Performance degradation detected"
  }
}

{
  "type": "metrics_update",
  "agent": "A05-performance-analyzer",
  "metrics": {
    "execution_time": 90,
    "success_rate": 88.9
  }
}
```

## 🚀 Access Dashboard

### Local Development
```bash
# Start dashboard server
python database/docs/agents/dashboard.py --serve

# Dashboard URL
http://localhost:8090

# API Documentation
http://localhost:8090/docs

# WebSocket test
http://localhost:8090/ws-test
```

### Production Deployment
```yaml
# docker-compose.yml
services:
  agents-dashboard:
    image: autocore/agents-dashboard:latest
    ports:
      - "8090:8090"
    environment:
      - DATABASE_URL=sqlite:///autocore.db
      - AGENTS_CONFIG_PATH=/config/agents.yaml
    volumes:
      - ./database:/database
      - ./config:/config
```

---

**Dashboard URL**: http://localhost:8090  
**API Docs**: http://localhost:8090/docs  
**Metrics Endpoint**: http://localhost:8090/api/metrics/summary  
**Health Check**: http://localhost:8090/health