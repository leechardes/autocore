-- Migration: Padronizar todos os tipos para minúsculo
-- Autor: Claude
-- Data: 2025-08-19
-- Objetivo: Converter todos os valores de tipos/enums para lowercase

BEGIN TRANSACTION;

-- ====================================
-- 1. DEVICE TYPES
-- ====================================

-- Converter device types para minúsculo
UPDATE devices 
SET type = LOWER(type) 
WHERE type IS NOT NULL;

-- Casos específicos que podem existir
UPDATE devices 
SET type = 'esp32_relay' 
WHERE type IN ('ESP32_RELAY', 'esp32-relay', 'relay', 'RELAY');

UPDATE devices 
SET type = 'esp32_display' 
WHERE type IN ('ESP32_DISPLAY', 'esp32-display', 'display', 'DISPLAY');

UPDATE devices 
SET type = 'sensor_board' 
WHERE type IN ('ESP32_DISPLAY_SMALL', 'esp32_display_small', 'sensor', 'SENSOR_BOARD');

UPDATE devices 
SET type = 'gateway' 
WHERE type IN ('ESP32_DISPLAY_LARGE', 'esp32_display_large', 'gateway', 'GATEWAY');

-- ====================================
-- 2. DEVICE STATUS
-- ====================================

-- Converter device status para minúsculo
UPDATE devices 
SET status = LOWER(status) 
WHERE status IS NOT NULL;

-- Casos específicos
UPDATE devices 
SET status = 'online' 
WHERE status IN ('ONLINE', 'Online', 'CONNECTED');

UPDATE devices 
SET status = 'offline' 
WHERE status IN ('OFFLINE', 'Offline', 'DISCONNECTED');

UPDATE devices 
SET status = 'error' 
WHERE status IN ('ERROR', 'Error', 'FAULT');

UPDATE devices 
SET status = 'maintenance' 
WHERE status IN ('MAINTENANCE', 'Maintenance', 'MAINT');

-- ====================================
-- 3. RELAY CHANNEL FUNCTION TYPES
-- ====================================

-- Converter function_type para minúsculo
UPDATE relay_channels 
SET function_type = LOWER(function_type) 
WHERE function_type IS NOT NULL;

-- Casos específicos
UPDATE relay_channels 
SET function_type = 'toggle' 
WHERE function_type IN ('TOGGLE', 'Toggle');

UPDATE relay_channels 
SET function_type = 'momentary' 
WHERE function_type IN ('MOMENTARY', 'Momentary', 'PUSH');

UPDATE relay_channels 
SET function_type = 'pulse' 
WHERE function_type IN ('PULSE', 'Pulse');

UPDATE relay_channels 
SET function_type = 'timer' 
WHERE function_type IN ('TIMER', 'Timer', 'TIMED');

-- ====================================
-- 4. RELAY CHANNEL PROTECTION MODES
-- ====================================

-- Converter protection_mode para minúsculo
UPDATE relay_channels 
SET protection_mode = LOWER(protection_mode) 
WHERE protection_mode IS NOT NULL;

-- Casos específicos
UPDATE relay_channels 
SET protection_mode = 'none' 
WHERE protection_mode IN ('NONE', 'None', 'NO_PROTECTION');

UPDATE relay_channels 
SET protection_mode = 'interlock' 
WHERE protection_mode IN ('CONFIRM', 'Confirm', 'INTERLOCK', 'Interlock');

UPDATE relay_channels 
SET protection_mode = 'exclusive' 
WHERE protection_mode IN ('PASSWORD', 'Password', 'EXCLUSIVE', 'Exclusive');

UPDATE relay_channels 
SET protection_mode = 'timed' 
WHERE protection_mode IN ('TIMED', 'Timed', 'TIME_BASED');

-- ====================================
-- 5. SCREEN ITEM TYPES
-- ====================================

-- Converter item_type para minúsculo
UPDATE screen_items 
SET item_type = LOWER(item_type) 
WHERE item_type IS NOT NULL;

-- Casos específicos
UPDATE screen_items 
SET item_type = 'display' 
WHERE item_type IN ('DISPLAY', 'Display');

UPDATE screen_items 
SET item_type = 'button' 
WHERE item_type IN ('BUTTON', 'Button');

UPDATE screen_items 
SET item_type = 'switch' 
WHERE item_type IN ('SWITCH', 'Switch');

UPDATE screen_items 
SET item_type = 'gauge' 
WHERE item_type IN ('GAUGE', 'Gauge');

-- ====================================
-- 6. SCREEN ITEM ACTION TYPES
-- ====================================

