-- Script para padronizar tipos de items na tabela screen_items
-- Executar com: sqlite3 autocore.db < fix_screen_items_types.sql

-- Backup primeiro (sempre importante!)
-- CREATE TABLE screen_items_backup AS SELECT * FROM screen_items;

BEGIN TRANSACTION;

-- 1. Corrigir items de DISPLAY (telemetria)
-- Displays não devem ter action_type nem relay associations
UPDATE screen_items 
SET 
    action_type = NULL,
    action_target = NULL,
    relay_board_id = NULL,
    relay_channel_id = NULL
WHERE item_type = 'display';

-- 2. Padronizar action_type para buttons com relay
-- Buttons com relay devem ter action_type correto
UPDATE screen_items 
SET action_type = 'relay_control'
WHERE item_type = 'button' 
  AND relay_board_id IS NOT NULL 
  AND relay_channel_id IS NOT NULL;

-- 3. Padronizar action_type para switches
UPDATE screen_items 
SET action_type = 'relay_control'
WHERE item_type = 'switch'
  AND relay_board_id IS NOT NULL;

-- 4. Adicionar data_source correto para displays
UPDATE screen_items SET data_source = 'telemetry', data_path = 'speed', data_unit = 'km/h' WHERE name = 'speed';
UPDATE screen_items SET data_source = 'telemetry', data_path = 'rpm', data_unit = 'rpm' WHERE name = 'rpm';
UPDATE screen_items SET data_source = 'telemetry', data_path = 'engine_temp', data_unit = '°C' WHERE name = 'temp';
UPDATE screen_items SET data_source = 'telemetry', data_path = 'fuel_level', data_unit = '%' WHERE name = 'fuel';

-- 5. Garantir que data_format está correto para displays
UPDATE screen_items 
SET data_format = 'number'
WHERE item_type = 'display' 
  AND data_format IS NULL;

-- 6. Limpar action_payload desnecessário de displays
UPDATE screen_items 
SET action_payload = NULL
WHERE item_type = 'display';

-- 7. Verificar mudanças antes de confirmar
SELECT 
    id, 
    item_type, 
    name, 
    action_type, 
    relay_board_id, 
    relay_channel_id,
    data_source,
    data_path,
    data_unit
FROM screen_items 
ORDER BY screen_id, position;

COMMIT;

-- Verificação final
SELECT 
    'Displays corrigidos:' as status,
    COUNT(*) as total 
FROM screen_items 
WHERE item_type = 'display' 
  AND action_type IS NULL;

SELECT 
    'Buttons com relay:' as status,
    COUNT(*) as total 
FROM screen_items 
WHERE item_type = 'button' 
  AND action_type = 'relay_control';

SELECT 
    'Switches com relay:' as status,
    COUNT(*) as total 
FROM screen_items 
WHERE item_type = 'switch' 
  AND action_type = 'relay_control';