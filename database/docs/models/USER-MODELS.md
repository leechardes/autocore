# 👥 User Models Documentation

Documentação dos models relacionados a usuários, autenticação e logs de eventos do AutoCore.

## 📋 Visão Geral

Os User Models gerenciam autenticação, autorização e auditoria do sistema AutoCore, incluindo controle de acesso por roles e logging de eventos.

### 🏗️ Estrutura
```
User (Usuário)
    └── EventLog (Logs de ações)
```

## 👤 User Model

Usuários do sistema com diferentes níveis de acesso e permissões.

### 📊 Schema
```python
class User(Base):
    __tablename__ = 'users'
    
    # Identificação
    id = Column(Integer, primary_key=True)
    username = Column(String(50), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    
    # Informações Pessoais
    full_name = Column(String(100), nullable=True)
    email = Column(String(100), unique=True, nullable=True)
    
    # Controle de Acesso
    role = Column(String(50), default='operator', nullable=False)
    pin_code = Column(String(10), nullable=True)    # PIN para displays
    
    # Status
    is_active = Column(Boolean, default=True)
    last_login = Column(DateTime, nullable=True)
    
    # Meta
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
```

### 🔐 User Roles

| Role | Descrição | Permissões | Acesso |
|------|-----------|------------|--------|
| `admin` | Administrador | Tudo | Todas as telas |
| `manager` | Gerente | Controle + Configuração | Controle + Settings |
| `operator` | Operador | Controle básico | Apenas controles |
| `viewer` | Visualizador | Apenas leitura | Dashboards |
| `maintenance` | Manutenção | Diagnósticos | Ferramentas específicas |

### 🏷️ Role Permissions Matrix

| Recurso | Admin | Manager | Operator | Viewer | Maintenance |
|---------|-------|---------|----------|--------|-------------|
| **Dashboard** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Relay Control** | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Device Config** | ✅ | ✅ | ❌ | ❌ | ✅ |
| **User Management** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **System Settings** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Logs/Audit** | ✅ | ✅ | ❌ | ❌ | ✅ |
| **Macros** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Emergency Stop** | ✅ | ✅ | ✅ | ❌ | ✅ |

### 📱 PIN Code System
```python
# PIN para acesso rápido em displays touchscreen
pin_code = Column(String(10), nullable=True)

# Exemplos de uso
admin_user.pin_code = "1234"      # PIN administrativo
operator_user.pin_code = "9876"   # PIN operacional
viewer_user.pin_code = None       # Sem PIN (login completo)
```

### 🔒 Password Security
```python
# Hash seguro da senha (implementação externa)
import bcrypt

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def verify_password(password: str, hash: str) -> bool:
    return bcrypt.checkpw(password.encode('utf-8'), hash.encode('utf-8'))

# Armazenamento
user.password_hash = hash_password("user_password")
```

### 📈 Índices
```python
Index('idx_users_username', 'username')  # Login lookup
Index('idx_users_email', 'email')        # Email lookup  
Index('idx_users_role', 'role')          # Permission filtering
```

## 📋 EventLog Model

Logs detalhados de eventos e ações do sistema para auditoria e troubleshooting.

### 📊 Schema
```python
class EventLog(Base):
    __tablename__ = 'event_logs'
    
    # Identificação
    id = Column(Integer, primary_key=True)
    timestamp = Column(DateTime, default=func.now(), nullable=False)
    
    # Categorização
    event_type = Column(String(50), nullable=False)    # relay_control, login, config_change
    source = Column(String(100), nullable=False)       # device_uuid, user_id, system
    target = Column(String(100), nullable=True)        # relay_id, screen_id, device_id
    action = Column(String(100), nullable=True)        # on, off, create, update, delete
    
    # Dados
    payload = Column(Text, nullable=True)              # JSON com detalhes
    
    # Contexto
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    ip_address = Column(String(15), nullable=True)     # IP de origem
    
    # Resultado
    status = Column(String(20), nullable=True)         # success, error, warning
    error_message = Column(Text, nullable=True)        # Detalhes do erro
```

### 🏷️ Event Types

| Event Type | Descrição | Source | Target | Action |
|------------|-----------|--------|--------|--------|
| `relay_control` | Controle de relé | user_id | relay_channel_id | on/off/toggle |
| `device_status` | Status dispositivo | device_uuid | - | online/offline |
| `user_login` | Login/logout | user_id | - | login/logout |
| `config_change` | Mudança config | user_id | config_item | update |
| `screen_access` | Acesso tela | user_id | screen_id | view |
| `macro_execution` | Execução macro | user_id | macro_id | execute |
| `system_startup` | Inicialização | system | - | startup |
| `backup_created` | Backup criado | system | backup_file | create |

### 📊 Event Status
| Status | Descrição | Uso |
|--------|-----------|-----|
| `success` | Ação executada | Operação normal |
| `error` | Erro na execução | Falhas, exceptions |
| `warning` | Aviso/atenção | Situações suspeitas |

### 🔗 Relationships
```python
# N:1 para usuário (se aplicável)
user = relationship("User")
```

### 📈 Índices
```python
Index('idx_events_timestamp', 'timestamp')      # Busca temporal
Index('idx_events_type', 'event_type')         # Filtro por tipo
Index('idx_events_source', 'source')           # Filtro por origem
```

## 🔄 User Management Workflows

### User Creation
```python
# Criar novo usuário
def create_user(username: str, password: str, role: str = 'operator'):
    user = User(
        username=username,
        password_hash=hash_password(password),
        role=role,
        is_active=True
    )
    session.add(user)
    
    # Log do evento
    log_event(
        event_type='user_management',
        source='admin',
        target=user.username,
        action='create',
        status='success'
    )
    
    session.commit()
    return user
```

