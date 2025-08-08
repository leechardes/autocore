# 🔧 Estratégia de Ambientes Virtuais - AutoCore

## 🎯 Decisão: Um .venv por Subprojeto

Após análise, optamos por **ambientes virtuais isolados** para cada subprojeto.

## 📊 Estrutura Final

```
AutoCore/
├── database/
│   ├── .venv/            # ~50MB - SQLAlchemy, Alembic
│   └── requirements.txt
├── gateway/
│   ├── .venv/            # ~40MB - paho-mqtt, asyncio
│   └── requirements.txt
└── config-app/
    └── backend/
        ├── .venv/        # ~60MB - FastAPI, uvicorn
        └── requirements.txt
```

**Total estimado:** ~150MB (aceitável no Pi Zero 2W com SD de 8GB+)

## ✅ Vantagens na Implantação

### 1. Deploy Independente
```bash
# Atualizar APENAS o gateway sem afetar config-app
./deploy.sh gateway deploy

# Config-app continua rodando sem interrupção
```

### 2. Rollback Seguro
```bash
# Problema no gateway? Rollback sem afetar outros
cd gateway
git checkout v1.0.0
source .venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart autocore-gateway
```

### 3. Testes Isolados
```bash
# Testar nova versão do FastAPI no config-app
cd config-app/backend
source .venv/bin/activate
pip install fastapi==0.105.0  # Versão nova
# Testes...
# Se falhar, outros serviços continuam funcionando
```

## 🚀 Otimizações para Raspberry Pi

### 1. Compartilhar Pacotes do Sistema
```bash
# Criar venv que usa pacotes do sistema quando possível
python3 -m venv .venv --system-site-packages
```

### 2. Cache de Pip Compartilhado
```bash
# Durante instalação inicial
export PIP_CACHE_DIR=/tmp/pip-cache
pip install -r requirements.txt
```

### 3. Limpeza Periódica
```bash
# Remover cache e arquivos desnecessários
find . -type d -name "__pycache__" -exec rm -r {} +
find . -type f -name "*.pyc" -delete
pip cache purge
```

## 📦 Requirements Otimizados

### database/requirements.txt
```txt
# Essenciais apenas
sqlalchemy==2.0.23
alembic==1.13.0
click==8.1.7
python-dotenv==1.0.0
```

### gateway/requirements.txt
```txt
# MQTT e async
paho-mqtt==1.6.1
aiofiles==23.2.1
python-dotenv==1.0.0
```

### config-app/backend/requirements.txt
```txt
# FastAPI mínimo
fastapi==0.104.1
uvicorn[standard]==0.24.0
python-multipart==0.0.6
python-dotenv==1.0.0
```

## 🔄 Systemd Services

Cada serviço tem seu próprio unit file com venv específico:

```ini
# /etc/systemd/system/autocore-gateway.service
[Service]
ExecStart=/home/pi/autocore/gateway/.venv/bin/python main.py

# /etc/systemd/system/autocore-config-app.service
[Service]
ExecStart=/home/pi/autocore/config-app/backend/.venv/bin/uvicorn main:app
```

## 📋 Checklist de Implantação

- [ ] Executar `setup_environments.sh` para criar todos os venvs
- [ ] Configurar systemd services
- [ ] Habilitar serviços: `sudo systemctl enable autocore-*`
- [ ] Testar deploy independente de cada serviço
- [ ] Configurar monitoramento de espaço em disco
- [ ] Agendar limpeza periódica de cache

## 🔍 Monitoramento

### Verificar Tamanho dos Venvs
```bash
du -sh */.venv */backend/.venv
```

### Verificar Memória por Processo
```bash
ps aux | grep python | awk '{sum+=$6} END {print "Total: " sum/1024 " MB"}'
```

### Logs Separados
```bash
journalctl -u autocore-gateway -f     # Logs do gateway
journalctl -u autocore-config-app -f  # Logs do config-app
```

## 🆘 Troubleshooting

### Problema: "No space left on device"
```bash
# Limpar caches e logs antigos
sudo apt clean
sudo journalctl --vacuum-time=2d
find /home/pi/autocore -name "*.pyc" -delete
find /home/pi/autocore -name "__pycache__" -type d -exec rm -rf {} +
```

### Problema: "Module not found" após deploy
```bash
# Verificar se está usando o venv correto
which python  # Deve mostrar /path/to/.venv/bin/python

# Reinstalar dependências
pip install -r requirements.txt --force-reinstall
```

### Problema: Conflito de portas
```bash
# Cada serviço tem sua porta
# Gateway: Não usa porta HTTP
# Config-app: 8000
# Database: Não é serviço

sudo netstat -tlnp | grep python
```

## 📝 Conclusão

A estratégia de **venvs isolados** oferece:
- ✅ Deploy seguro e independente
- ✅ Isolamento de falhas
- ✅ Facilidade de manutenção
- ✅ Rollback granular
- ✅ Alinhamento com arquitetura de microserviços

O custo de ~150MB de espaço é compensável pelos benefícios operacionais.

---

**Última Atualização:** 07 de agosto de 2025  
**Autor:** Lee Chardes