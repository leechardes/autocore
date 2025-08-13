# 🚀 Guia de Deployment - ESP32-Relay ESP-IDF

Instruções completas para deployment em produção do sistema ESP32-Relay.

## 📖 Índice

- [🏭 Deployment de Produção](#-deployment-de-produção)
- [📦 Build para Produção](#-build-para-produção)
- [🔧 Configuração de Fábrica](#-configuração-de-fábrica)
- [📱 OTA Updates](#-ota-updates)
- [🔄 Automação](#-automação)
- [📊 Monitoramento](#-monitoramento)
- [🛡️ Backup e Recovery](#%EF%B8%8F-backup-e-recovery)

## 🏭 Deployment de Produção

### Hardware Requirements

**ESP32 Specifications:**
- **Chip**: ESP32-WROOM-32 (mínimo)
- **Flash**: 4MB (recomendado: 8MB+)
- **RAM**: 320KB (built-in)
- **WiFi**: 802.11 b/g/n 2.4GHz
- **GPIO**: Mínimo 16 pinos livres para relés

**External Components:**
- Módulos de relé compatíveis com 3.3V/5V
- Fonte de alimentação estável (5V/12V dependendo dos relés)
- Proteção contra surtos
- LED indicadores (opcional)
- Botão de reset (opcional)

### Production Build

```bash
# 1. Clean environment
make fullclean

# 2. Production configuration
idf.py menuconfig
# Set: Optimization Level → Size (-Os)
# Set: Log Level → Warning
# Disable: Debug features

# 3. Build production firmware
idf.py build -DCMAKE_BUILD_TYPE=Release \
  -DCONFIG_COMPILER_OPTIMIZATION_SIZE=y \
  -DCONFIG_ESP32_RELAY_LOG_LEVEL=2 \
  -DCONFIG_ESP32_RELAY_PRODUCTION_BUILD=y

# 4. Generate factory image
make factory-image
```

### Mass Production Flash

```bash
#!/bin/bash
# scripts/mass_production_flash.sh

FIRMWARE_PATH="build/esp32-relay-factory.bin"
DEVICE_COUNT=0

echo "🏭 ESP32-Relay Mass Production Flash"
echo "===================================="

while true; do
    echo "Connect device and press Enter (or 'q' to quit)..."
    read -n 1 input
    
    if [ "$input" = "q" ]; then
        break
    fi
    
    # Auto-detect port
    PORT=$(python scripts/detect_port.py)
    
    if [ -z "$PORT" ]; then
        echo "❌ No ESP32 device detected"
        continue
    fi
    
    echo "📱 Flashing device on $PORT..."
    
    # Flash with verification
    idf.py -p $PORT flash --verify
    
    if [ $? -eq 0 ]; then
        DEVICE_COUNT=$((DEVICE_COUNT + 1))
        echo "✅ Device #$DEVICE_COUNT flashed successfully"
        
        # Generate device label
        DEVICE_ID=$(python scripts/get_device_id.py $PORT)
        echo "Device ID: $DEVICE_ID" | tee -a production_log.txt
    else
        echo "❌ Flash failed"
    fi
    
    echo "Disconnect device and connect next one..."
done

echo "📊 Total devices flashed: $DEVICE_COUNT"
```

## 📦 Build para Produção

### Production Configuration

**sdkconfig.production:**
```ini
# Optimization
CONFIG_COMPILER_OPTIMIZATION_SIZE=y
CONFIG_COMPILER_CXX_EXCEPTIONS=n
CONFIG_COMPILER_CXX_RTTI=n

# Logging
CONFIG_LOG_DEFAULT_LEVEL_WARN=y
CONFIG_ESP32_RELAY_LOG_LEVEL=2

# Security
CONFIG_SECURE_BOOT=y
CONFIG_SECURE_FLASH_ENC_ENABLED=y
CONFIG_ESP32_RELAY_DISABLE_DEBUG=y

# Memory optimization
CONFIG_SPIRAM_SUPPORT=n
CONFIG_ESP32_WIFI_DYNAMIC_RX_BUFFER_NUM=8
CONFIG_LWIP_MAX_SOCKETS=4

# Production features
CONFIG_ESP32_RELAY_PRODUCTION_BUILD=y
CONFIG_ESP32_RELAY_DISABLE_SERIAL_CONFIG=y
CONFIG_ESP32_RELAY_WATCHDOG_ENABLED=y
```

### Makefile Production Targets

```makefile
# Production builds
production: clean
	cp sdkconfig.production sdkconfig
	idf.py build -DCMAKE_BUILD_TYPE=Release

factory-image: production
	$(IDF_PATH)/tools/mkimage.py \
		--output build/esp32-relay-factory.bin \
		--bootloader build/bootloader/bootloader.bin \
		--partition-table build/partition_table/partition-table.bin \
		--app build/esp32-relay.bin

production-test: factory-image
	python scripts/production_test.py
```

### Version Management

```bash
# Auto-increment version
python scripts/version_bump.py patch  # 2.0.1
python scripts/version_bump.py minor  # 2.1.0  
python scripts/version_bump.py major  # 3.0.0

# Build with version
make production VERSION=2.0.1
```

## 🔧 Configuração de Fábrica

### Factory Reset Mechanism

```c
// Factory reset trigger
void check_factory_reset(void) {
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << FACTORY_RESET_PIN),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_ENABLE,
    };
    gpio_config(&io_conf);
    
    // Check if button held during boot
    if (gpio_get_level(FACTORY_RESET_PIN) == 0) {
        ESP_LOGI(TAG, "🏭 Factory reset detected");
        nvs_flash_erase();
        esp_restart();
    }
}
```

### Pre-configuration Script

```python
#!/usr/bin/env python3
# scripts/factory_configure.py
"""
Factory configuration for mass production
"""

import json
import serial
import time
import argparse

class FactoryConfigurator:
    def __init__(self, port, config_file):
        self.port = port
        with open(config_file, 'r') as f:
            self.config = json.load(f)
            
    def configure_device(self):
        """Configure device with factory settings"""
        
        with serial.Serial(self.port, 115200, timeout=5) as ser:
            # Wait for boot
            time.sleep(2)
            
            # Send configuration commands
            commands = [
                f"config wifi_ssid {self.config['wifi']['ssid']}",
                f"config wifi_password {self.config['wifi']['password']}",
                f"config backend_ip {self.config['backend']['ip']}",
                f"config backend_port {self.config['backend']['port']}",
                "config save",
                "restart"
            ]
            
            for cmd in commands:
                ser.write(f"{cmd}\n".encode())
                time.sleep(0.5)
                
        print("✅ Device configured successfully")

# Usage
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", required=True)
    parser.add_argument("--config", default="factory_config.json")
    args = parser.parse_args()
    
    configurator = FactoryConfigurator(args.port, args.config)
    configurator.configure_device()
```

### Factory Config Template

**factory_config.json:**
```json
{
  "wifi": {
    "ssid": "AutoCore_Production",
    "password": "ProductionWiFi2025!"
  },
  "backend": {
    "ip": "10.0.1.100",
    "port": 8081
  },
  "device": {
    "name_prefix": "ESP32-Relay-Prod",
    "location": "Factory Floor",
    "channels": 16
  },
  "production": {
    "firmware_version": "2.0.0",
    "build_date": "2025-08-11",
    "batch_number": "B2025081101"
  }
}
```

## 📱 OTA Updates

### OTA Server Setup

```python
#!/usr/bin/env python3
# ota_server.py
"""
Simple OTA update server
"""

from flask import Flask, send_file, request, jsonify
import os
import hashlib

app = Flask(__name__)

FIRMWARE_DIR = "firmware_releases"

@app.route('/api/ota/check/<device_id>')
def check_update(device_id):
    """Check if update is available"""
    
    current_version = request.args.get('version', '0.0.0')
    
    # Find latest firmware
    latest_file = get_latest_firmware()
    if not latest_file:
        return jsonify({"update_available": False})
    
    latest_version = extract_version_from_filename(latest_file)
    
    if version_greater(latest_version, current_version):
        checksum = calculate_md5(os.path.join(FIRMWARE_DIR, latest_file))
        
        return jsonify({
            "update_available": True,
            "version": latest_version,
            "url": f"/api/ota/download/{latest_file}",
            "size": os.path.getsize(os.path.join(FIRMWARE_DIR, latest_file)),
            "checksum": checksum
        })
    
    return jsonify({"update_available": False})

@app.route('/api/ota/download/<filename>')
def download_firmware(filename):
    """Download firmware file"""
    return send_file(
        os.path.join(FIRMWARE_DIR, filename),
        as_attachment=True,
        mimetype='application/octet-stream'
    )

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

### OTA Client Implementation

```c
// components/network/src/ota_client.c
#include "esp_ota_ops.h"
#include "esp_http_client.h"

esp_err_t perform_ota_update(const char* url) {
    esp_http_client_config_t config = {
        .url = url,
        .timeout_ms = 30000,
        .keep_alive_enable = true,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&config);
    esp_err_t err = esp_https_ota(client, NULL);
    
    if (err == ESP_OK) {
        ESP_LOGI(TAG, "✅ OTA update successful, restarting...");
        esp_restart();
    } else {
        ESP_LOGE(TAG, "❌ OTA update failed: %s", esp_err_to_name(err));
    }
    
    esp_http_client_cleanup(client);
    return err;
}
```

### Automated OTA Deployment

```bash
#!/bin/bash
# scripts/deploy_ota.sh

VERSION=$1
FIRMWARE_FILE="build/esp32-relay-$VERSION.bin"
OTA_SERVER="http://192.168.1.200:8080"

if [ -z "$VERSION" ]; then
    echo "Usage: deploy_ota.sh <version>"
    exit 1
fi

echo "🚀 Deploying OTA update v$VERSION"

# 1. Build firmware
make production VERSION=$VERSION

# 2. Upload to OTA server
curl -X POST "$OTA_SERVER/api/firmware/upload" \
  -F "file=@$FIRMWARE_FILE" \
  -F "version=$VERSION"

# 3. Notify devices
curl -X POST "$OTA_SERVER/api/notify/update" \
  -H "Content-Type: application/json" \
  -d "{\"version\":\"$VERSION\",\"force\":false}"

echo "✅ OTA deployment complete"
```

## 🔄 Automação

### CI/CD Pipeline

**.github/workflows/production.yml:**
```yaml
name: Production Build and Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup ESP-IDF
      uses: espressif/esp-idf-ci-action@v1
      with:
        esp_idf_version: v5.0
        
    - name: Build production firmware
      run: |
        . $IDF_PATH/export.sh
        make production VERSION=${GITHUB_REF#refs/tags/v}
        
    - name: Run tests
      run: |
        python scripts/production_test.py
        
    - name: Generate artifacts
      run: |
        make factory-image
        cp build/esp32-relay-factory.bin esp32-relay-${GITHUB_REF#refs/tags/v}.bin
        
    - name: Upload to OTA server
      env:
        OTA_SERVER: ${{ secrets.OTA_SERVER_URL }}
        OTA_TOKEN: ${{ secrets.OTA_TOKEN }}
      run: |
        curl -X POST "$OTA_SERVER/api/firmware/upload" \
          -H "Authorization: Bearer $OTA_TOKEN" \
          -F "file=@esp32-relay-${GITHUB_REF#refs/tags/v}.bin" \
          -F "version=${GITHUB_REF#refs/tags/v}"
          
    - name: Create GitHub Release
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: ${{ github.ref }}
        release_name: Release ${{ github.ref }}
        body_path: CHANGELOG.md
```

### Production Test Suite

```python
#!/usr/bin/env python3
# scripts/production_test.py
"""
Automated production testing
"""

import serial
import time
import json
import requests

class ProductionTester:
    def __init__(self, port):
        self.port = port
        self.tests_passed = 0
        self.tests_failed = 0
        
    def run_all_tests(self):
        """Run complete test suite"""
        
        tests = [
            self.test_boot_time,
            self.test_wifi_connection,
            self.test_http_api,
            self.test_relay_control,
            self.test_mqtt_communication,
            self.test_memory_usage
        ]
        
        for test in tests:
            try:
                test()
                self.tests_passed += 1
            except Exception as e:
                print(f"❌ {test.__name__}: {e}")
                self.tests_failed += 1
                
        self.print_results()
        
    def test_boot_time(self):
        """Test boot time < 2 seconds"""
        with serial.Serial(self.port, 115200, timeout=10) as ser:
            start_time = time.time()
            
            # Reset device
            ser.dtr = False
            time.sleep(0.1)
            ser.dtr = True
            
            # Wait for ready message
            while True:
                line = ser.readline().decode('utf-8', errors='ignore')
                if 'System initialization complete' in line:
                    boot_time = time.time() - start_time
                    break
                    
            assert boot_time < 2.0, f"Boot time {boot_time:.2f}s > 2.0s"
            print(f"✅ Boot time: {boot_time:.2f}s")
            
    def print_results(self):
        """Print test results"""
        total = self.tests_passed + self.tests_failed
        
        print("\n📊 Production Test Results:")
        print(f"  Passed: {self.tests_passed}/{total}")
        print(f"  Failed: {self.tests_failed}/{total}")
        
        if self.tests_failed == 0:
            print("✅ All tests passed - Device ready for production")
        else:
            print("❌ Some tests failed - Device NOT ready")
            exit(1)

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: production_test.py <port>")
        exit(1)
        
    tester = ProductionTester(sys.argv[1])
    tester.run_all_tests()
```

## 📊 Monitoramento

### Production Monitoring

```python
#!/usr/bin/env python3
# scripts/production_monitor.py
"""
Production fleet monitoring
"""

import paho.mqtt.client as mqtt
import json
import sqlite3
from datetime import datetime

class FleetMonitor:
    def __init__(self, broker_host, db_file):
        self.broker = broker_host
        self.db = sqlite3.connect(db_file)
        self.setup_database()
        
    def setup_database(self):
        """Setup monitoring database"""
        self.db.execute('''
            CREATE TABLE IF NOT EXISTS device_status (
                device_id TEXT,
                timestamp DATETIME,
                status TEXT,
                uptime INTEGER,
                free_memory INTEGER,
                wifi_rssi INTEGER,
                firmware_version TEXT
            )
        ''')
        
    def on_message(self, client, userdata, msg):
        """Process status messages"""
        try:
            topic_parts = msg.topic.split('/')
            device_id = topic_parts[2]
            
            if msg.topic.endswith('/status'):
                data = json.loads(msg.payload.decode())
                
                self.db.execute('''
                    INSERT INTO device_status VALUES 
                    (?, ?, ?, ?, ?, ?, ?)
                ''', (
                    device_id,
                    datetime.now(),
                    data.get('status'),
                    data.get('uptime'),
                    data.get('free_memory'),
                    data.get('wifi_rssi'),
                    data.get('firmware_version')
                ))
                self.db.commit()
                
                # Alert on issues
                if data.get('free_memory', 0) < 10000:
                    self.send_alert(device_id, "Low memory warning")
                    
        except Exception as e:
            print(f"Error processing message: {e}")
            
    def generate_report(self):
        """Generate fleet status report"""
        cursor = self.db.execute('''
            SELECT device_id, MAX(timestamp) as last_seen,
                   status, uptime, free_memory, firmware_version
            FROM device_status 
            GROUP BY device_id
            ORDER BY last_seen DESC
        ''')
        
        devices = cursor.fetchall()
        
        print("🏭 Production Fleet Status Report")
        print("=" * 50)
        
        online_count = 0
        for device in devices:
            device_id, last_seen, status, uptime, memory, version = device
            
            # Check if device is online (last seen < 5 minutes)
            last_dt = datetime.fromisoformat(last_seen)
            minutes_ago = (datetime.now() - last_dt).total_seconds() / 60
            
            if minutes_ago < 5:
                online_count += 1
                status_icon = "🟢"
            else:
                status_icon = "🔴"
                
            print(f"{status_icon} {device_id} | {version} | "
                  f"Memory: {memory//1000}KB | "
                  f"Last seen: {int(minutes_ago)}min ago")
                  
        print(f"\n📊 Summary: {online_count}/{len(devices)} devices online")

# Usage
monitor = FleetMonitor("192.168.1.100", "fleet_monitor.db")

client = mqtt.Client()
client.on_message = monitor.on_message
client.connect("192.168.1.100", 1883, 60)
client.subscribe("autocore/devices/+/status")

# Run monitoring
client.loop_forever()
```

## 🛡️ Backup e Recovery

### Configuration Backup

```bash
#!/bin/bash
# scripts/backup_fleet_configs.sh

MQTT_BROKER="192.168.1.100"
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"

mkdir -p "$BACKUP_DIR"

echo "💾 Backing up fleet configurations..."

# Get list of online devices
DEVICES=$(mosquitto_sub -h "$MQTT_BROKER" -t "autocore/devices/+/status" -C 10 | \
          grep -o '"uuid":"[^"]*"' | \
          sed 's/"uuid"://g' | \
          sed 's/"//g' | \
          sort -u)

for device in $DEVICES; do
    echo "Backing up $device..."
    
    # Request current config
    mosquitto_pub -h "$MQTT_BROKER" \
      -t "autocore/devices/$device/commands/backup" \
      -m '{"command":"backup_config"}'
      
    # Wait for response
    timeout 10 mosquitto_sub -h "$MQTT_BROKER" \
      -t "autocore/devices/$device/config" \
      -C 1 > "$BACKUP_DIR/${device}_config.json"
      
done

echo "✅ Backup complete: $BACKUP_DIR"
```

### Recovery Procedures

```python
#!/usr/bin/env python3
# scripts/recovery.py
"""
Device recovery procedures
"""

import json
import paho.mqtt.client as mqtt
import time

class DeviceRecovery:
    def __init__(self, broker_host):
        self.broker = broker_host
        self.client = mqtt.Client()
        
    def factory_reset_device(self, device_id):
        """Perform factory reset on device"""
        
        print(f"🔄 Factory reset for {device_id}")
        
        self.client.connect(self.broker, 1883, 60)
        
        reset_cmd = {
            "command": "reset",
            "type": "factory",
            "confirm": True
        }
        
        self.client.publish(
            f"autocore/devices/{device_id}/commands/reset",
            json.dumps(reset_cmd)
        )
        
        print("✅ Factory reset command sent")
        
    def restore_config(self, device_id, config_file):
        """Restore device configuration"""
        
        with open(config_file, 'r') as f:
            config = json.load(f)
            
        print(f"📁 Restoring config for {device_id}")
        
        self.client.connect(self.broker, 1883, 60)
        
        restore_cmd = {
            "command": "restore_config",
            "config": config
        }
        
        self.client.publish(
            f"autocore/devices/{device_id}/commands/restore",
            json.dumps(restore_cmd)
        )
        
        print("✅ Configuration restore command sent")

# Usage
recovery = DeviceRecovery("192.168.1.100")

# Recovery procedures
recovery.factory_reset_device("esp32_relay_broken")
time.sleep(60)  # Wait for reset
recovery.restore_config("esp32_relay_broken", "backup_config.json")
```

---

## 🔗 Links Relacionados

- [⚙️ Configuração](CONFIGURATION.md) - Configuração detalhada
- [🛠️ Development](DEVELOPMENT.md) - Guia para desenvolvedores  
- [🚨 Troubleshooting](TROUBLESHOOTING.md) - Soluções para problemas
- [🔒 Security](SECURITY.md) - Considerações de segurança
- [💾 Hardware](HARDWARE.md) - Especificações de hardware

---

**Documento**: Guia de Deployment ESP32-Relay  
**Versão**: 2.0.0  
**Última Atualização**: 11 de Agosto de 2025  
**Autor**: AutoCore Team