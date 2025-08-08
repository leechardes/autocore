#!/usr/bin/env python3
"""
Executor do Simulador de Relés ESP32
Simula uma placa ESP32 com 16 relés
"""
import asyncio
import logging
import sys
from pathlib import Path

# Adicionar path do simulador
sys.path.append(str(Path(__file__).parent))

from simulators.relay_simulator import RelayBoardSimulator

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

async def main():
    """Executa o simulador"""
    # Configurações do simulador
    BOARD_ID = 1
    DEVICE_UUID = "esp32-relay-001"  # Mesmo UUID do database
    TOTAL_CHANNELS = 16
    
    logger.info("🚀 Iniciando Simulador de Relés ESP32")
    logger.info(f"📋 UUID: {DEVICE_UUID}")
    logger.info(f"📟 Board ID: {BOARD_ID}")
    logger.info(f"🔌 Canais: {TOTAL_CHANNELS}")
    
    # Criar e conectar simulador
    simulator = RelayBoardSimulator(
        board_id=BOARD_ID,
        device_uuid=DEVICE_UUID,
        total_channels=TOTAL_CHANNELS
    )
    
    # Conectar ao MQTT
    connected = await simulator.connect()
    
    if not connected:
        logger.error("❌ Falha ao conectar ao MQTT")
        return
    
    logger.info("✅ Simulador conectado e pronto!")
    logger.info(f"📡 Escutando em: autocore/devices/{DEVICE_UUID}/relay/command")
    logger.info("Pressione Ctrl+C para parar...")
    
    try:
        # Executar loop principal
        await simulator.run()
    except KeyboardInterrupt:
        logger.info("\n🛑 Encerrando simulador...")
    finally:
        await simulator.disconnect()
        logger.info("✅ Simulador encerrado")

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass