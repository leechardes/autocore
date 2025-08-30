# 🗄️ Database Schema

## 📋 Overview
Complete database schema documentation for AutoCore Backend PostgreSQL database.

## 🏗️ Schema Architecture

### Core Tables

#### Users Management
```sql
-- users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Device Registry  
```sql
-- devices table
CREATE TABLE devices (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) DEFAULT 'esp32',
    ip_address INET,
    mac_address VARCHAR(17),
    firmware_version VARCHAR(20),
    is_online BOOLEAN DEFAULT false,
    last_seen TIMESTAMP,
    user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Relay Control
```sql
-- relays table
CREATE TABLE relays (
    id SERIAL PRIMARY KEY,
    device_id INTEGER REFERENCES devices(id),
    relay_index INTEGER NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT false,
    current_state BOOLEAN DEFAULT false,
    auto_mode BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(device_id, relay_index)
);
```

## 📊 Relationships

### Entity Relationship Diagram
```
Users (1) ----< (N) Devices
Devices (1) ----< (N) Relays  
Devices (1) ----< (N) Screens
Screens (N) ----< (M) Components
Users (1) ----< (N) Telemetry
```

### Foreign Keys
- `devices.user_id` → `users.id`
- `relays.device_id` → `devices.id`
- `screens.device_id` → `devices.id`
- `telemetry.device_id` → `devices.id`
- `telemetry.user_id` → `users.id`

## 🔍 Indexes

### Performance Indexes
```sql
-- Device lookup optimization
CREATE INDEX idx_devices_device_id ON devices(device_id);
CREATE INDEX idx_devices_user_id ON devices(user_id);
CREATE INDEX idx_devices_is_online ON devices(is_online);

-- Relay state queries
CREATE INDEX idx_relays_device_id ON relays(device_id);
CREATE INDEX idx_relays_is_active ON relays(is_active);

-- Telemetry time-series
CREATE INDEX idx_telemetry_device_timestamp ON telemetry(device_id, timestamp);
CREATE INDEX idx_telemetry_timestamp ON telemetry(timestamp DESC);
```

## 🔧 Constraints

### Data Integrity Rules
- All device_ids must be unique across the system
- Relay indexes must be unique per device (0-7 for ESP32)
- Email addresses must be valid format
- MAC addresses must follow standard format
- Firmware versions follow semantic versioning

### Check Constraints
```sql
-- Relay index bounds
ALTER TABLE relays ADD CONSTRAINT chk_relay_index 
    CHECK (relay_index >= 0 AND relay_index <= 7);

-- Valid MAC address format
ALTER TABLE devices ADD CONSTRAINT chk_mac_format
    CHECK (mac_address ~* '^([0-9A-F]{2}[:-]){5}[0-9A-F]{2}$');
```

## 📈 Migrations

### Migration Strategy
- **Alembic** for version control
- **Backward compatibility** maintained
- **Data preservation** during schema changes
- **Rollback procedures** documented

### Recent Migrations
- `001_initial_schema` - Base tables creation
- `002_add_telemetry` - Historical data storage
- `003_device_metadata` - Extended device info
- `004_user_preferences` - User customizations

## 🔒 Security

### Access Control
- **Row Level Security** for multi-tenant data
- **Connection pooling** with authentication
- **Encrypted connections** required
- **Audit logging** for sensitive operations

### Data Protection
- Password hashing with bcrypt
- Personal data anonymization
- GDPR compliance features
- Secure backup procedures

---
*Schema version: 1.4.0 | Last updated: 2025-01-28*