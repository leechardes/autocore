# 🚀 Guia de Configuração

## Instalação Inicial

### 1. Preparar Ambiente

```bash
cd /home/pi/autocore/database
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Inicializar Banco

```bash
# Opção 1: Inicialização completa
python src/cli/manage.py init

# Opção 2: Passo a passo
python src/cli/manage.py migrate
python src/cli/manage.py seed
```

### 3. Verificar Instalação

```bash
python src/cli/manage.py status
```

## Configuração de Produção

### Permissões

```bash
# Configurar permissões do banco
chmod 600 autocore.db
chown pi:pi autocore.db

# Configurar diretório
chmod 755 /home/pi/autocore/database
```

### Backup Automático

```bash
# Adicionar ao crontab
crontab -e

# Backup diário às 2h
0 2 * * * cd /home/pi/autocore/database && ./venv/bin/python src/cli/manage.py backup
```

### Manutenção Automática

```bash
# Configurar limpeza automática
cd scripts
./schedule_maintenance.sh
```

## Configuração Avançada

### Variáveis de Ambiente

```bash
# Criar arquivo .env
cat > .env << EOF
DATABASE_PATH=/home/pi/autocore/database/autocore.db
BACKUP_PATH=/mnt/usb/backups
MAINTENANCE_DAYS=7
MAX_DB_SIZE_MB=50
EOF
```

### Otimizações SQLite

As otimizações são aplicadas automaticamente em `shared/connection.py`:

- **WAL Mode**: Permite leitura e escrita simultâneas
- **Memory Cache**: 10MB de cache em RAM
- **MMAP Size**: 30MB mapeados em memória
- **Foreign Keys**: Integridade referencial ativa

### Monitoramento

```bash
# Ver estatísticas
python scripts/maintenance.py stats

# Ver tamanho do banco
du -h autocore.db

# Ver número de conexões
lsof | grep autocore.db
```

## Troubleshooting

### Banco Corrompido

```bash
# Verificar integridade
sqlite3 autocore.db "PRAGMA integrity_check"

# Recuperar de backup
python src/cli/manage.py restore --file backup.gz
```

### Performance Ruim

```bash
# Executar manutenção completa
python scripts/maintenance.py full

# Recriar índices
sqlite3 autocore.db "REINDEX"
```

### Banco Muito Grande

```bash
# Ver o que ocupa espaço
python scripts/maintenance.py stats

# Limpar agressivamente
python src/cli/manage.py clean --days 1
```