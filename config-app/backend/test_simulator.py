#!/usr/bin/env python3
"""
Script de teste para debugar o simulador de relés
"""
import asyncio
import sys
import os
from pathlib import Path

# Adicionar paths necessários
sys.path.append(str(Path(__file__).parent.parent.parent / "database"))

# Configurar variáveis de ambiente
os.environ.setdefault("MQTT_BROKER", "localhost")
os.environ.setdefault("MQTT_PORT", "1883")
os.environ.setdefault("MQTT_USERNAME", "autocore")
os.environ.setdefault("MQTT_PASSWORD", "kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr")

import logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

async def test_simulator():
    """Testa criação do simulador"""
    print("\n🧪 TESTE DO SIMULADOR DE RELÉS")
    print("=" * 50)
    
    try:
        # 1. Verificar ambiente
        print("\n1️⃣ Verificando ambiente...")
        print(f"   MQTT_BROKER: {os.getenv('MQTT_BROKER')}")
        print(f"   MQTT_PORT: {os.getenv('MQTT_PORT')}")
        print(f"   MQTT_USERNAME: {os.getenv('MQTT_USERNAME')}")
        print(f"   MQTT_PASSWORD: {'*' * 10 if os.getenv('MQTT_PASSWORD') else 'NÃO DEFINIDO'}")
        
        # 2. Importar simulador
        print("\n2️⃣ Importando simulador...")
        from simulators.relay_simulator import RelayBoardSimulator, RelaySimulatorManager
        print("   ✅ Import OK")
        
        # 3. Verificar banco de dados
        print("\n3️⃣ Verificando banco de dados...")
        from shared.repositories import devices, relays
        
        with devices as repo:
            all_devices = repo.get_all()
            esp32_devices = [d for d in all_devices if d.type == "esp32_relay"]
            print(f"   Dispositivos ESP32 relay: {len(esp32_devices)}")
            for dev in esp32_devices:
                print(f"      • {dev.name} (UUID: {dev.uuid})")
        
        with relays as repo:
            boards = repo.get_boards()
            print(f"   Placas de relé: {len(boards)}")
            for board in boards:
                print(f"      • Board ID: {board.id}, Device ID: {board.device_id}, Canais: {board.total_channels}")
        
        if not boards:
            print("   ⚠️ Nenhuma placa cadastrada! Cadastre uma placa primeiro.")
            return False
        
        # 4. Testar conexão MQTT direta
        print("\n4️⃣ Testando conexão MQTT...")
        import paho.mqtt.client as mqtt
        
        connected = False
        def on_connect(client, userdata, flags, rc):
            nonlocal connected
            if rc == 0:
                print("   ✅ Conectado ao MQTT")
                connected = True
            else:
                print(f"   ❌ Falha na conexão: código {rc}")
                if rc == 5:
                    print("      Erro 5: Não autorizado - verifique usuário/senha")
        
        client = mqtt.Client(client_id="test_simulator")
        client.on_connect = on_connect
        
        # Configurar autenticação
        mqtt_user = os.getenv("MQTT_USERNAME")
        mqtt_pass = os.getenv("MQTT_PASSWORD")
        if mqtt_user and mqtt_pass:
            client.username_pw_set(mqtt_user, mqtt_pass)
            print(f"   🔐 Usando autenticação: {mqtt_user}")
        else:
            print("   ⚠️ Sem autenticação configurada")
        
        try:
            client.connect(os.getenv("MQTT_BROKER", "localhost"), 
                          int(os.getenv("MQTT_PORT", "1883")), 60)
            client.loop_start()
            await asyncio.sleep(2)
            client.loop_stop()
            client.disconnect()
        except Exception as e:
            print(f"   ❌ Erro conectando: {e}")
            connected = False
        
        if not connected:
            print("\n⚠️ MQTT não está acessível ou credenciais incorretas")
            return False
        
        # 5. Criar simulador
        print("\n5️⃣ Criando simulador...")
        
        # Pegar primeira placa
        board = boards[0]
        device = None
        with devices as repo:
            device = repo.get_by_id(board.device_id)
        
        if not device:
            print("   ❌ Dispositivo não encontrado para a placa")
            return False
        
        print(f"   Placa: ID {board.id}")
        print(f"   Device: {device.name} (UUID: {device.uuid})")
        
        # Criar manager
        manager = RelaySimulatorManager(
            mqtt_host=os.getenv("MQTT_BROKER", "localhost"),
            mqtt_port=int(os.getenv("MQTT_PORT", "1883")),
            mqtt_username=os.getenv("MQTT_USERNAME"),
            mqtt_password=os.getenv("MQTT_PASSWORD")
        )
        
        # Criar simulador
        print(f"\n   Criando simulador para board_id={board.id}...")
        simulator = await manager.create_simulator(
            board_id=board.id,
            device_uuid=device.uuid,
            total_channels=board.total_channels
        )
        
        if simulator:
            print("   ✅ Simulador criado com sucesso!")
            print(f"   Status: {simulator.get_status()}")
            
            # Testar comando
            print("\n6️⃣ Testando comando de relé...")
            await simulator.set_relay_state(1, True)
            await asyncio.sleep(1)
            print(f"   Estado canal 1: {simulator.channel_states[1]}")
            
            # Desconectar
            print("\n7️⃣ Desconectando...")
            await simulator.disconnect()
            print("   ✅ Desconectado")
            
            return True
        else:
            print("   ❌ Falha ao criar simulador")
            return False
            
    except Exception as e:
        print(f"\n❌ ERRO: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = asyncio.run(test_simulator())
    print("\n" + "=" * 50)
    if success:
        print("✅ TESTE CONCLUÍDO COM SUCESSO")
    else:
        print("❌ TESTE FALHOU")
        print("\n💡 Possíveis soluções:")
        print("   1. Verificar se o Mosquitto está rodando")
        print("   2. Confirmar credenciais MQTT no .env")
        print("   3. Cadastrar uma placa de relé no sistema")
        print("   4. Verificar logs do backend para mais detalhes")
    
    sys.exit(0 if success else 1)