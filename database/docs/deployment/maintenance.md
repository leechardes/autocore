# 🔧 Manutenção do Banco de Dados - AutoCore

## 📊 Visão Geral

O AutoCore usa **SQLite** como banco de dados principal, perfeito para nosso cenário:
- ✅ **10 dispositivos** no máximo
- ✅ **Raspberry Pi Zero 2W** com 512MB RAM
- ✅ **Sem necessidade** de migração futura
- ✅ **Zero configuração** e manutenção mínima

## 🏗️ Arquitetura com Repository Pattern

### Por que Repository Pattern?
Mesmo que nunca vamos migrar de SQLite, o Repository Pattern oferece:
- **Código organizado** - Queries SQL centralizadas
- **Manutenção fácil** - Mudanças em um só lugar
- **Testabilidade** - Fácil criar mocks
- **Reusabilidade** - Métodos compartilhados

### Estrutura
```
database/
├── shared/
│   ├── connection.py      # Conexão otimizada com SQLite
│   ├── repositories.py    # Repositories para cada entidade
│   └── __init__.py       # Exports
├── scripts/
│   ├── maintenance.py     # Script de manutenção
│   └── schedule_maintenance.sh # Agendamento cron
└── autocore.db           # Banco de dados SQLite
```

## 💾 Estratégia de Retenção de Dados

### Política de Limpeza
| Tipo de Dado | Retenção | Agregação | Justificativa |
|--------------|----------|-----------|---------------|
| **Telemetria** | 7 dias | Médias horárias após 7 dias | Dados de alta frequência |
| **Logs Info** | 30 dias | Não | Histórico operacional |
| **Logs Erro** | 90 dias | Não | Diagnóstico importante |
| **Configurações** | Permanente | Não | Essencial para operação |
| **Status** | Tempo real | Não | Apenas estado atual |

### Tamanho Estimado
Com 10 dispositivos enviando dados a cada segundo:
- **Sem limpeza:** ~500MB/mês ❌
- **Com limpeza:** ~20MB/mês ✅
- **Com agregação:** ~5MB/mês ✅✅

## 🧹 Scripts de Manutenção

### Uso Manual

```bash
# Ver estatísticas do banco
python database/scripts/maintenance.py stats

# Limpeza simples (remove dados antigos)
python database/scripts/maintenance.py clean

# Vacuum (recupera espaço em disco)
python database/scripts/maintenance.py vacuum

# Manutenção completa (limpeza + agregação + vacuum)
python database/scripts/maintenance.py full
```

### Parâmetros Opcionais
```bash
# Customizar dias de retenção
python maintenance.py clean --telemetry-days 3 --log-days 15

# Manutenção completa sem agregação
python maintenance.py full --no-aggregate
```

## ⏰ Agendamento Automático

### Instalação no Raspberry Pi
```bash
cd /home/pi/autocore/database/scripts
./schedule_maintenance.sh
```

### Tarefas Agendadas
| Frequência | Horário | Tarefa | Descrição |
|------------|---------|--------|-----------|
| **Diária** | 3:00 AM | Clean | Remove telemetria > 7 dias |
| **Semanal** | Dom 4:00 AM | Vacuum | Desfragmenta banco |
| **Mensal** | Dia 1, 2:00 AM | Full | Manutenção completa |
| **Diária** | 2:30 AM | Logs | Rotação de logs do sistema |

### Verificar Agendamentos
```bash
# Ver tarefas agendadas
crontab -l | grep AutoCore

# Ver logs de manutenção
tail -f /home/pi/autocore/logs/maintenance.log
```

## 🚀 Uso com Repository Pattern

### Gateway Usando
```python
from database.shared.repositories import devices, telemetry, events

# Atualizar status do dispositivo
devices.update_status(device_id=1, status='online', ip_address='192.168.1.100')

# Salvar telemetria
telemetry.save(
    device_id=1,
    data_type='sensor',
    key='temperature',
    value=25.5,
    unit='°C'
)

# Registrar evento
events.log(
    event_type='info',
    source='gateway',
    action='device_connected',
    target='device_1'
)
```

