# 🔌 Mapa de Portas - AutoCore

## 📊 Portas Utilizadas

| Serviço | Porta | Descrição | Protocolo |
|---------|-------|-----------|-----------|
| **Frontend** | 8080 | Interface React (Vite dev server) | HTTP |
| **Backend API** | 8081 | Config App Backend FastAPI | HTTP/WS |
| **Gateway** | - | Cliente MQTT (não expõe porta) | - |
| **MQTT Broker** | 1883 | Mosquitto MQTT | MQTT |
| **MQTT WebSocket** | 9001 | Mosquitto WS (opcional) | WS |

## 🎯 Organização

As portas foram organizadas de forma sequencial para facilitar memorização e configuração:

### Aplicações Web (8080-8089)
- `8080` - Frontend React (Interface Web)
- `8081` - Backend API (FastAPI)
- `8082-8089` - Reservado para futuros serviços


### Protocolos Específicos
- `1883` - MQTT padrão
- `9001` - MQTT sobre WebSocket

## 🔧 Configuração

### Desenvolvimento Local

```bash
# Config App Backend
cd config-app/backend
make start  # Porta 8080

# Gateway
cd gateway
make start  # Porta 8081

# Frontend
cd config-app/frontend
make start  # Porta 3000
```

### Variáveis de Ambiente

```env
# config-app/backend/.env
CONFIG_APP_PORT=8080

# gateway/.env
GATEWAY_PORT=8081

# config-app/frontend/.env
VITE_API_PORT=8080
```

## 🚀 Deploy no Raspberry Pi

No Raspberry Pi, os serviços são configurados via systemd e usam as mesmas portas:

```bash
# Verificar portas em uso
sudo netstat -tlnp

# Saída esperada:
# :3000  - Frontend React
# :8080  - Config App API
# :8081  - Gateway
# :1883  - MQTT Broker
```

## 🔒 Segurança

### Firewall (ufw)

```bash
# Permitir apenas portas necessárias
sudo ufw allow 3000/tcp  # Frontend
sudo ufw allow 8080/tcp  # API
sudo ufw allow 8081/tcp  # Gateway
sudo ufw allow 1883/tcp  # MQTT
```

### Nginx Proxy (Opcional)

Para produção, use Nginx como proxy reverso na porta 80:

```nginx
server {
    listen 80;
    server_name autocore.local;

    location / {
        proxy_pass http://localhost:3000;
    }

    location /api {
        proxy_pass http://localhost:8080;
    }

    location /gateway {
        proxy_pass http://localhost:8081;
    }
}
```

## 📝 Notas

- **Evite porta 5000** no macOS (conflito com AirPlay)
- **Evite porta 8000** (comum em desenvolvimento)
- Mantenha a sequência 808X para facilitar memorização
- Use variáveis de ambiente para flexibilidade

---

**Última atualização:** Agosto 2025