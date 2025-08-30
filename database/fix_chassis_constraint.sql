-- Migração para corrigir constraint do chassi
-- Problema: CHECK (length(chassis) >= 17) impede veículos antigos
-- Solução: Alterar para aceitar 11-30 caracteres

BEGIN TRANSACTION;

-- 1. Criar tabela temporária sem o constraint problemático
CREATE TABLE vehicles_new (
    id INTEGER NOT NULL, 
    uuid VARCHAR(36) NOT NULL, 
    plate VARCHAR(10) NOT NULL, 
    chassis VARCHAR(30) NOT NULL, 
    renavam VARCHAR(20) NOT NULL, 
    brand VARCHAR(50) NOT NULL, 
    model VARCHAR(100) NOT NULL, 
    version VARCHAR(100), 
    year_manufacture INTEGER NOT NULL, 
    year_model INTEGER NOT NULL, 
    color VARCHAR(30), 
    color_code VARCHAR(10), 
    fuel_type VARCHAR(20) NOT NULL, 
    engine_capacity INTEGER, 
    engine_power INTEGER, 
    engine_torque INTEGER, 
    transmission VARCHAR(20), 
    category VARCHAR(30) NOT NULL, 
    usage_type VARCHAR(30), 
    user_id INTEGER NOT NULL, 
    primary_device_id INTEGER, 
    status VARCHAR(20) NOT NULL, 
    odometer INTEGER NOT NULL, 
    odometer_unit VARCHAR(5) NOT NULL, 
    last_location TEXT, 
    next_maintenance_date DATETIME, 
    next_maintenance_km INTEGER, 
    last_maintenance_date DATETIME, 
    last_maintenance_km INTEGER, 
    insurance_expiry DATETIME, 
    license_expiry DATETIME, 
    inspection_expiry DATETIME, 
    vehicle_config TEXT, 
    notes TEXT, 
    tags TEXT, 
    is_active BOOLEAN NOT NULL, 
    is_tracked BOOLEAN NOT NULL, 
    created_at DATETIME NOT NULL, 
    updated_at DATETIME NOT NULL, 
    deleted_at DATETIME, 
    PRIMARY KEY (id), 
    UNIQUE (uuid), 
    UNIQUE (plate), 
    UNIQUE (chassis), 
    UNIQUE (renavam), 
    CHECK (id = 1), 
    CHECK (fuel_type IN ('flex', 'gasoline', 'ethanol', 'diesel', 'electric', 'hybrid')), 
    CHECK (category IN ('passenger', 'commercial', 'motorcycle', 'truck', 'bus')), 
    CHECK (status IN ('active', 'inactive', 'maintenance', 'retired', 'sold')), 
    CHECK (year_manufacture >= 1900 AND year_manufacture <= 2030), 
    CHECK (year_model >= year_manufacture AND year_model <= (year_manufacture + 1)), 
    CHECK (odometer >= 0), 
    CHECK (length(plate) >= 7 AND length(plate) <= 8), 
    CHECK (length(chassis) >= 11 AND length(chassis) <= 30),  -- CORREÇÃO: 11-30 chars
    FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
    FOREIGN KEY(primary_device_id) REFERENCES devices (id) ON DELETE SET NULL
);

-- 2. Copiar dados existentes
INSERT INTO vehicles_new 
SELECT * FROM vehicles;

-- 3. Remover tabela antiga
DROP TABLE vehicles;

-- 4. Renomear nova tabela
ALTER TABLE vehicles_new RENAME TO vehicles;

-- 5. Recriar índices (se houver)
CREATE INDEX IF NOT EXISTS idx_vehicles_uuid ON vehicles(uuid);
CREATE INDEX IF NOT EXISTS idx_vehicles_plate ON vehicles(plate);
CREATE INDEX IF NOT EXISTS idx_vehicles_chassis ON vehicles(chassis);
CREATE INDEX IF NOT EXISTS idx_vehicles_status ON vehicles(status);

COMMIT;

-- Verificar resultado
SELECT name, sql FROM sqlite_master WHERE type='table' AND name='vehicles';