### Config App Usando
```python
from database.shared.repositories import devices, relays, config

# Listar dispositivos
all_devices = devices.get_all()
online = devices.get_online_devices()

# Controlar relé
relays.toggle_channel(channel_id=5)
relays.set_channel_state(channel_id=5, state=True)

# Buscar configurações
screens = config.get_screens()
themes = config.get_themes()
```

## 📈 Otimizações para Raspberry Pi

### Pragmas SQLite
Configurados automaticamente em `connection.py`:
```sql
PRAGMA journal_mode=WAL;      -- Permite leitura durante escrita
PRAGMA synchronous=NORMAL;    -- Mais rápido, ainda seguro
PRAGMA cache_size=10000;      -- ~10MB cache em RAM
PRAGMA temp_store=MEMORY;     -- Operações temp em RAM
PRAGMA mmap_size=30000000;    -- 30MB memory-mapped I/O
```

### Performance Tips
1. **Batch inserts** - Agrupe múltiplas inserções
2. **Índices** - Criados nas colunas mais consultadas
3. **WAL mode** - Leitura não bloqueia escrita
4. **Agregação** - Dados antigos viram médias

## 📊 Monitoramento

### Dashboard de Métricas
```python
from database.scripts.maintenance import DatabaseMaintenance

maint = DatabaseMaintenance()
stats = maint.get_statistics()

print(f"Dispositivos: {stats['devices']}")
print(f"Telemetria: {stats['telemetry_records']} registros")
print(f"Tamanho: {stats['database_size']['total_size_mb']} MB")
```

### Alertas Sugeridos
- ⚠️ Banco > 100MB → Executar manutenção
- ⚠️ Telemetria > 100k registros → Executar agregação
- ⚠️ Logs > 50k registros → Executar limpeza

## 🔐 Backup

### Backup Manual
```bash
# Backup simples
cp /home/pi/autocore/database/autocore.db /backup/autocore_$(date +%Y%m%d).db

# Backup com compressão
sqlite3 /home/pi/autocore/database/autocore.db ".backup /tmp/backup.db"
gzip /tmp/backup.db
mv /tmp/backup.db.gz /backup/autocore_$(date +%Y%m%d).db.gz
```

### Backup Automático (Adicionar ao cron)
```bash
# Backup diário às 1:00 AM
0 1 * * * sqlite3 /home/pi/autocore/database/autocore.db ".backup /backup/autocore_$(date +\%Y\%m\%d).db"
```

## 🎯 Comandos Úteis

```bash
# Tamanho do banco
du -h /home/pi/autocore/database/autocore.db

# Integridade do banco
sqlite3 autocore.db "PRAGMA integrity_check"

# Vacuum manual
sqlite3 autocore.db "VACUUM"

# Ver tabelas e tamanhos
sqlite3 autocore.db "SELECT name, SUM(pgsize) FROM dbstat GROUP BY name"

# Estatísticas de I/O
iostat -x 1 | grep mmcblk
```

## 🚨 Troubleshooting

### Banco crescendo muito
```bash
# 1. Verificar o que está ocupando espaço
python maintenance.py stats

# 2. Executar manutenção completa
python maintenance.py full

# 3. Se ainda grande, reduzir retenção
python maintenance.py full --telemetry-days 3 --log-days 7
```

### Banco corrompido
```bash
# Tentar recuperar
sqlite3 autocore.db ".recover" | sqlite3 autocore_recovered.db

# Ou restaurar do backup
cp /backup/autocore_latest.db /home/pi/autocore/database/autocore.db
```

### Performance lenta
```bash
# Recriar índices
sqlite3 autocore.db "REINDEX"

# Analisar e otimizar
sqlite3 autocore.db "ANALYZE"

# Verificar fragmentação
sqlite3 autocore.db "PRAGMA page_count; PRAGMA freelist_count"
```

## 📝 Conclusão

Com esta estrutura:
- ✅ **SQLite é perfeito** para nosso caso (10 dispositivos)
- ✅ **Repository Pattern** organiza o código
- ✅ **Manutenção automática** mantém banco pequeno (<50MB)
- ✅ **Performance otimizada** para Raspberry Pi Zero
- ✅ **Sem necessidade** de migração futura

O banco vai rodar **eternamente** no Pi Zero sem problemas! 🚀

---

**Última Atualização:** 07 de agosto de 2025  
**Maintainer:** Lee Chardes