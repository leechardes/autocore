# 📊 Database Schemas

## 📋 Visão Geral

Definição completa dos esquemas de banco de dados do AutoCore.

## 🗄️ Esquemas Principais

### Core Tables
- `users` - Usuários do sistema
- `devices` - Dispositivos ESP32 registrados
- `relays` - Configuração de relés por device
- `icons` - Ícones do sistema

### UI Tables
- `screens` - Configuração de telas
- `screen_items` - Componentes das telas
- `themes` - Temas visuais
- `user_preferences` - Preferências por usuário

### Configuration Tables
- `device_configs` - Configurações específicas por device
- `system_settings` - Configurações globais

## 📈 Schema Evolution

Consulte o arquivo `schema.dbml` na pasta `architecture/` para o schema visual completo.

## 🔗 Relacionamentos

- User 1:N Devices
- Device 1:N Relays
- Device 1:N Screens
- Screen 1:N ScreenItems