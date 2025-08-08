-- Migration: Remove name and location fields from relay_boards table
-- Date: 2025-08-08
-- Description: Removing redundant fields as device name will be used instead

-- SQLite doesn't support dropping columns directly, so we need to recreate the table

-- Step 1: Create new table without the redundant fields
CREATE TABLE relay_boards_new (
    id INTEGER PRIMARY KEY,
    device_id INTEGER NOT NULL,
    total_channels INTEGER NOT NULL DEFAULT 16,
    board_model VARCHAR(50),
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);

-- Step 2: Copy data from old table (using device name as placeholder for name field)
INSERT INTO relay_boards_new (id, device_id, total_channels, board_model, is_active, created_at)
SELECT id, device_id, total_channels, board_model, is_active, created_at
FROM relay_boards;

-- Step 3: Drop old table
DROP TABLE relay_boards;

-- Step 4: Rename new table to original name
ALTER TABLE relay_boards_new RENAME TO relay_boards;

-- Step 5: Recreate index
CREATE INDEX idx_relay_boards_device ON relay_boards(device_id);