### Authentication Flow
```python
def authenticate_user(username: str, password: str) -> User:
    user = session.query(User).filter_by(
        username=username,
        is_active=True
    ).first()
    
    if user and verify_password(password, user.password_hash):
        # Atualizar último login
        user.last_login = datetime.now()
        
        # Log successful login
        log_event(
            event_type='user_login',
            source=str(user.id),
            action='login',
            user_id=user.id,
            status='success'
        )
        
        session.commit()
        return user
    else:
        # Log failed login
        log_event(
            event_type='user_login',
            source=username,
            action='login_failed',
            status='error',
            error_message='Invalid credentials'
        )
        return None
```

### PIN Authentication
```python
def authenticate_pin(pin: str) -> User:
    user = session.query(User).filter_by(
        pin_code=pin,
        is_active=True
    ).first()
    
    if user:
        log_event(
            event_type='pin_login',
            source=str(user.id),
            action='pin_access',
            user_id=user.id,
            status='success'
        )
        return user
    
    return None
```

## 📊 Event Logging

### Relay Control Logging
```python
def log_relay_action(user_id: int, relay_channel_id: int, action: str, success: bool):
    log_event(
        event_type='relay_control',
        source=str(user_id),
        target=str(relay_channel_id),
        action=action,
        user_id=user_id,
        status='success' if success else 'error',
        payload=json.dumps({
            'channel_id': relay_channel_id,
            'action': action,
            'timestamp': datetime.now().isoformat()
        })
    )
```

### System Event Logging
```python
def log_system_event(event_type: str, message: str, **kwargs):
    log_event(
        event_type=event_type,
        source='system',
        action='system_event',
        status='info',
        payload=json.dumps({
            'message': message,
            **kwargs
        })
    )
```

### Configuration Change Logging
```python
def log_config_change(user_id: int, config_item: str, old_value, new_value):
    log_event(
        event_type='config_change',
        source=str(user_id),
        target=config_item,
        action='update',
        user_id=user_id,
        status='success',
        payload=json.dumps({
            'config_item': config_item,
            'old_value': str(old_value),
            'new_value': str(new_value)
        })
    )
```

## 🔍 Query Examples

### User Queries
```python
# Usuários ativos por role
admins = session.query(User).filter_by(role='admin', is_active=True).all()
operators = session.query(User).filter_by(role='operator', is_active=True).all()

# Último login
recent_users = session.query(User).filter(
    User.last_login >= datetime.now() - timedelta(days=30)
).order_by(User.last_login.desc()).all()

# Usuários com PIN
pin_users = session.query(User).filter(
    User.pin_code.isnot(None),
    User.is_active == True
).all()
```

### Event Log Queries
```python
# Eventos recentes
recent_events = session.query(EventLog).filter(
    EventLog.timestamp >= datetime.now() - timedelta(hours=24)
).order_by(EventLog.timestamp.desc()).limit(100).all()

# Ações de controle por usuário
user_actions = session.query(EventLog).filter_by(
    user_id=user.id,
    event_type='relay_control'
).order_by(EventLog.timestamp.desc()).all()

# Eventos de erro
error_events = session.query(EventLog).filter_by(
    status='error'
).order_by(EventLog.timestamp.desc()).all()

# Estatísticas por tipo de evento
event_stats = session.query(
    EventLog.event_type,
    func.count(EventLog.id).label('count')
).group_by(EventLog.event_type).all()
```

## 🔐 Security Features

### Role-Based Access Control
```python
def check_permission(user: User, required_role: str) -> bool:
    role_hierarchy = {
        'viewer': 1,
        'operator': 2,
        'maintenance': 2,
        'manager': 3,
        'admin': 4
    }
    
    user_level = role_hierarchy.get(user.role, 0)
    required_level = role_hierarchy.get(required_role, 0)
    
    return user_level >= required_level
```

### Session Management
```python
# Sessões ativas (implementação externa)
active_sessions = {
    'user_id': 1,
    'session_token': 'abc123',
    'created_at': datetime.now(),
    'expires_at': datetime.now() + timedelta(hours=8),
    'ip_address': '192.168.1.100'
}
```

### Audit Queries
```python
# Ações administrativas
admin_actions = session.query(EventLog).join(User).filter(
    User.role == 'admin',
    EventLog.event_type.in_(['user_management', 'config_change'])
).order_by(EventLog.timestamp.desc()).all()

# Tentativas de login falhadas
failed_logins = session.query(EventLog).filter(
    EventLog.event_type == 'user_login',
    EventLog.action == 'login_failed'
).order_by(EventLog.timestamp.desc()).all()
```

## 🔗 Integration Points

### Screen Permission Integration
```sql
-- Screens que requerem permissão específica
SELECT s.* FROM screens s 
WHERE s.required_permission IS NULL 
   OR s.required_permission = 'viewer'  -- Para user viewer
```

### Relay Access Control
```python
# Verificar se usuário pode controlar relé específico
def can_control_relay(user: User, relay_channel: RelayChannel) -> bool:
    # Operators+ podem controlar relés
    if user.role in ['operator', 'manager', 'admin', 'maintenance']:
        return True
    return False
```

### Event Correlation
```python
# Correlacionar eventos de um dispositivo
device_events = session.query(EventLog).filter(
    or_(
        EventLog.source == device.uuid,
        EventLog.target == str(device.id)
    )
).order_by(EventLog.timestamp.desc()).all()
```

---

**Próximos passos**:
1. [Relationships](./relationships.md) - Complete mapping
2. [Security Patterns](../security/access-control.md) - Auth implementation
3. [Audit Logging](../security/audit-logging.md) - Event tracking