-- Converter action_type para minúsculo
UPDATE screen_items 
SET action_type = LOWER(action_type) 
WHERE action_type IS NOT NULL;

-- Casos específicos
UPDATE screen_items 
SET action_type = 'relay_control' 
WHERE action_type IN ('RELAY_CONTROL', 'Relay_Control', 'relay-control', 'RELAY-CONTROL');

UPDATE screen_items 
SET action_type = 'command' 
WHERE action_type IN ('COMMAND', 'Command');

UPDATE screen_items 
SET action_type = 'macro' 
WHERE action_type IN ('MACRO', 'Macro');

UPDATE screen_items 
SET action_type = 'navigation' 
WHERE action_type IN ('NAVIGATION', 'Navigation');

UPDATE screen_items 
SET action_type = 'preset' 
WHERE action_type IN ('PRESET', 'Preset');

-- ====================================
-- 7. SCREEN TYPES
-- ====================================

-- Converter screen_type para minúsculo se existir
UPDATE screens 
SET screen_type = LOWER(screen_type) 
WHERE screen_type IS NOT NULL;

-- ====================================
-- 8. TELEMETRY DATA TYPES
-- ====================================

-- Converter data_type para minúsculo
UPDATE telemetry_data 
SET data_type = LOWER(data_type) 
WHERE data_type IS NOT NULL;

-- ====================================
-- 9. EVENT LOG TYPES
-- ====================================

-- Converter event_type para minúsculo
UPDATE event_logs 
SET event_type = LOWER(event_type) 
WHERE event_type IS NOT NULL;

-- Converter status para minúsculo
UPDATE event_logs 
SET status = LOWER(status) 
WHERE status IS NOT NULL;

-- ====================================
-- 10. USER ROLES
-- ====================================

-- Converter role para minúsculo
UPDATE users 
SET role = LOWER(role) 
WHERE role IS NOT NULL;

-- Casos específicos
UPDATE users 
SET role = 'admin' 
WHERE role IN ('ADMIN', 'Admin', 'Administrator');

UPDATE users 
SET role = 'operator' 
WHERE role IN ('OPERATOR', 'Operator');

UPDATE users 
SET role = 'viewer' 
WHERE role IN ('VIEWER', 'Viewer', 'USER', 'User');

-- ====================================
-- 11. CAN SIGNAL TYPES
-- ====================================

-- Converter data_type para minúsculo
UPDATE can_signals 
SET data_type = LOWER(data_type) 
WHERE data_type IS NOT NULL;

-- Converter byte_order para minúsculo
UPDATE can_signals 
SET byte_order = LOWER(byte_order) 
WHERE byte_order IS NOT NULL;

-- Converter category para minúsculo
UPDATE can_signals 
SET category = LOWER(category) 
WHERE category IS NOT NULL;

-- ====================================
-- 12. MACRO TRIGGER TYPES
-- ====================================

-- Converter trigger_type para minúsculo
UPDATE macros 
SET trigger_type = LOWER(trigger_type) 
WHERE trigger_type IS NOT NULL;

-- ====================================
-- 13. ICON CATEGORIES
-- ====================================

-- Converter category para minúsculo
UPDATE icons 
SET category = LOWER(category) 
WHERE category IS NOT NULL;

-- ====================================
-- VERIFICAÇÕES FINAIS
-- ====================================

-- Contar registros por tipo após migração
SELECT 'devices.type' as campo, type, COUNT(*) as total FROM devices WHERE type IS NOT NULL GROUP BY type
UNION ALL
SELECT 'devices.status' as campo, status, COUNT(*) as total FROM devices WHERE status IS NOT NULL GROUP BY status
UNION ALL
SELECT 'relay_channels.function_type' as campo, function_type, COUNT(*) as total FROM relay_channels WHERE function_type IS NOT NULL GROUP BY function_type
UNION ALL
SELECT 'relay_channels.protection_mode' as campo, protection_mode, COUNT(*) as total FROM relay_channels WHERE protection_mode IS NOT NULL GROUP BY protection_mode
UNION ALL
SELECT 'screen_items.item_type' as campo, item_type, COUNT(*) as total FROM screen_items WHERE item_type IS NOT NULL GROUP BY item_type
UNION ALL
SELECT 'screen_items.action_type' as campo, action_type, COUNT(*) as total FROM screen_items WHERE action_type IS NOT NULL GROUP BY action_type;

-- Finalizar transação
COMMIT;

-- Log de conclusão
SELECT 'Migration concluída: padronizar_tipos_minusculo.sql' as resultado, datetime('now', 'localtime') as timestamp;