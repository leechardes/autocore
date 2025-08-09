#!/bin/bash

# Script para fazer backup e resetar o banco de dados do AutoCore
# Com carga inicial de dados padrão

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Diretório do banco
DB_DIR="/Users/leechardes/Projetos/AutoCore/database"
DB_FILE="$DB_DIR/autocore.db"
BACKUP_DIR="$DB_DIR/backups"

# Criar diretório de backup se não existir
mkdir -p "$BACKUP_DIR"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     AutoCore - Reset do Banco de Dados    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# 1. Fazer backup do banco atual
if [ -f "$DB_FILE" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/autocore_backup_${TIMESTAMP}.db"
    
    echo -e "${YELLOW}1. Fazendo backup do banco atual...${NC}"
    cp "$DB_FILE" "$BACKUP_FILE"
    
    if [ -f "$BACKUP_FILE" ]; then
        SIZE=$(ls -lh "$BACKUP_FILE" | awk '{print $5}')
        echo -e "${GREEN}   ✅ Backup salvo: $BACKUP_FILE ($SIZE)${NC}"
    else
        echo -e "${RED}   ❌ Erro ao criar backup!${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}   ⚠️ Banco de dados não existe, criando novo...${NC}"
fi

echo ""

# 2. Remover banco atual
echo -e "${YELLOW}2. Removendo banco atual...${NC}"
rm -f "$DB_FILE"
echo -e "${GREEN}   ✅ Banco removido${NC}"

echo ""

# 3. Criar novo banco com schema
echo -e "${YELLOW}3. Criando novo banco de dados...${NC}"

# Ativar ambiente virtual Python
cd "$DB_DIR"
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
elif [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi

# Criar banco usando o script Python
python3 << 'EOF'
import sys
sys.path.append('/Users/leechardes/Projetos/AutoCore/database')

from shared.database import engine, Base
from shared.models import *

# Criar todas as tabelas
Base.metadata.create_all(bind=engine)
print("   ✅ Schema criado com sucesso")
EOF

echo ""

# 4. Inserir dados iniciais
echo -e "${YELLOW}4. Inserindo dados iniciais...${NC}"

python3 << 'EOF'
import sys
import os
from datetime import datetime
sys.path.append('/Users/leechardes/Projetos/AutoCore/database')

from shared.database import get_session
from shared.models import Device, RelayBoard, RelayChannel, Screen, ScreenItem, DeviceTheme

session = get_session()

try:
    # 1. Criar dispositivo ESP32 padrão para relés
    print("   📦 Criando dispositivo ESP32 para relés...")
    esp32_relay = Device(
        uuid="esp32-relay-001",
        name="Central de Relés Principal",
        type="esp32_relay",
        mac_address="AA:BB:CC:DD:EE:01",
        ip_address="192.168.1.200",
        firmware_version="v1.0.0",
        hardware_version="rev2",
        status="online",
        metadata={
            "relay_count": 16,
            "mqtt_topic": "autocore/relay/001",
            "location": "painel",
            "board_model": "16ch_standard",
            "voltage": "12V",
            "max_current": "10A"
        },
        capabilities={
            "relay_control": True,
            "status_report": True,
            "ota_update": True,
            "timer_control": True,
            "interlock": False
        }
    )
    session.add(esp32_relay)
    session.flush()  # Para obter o ID
    
    # 2. Criar placa de relé
    print("   🎛️ Criando placa de relé com 16 canais...")
    relay_board = RelayBoard(
        device_id=esp32_relay.id,
        total_channels=16,
        board_model="RELAY16CH-12V",
        is_active=True
    )
    session.add(relay_board)
    session.flush()
    
    # 3. Criar canais de relé com funções variadas
    print("   🔌 Criando 16 canais de relé...")
    channel_configs = [
        {"num": 1, "name": "Farol Alto", "func": "lighting", "icon": "lightbulb", "color": "yellow"},
        {"num": 2, "name": "Farol Baixo", "func": "lighting", "icon": "lightbulb-off", "color": "yellow"},
        {"num": 3, "name": "Milha", "func": "lighting", "icon": "cloud-fog", "color": "orange"},
        {"num": 4, "name": "Strobo", "func": "safety", "icon": "alert-triangle", "color": "red"},
        {"num": 5, "name": "Sirene", "func": "safety", "icon": "volume-2", "color": "red"},
        {"num": 6, "name": "Luz Interna", "func": "lighting", "icon": "lamp", "color": "white"},
        {"num": 7, "name": "Guincho", "func": "accessory", "icon": "anchor", "color": "blue"},
        {"num": 8, "name": "Compressor", "func": "accessory", "icon": "wind", "color": "cyan"},
        {"num": 9, "name": "Inversor 110V", "func": "power", "icon": "zap", "color": "green"},
        {"num": 10, "name": "Refrigerador", "func": "accessory", "icon": "thermometer", "color": "blue"},
        {"num": 11, "name": "Som", "func": "accessory", "icon": "music", "color": "purple"},
        {"num": 12, "name": "GPS/Rastreador", "func": "accessory", "icon": "navigation", "color": "green"},
        {"num": 13, "name": "Câmera", "func": "accessory", "icon": "camera", "color": "gray"},
        {"num": 14, "name": "Auxiliar 1", "func": "auxiliary", "icon": "power", "color": "gray"},
        {"num": 15, "name": "Auxiliar 2", "func": "auxiliary", "icon": "power", "color": "gray"},
        {"num": 16, "name": "Reserva", "func": "auxiliary", "icon": "circle", "color": "gray"}
    ]
    
    for cfg in channel_configs:
        channel = RelayChannel(
            board_id=relay_board.id,
            channel_number=cfg["num"],
            name=cfg["name"],
            description=f"Canal {cfg['num']} - {cfg['name']}",
            function_type=cfg["func"],
            current_state=False,
            icon=cfg["icon"],
            color=cfg["color"],
            protection_mode="none" if cfg["func"] != "safety" else "password"
        )
        session.add(channel)
    
    # 4. Criar dispositivo ESP32 para display
    print("   📟 Criando dispositivo ESP32 para display...")
    esp32_display = Device(
        uuid="esp32-display-001",
        name="Display Principal",
        type="esp32_display",
        mac_address="AA:BB:CC:DD:EE:02",
        ip_address="192.168.1.201",
        firmware_version="v1.0.0",
        hardware_version="rev2",
        status="online",
        metadata={
            "display_type": "oled_128x64",
            "mqtt_topic": "autocore/display/001",
            "location": "dashboard",
            "brightness": 100
        },
        capabilities={
            "display_control": True,
            "touch_input": False,
            "ota_update": True,
            "multi_screen": True
        }
    )
    session.add(esp32_display)
    session.flush()
    
    # 5. Criar tela de exemplo
    print("   🖼️ Criando tela de exemplo...")
    screen = Screen(
        device_id=esp32_display.id,
        name="Tela Principal",
        screen_type="status",
        layout_config={
            "rows": 4,
            "columns": 2,
            "background": "black",
            "font_size": 12
        },
        is_active=True,
        display_order=1
    )
    session.add(screen)
    session.flush()
    
    # 6. Adicionar itens na tela
    print("   📊 Adicionando itens na tela...")
    screen_items = [
        {"type": "text", "pos": 1, "content": {"text": "RPM", "label": "Motor"}},
        {"type": "gauge", "pos": 2, "content": {"value": 0, "max": 8000, "unit": "rpm"}},
        {"type": "text", "pos": 3, "content": {"text": "°C", "label": "Temp"}},
        {"type": "gauge", "pos": 4, "content": {"value": 0, "max": 120, "unit": "°C"}},
    ]
    
    for item in screen_items:
        screen_item = ScreenItem(
            screen_id=screen.id,
            item_type=item["type"],
            position=item["pos"],
            content=item["content"],
            style={"color": "white", "align": "center"}
        )
        session.add(screen_item)
    
    # 7. Criar tema padrão
    print("   🎨 Criando tema padrão...")
    theme = DeviceTheme(
        name="AutoCore Dark",
        description="Tema escuro padrão do AutoCore",
        theme_type="dark",
        colors={
            "primary": "#3B82F6",
            "secondary": "#10B981",
            "accent": "#F59E0B",
            "background": "#111827",
            "surface": "#1F2937",
            "text": "#F9FAFB",
            "error": "#EF4444",
            "warning": "#F59E0B",
            "success": "#10B981"
        },
        fonts={
            "primary": "Inter",
            "mono": "JetBrains Mono"
        },
        is_active=True
    )
    session.add(theme)
    
    # Commit de todas as mudanças
    session.commit()
    
    print("   ✅ Dados iniciais inseridos com sucesso!")
    
    # Mostrar resumo
    print("\n   📊 Resumo dos dados inseridos:")
    print(f"      • 2 Dispositivos ESP32")
    print(f"      • 1 Placa de relé com 16 canais")
    print(f"      • 1 Tela com 4 widgets")
    print(f"      • 1 Tema padrão")

except Exception as e:
    session.rollback()
    print(f"   ❌ Erro ao inserir dados: {e}")
    sys.exit(1)
finally:
    session.close()
EOF

echo ""

# 5. Verificar o banco criado
echo -e "${YELLOW}5. Verificando banco criado...${NC}"
if [ -f "$DB_FILE" ]; then
    SIZE=$(ls -lh "$DB_FILE" | awk '{print $5}')
    echo -e "${GREEN}   ✅ Banco criado: $DB_FILE ($SIZE)${NC}"
    
    # Contar registros
    echo -e "${BLUE}   📊 Contagem de registros:${NC}"
    for table in devices relay_boards relay_channels screens screen_items device_themes; do
        COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM $table;" 2>/dev/null || echo "0")
        echo -e "      • $table: $COUNT registros"
    done
else
    echo -e "${RED}   ❌ Erro: Banco não foi criado!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Reset do banco concluído com sucesso!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Backups disponíveis em: $BACKUP_DIR${NC}"
echo ""
echo -e "${BLUE}Para restaurar um backup:${NC}"
echo -e "  cp $BACKUP_DIR/autocore_backup_TIMESTAMP.db $DB_FILE"
echo ""