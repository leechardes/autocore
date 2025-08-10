#!/usr/bin/env python3
"""
Script para debugar erro de criação de simulador
Executa passo a passo para identificar onde está o problema
"""

import sys
import os
from pathlib import Path

print("=" * 60)
print("DEBUG: Erro de Criação de Simulador")
print("=" * 60)

# 1. Verificar Python
print("\n1. Versão do Python:")
print(f"   {sys.version}")

# 2. Verificar diretório atual
print("\n2. Diretório atual:")
print(f"   {os.getcwd()}")

# 3. Verificar se paho-mqtt está instalado
print("\n3. Verificando paho-mqtt:")
try:
    import paho.mqtt.client as mqtt
    print("   ✅ paho-mqtt instalado")
    client = mqtt.Client()
    print(f"   Versão: {client._client_version()}")
except ImportError as e:
    print(f"   ❌ paho-mqtt NÃO instalado: {e}")
    print("   Execute: pip3 install paho-mqtt")
    sys.exit(1)

# 4. Verificar se FastAPI está instalado
print("\n4. Verificando FastAPI:")
try:
    import fastapi
    print(f"   ✅ FastAPI instalado: {fastapi.__version__}")
except ImportError as e:
    print(f"   ❌ FastAPI NÃO instalado: {e}")
    print("   Execute: pip3 install fastapi")
    sys.exit(1)

# 5. Verificar path do database
print("\n5. Configurando path do database:")
try:
    db_path = str(Path(__file__).parent.parent.parent / "database")
    print(f"   Path calculado: {db_path}")
    print(f"   Path existe: {os.path.exists(db_path)}")
    
    if db_path not in sys.path:
        sys.path.append(db_path)
        print("   Path adicionado ao sys.path")
    
    # Tentar importar repositórios
    print("\n6. Tentando importar repositórios:")
    from shared.repositories import devices, relays
    print("   ✅ Repositórios importados com sucesso")
    
except ImportError as e:
    print(f"   ❌ Erro importando repositórios: {e}")
    print(f"   sys.path atual: {sys.path}")
    sys.exit(1)
except Exception as e:
    print(f"   ❌ Erro configurando path: {e}")
    sys.exit(1)

# 7. Verificar simulador
print("\n7. Importando simulador:")
try:
    from simulators.relay_simulator import RelayBoardSimulator, simulator_manager
    print("   ✅ Simulador importado com sucesso")
except ImportError as e:
    print(f"   ❌ Erro importando simulador: {e}")
    sys.exit(1)

# 8. Testar conexão MQTT
print("\n8. Testando conexão MQTT:")
import asyncio

async def test_mqtt():
    try:
        # Criar cliente MQTT simples
        client = mqtt.Client(client_id="test_debug")
        
        connected = False
        
        def on_connect(client, userdata, flags, rc):
            nonlocal connected
            if rc == 0:
                connected = True
                print("   ✅ Conectado ao MQTT")
            else:
                print(f"   ❌ Falha na conexão MQTT: código {rc}")
        
        client.on_connect = on_connect
        
        # Tentar conectar
        print("   Conectando ao broker MQTT...")
        client.connect("localhost", 1883, 60)
        client.loop_start()
        
        # Aguardar
        await asyncio.sleep(2)
        
        client.loop_stop()
        client.disconnect()
        
        if not connected:
            print("   ❌ Não conseguiu conectar ao MQTT")
            print("   Verifique se o Mosquitto está rodando:")
            print("     sudo systemctl status mosquitto")
            return False
            
    except Exception as e:
        print(f"   ❌ Erro: {e}")
        return False
    
    return True

# Executar teste MQTT
loop = asyncio.get_event_loop()
mqtt_ok = loop.run_until_complete(test_mqtt())

# 9. Testar criação de simulador simples
if mqtt_ok:
    print("\n9. Testando criação de simulador:")
    
    async def test_simulator():
        try:
            print("   Criando simulador de teste...")
            simulator = RelayBoardSimulator(
                board_id=999,
                device_uuid="debug-test",
                total_channels=4
            )
            print("   ✅ Simulador criado")
            
            print("   Conectando simulador ao MQTT...")
            connected = await simulator.connect("localhost", 1883)
            
            if connected:
                print("   ✅ Simulador conectado!")
                await simulator.disconnect()
                return True
            else:
                print("   ❌ Simulador não conectou")
                return False
                
        except Exception as e:
            print(f"   ❌ Erro: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    sim_ok = loop.run_until_complete(test_simulator())
else:
    print("\n9. Pulando teste do simulador (MQTT não está funcionando)")
    sim_ok = False

# 10. Testar acesso ao banco
print("\n10. Testando acesso ao banco de dados:")
try:
    with relays as repo:
        boards = repo.get_boards()
        print(f"   ✅ Banco acessível: {len(boards)} placas encontradas")
        
        if boards:
            board = boards[0]
            print(f"   Primeira placa: ID={board.id}, Canais={board.total_channels}")
            
            with devices as dev_repo:
                device = dev_repo.get_by_id(board.device_id)
                if device:
                    print(f"   Dispositivo: {device.name} (UUID: {device.uuid})")
                    
                    # Tentar criar simulador para esta placa
                    print("\n11. Criando simulador para placa real:")
                    
                    async def create_real_simulator():
                        try:
                            result = await simulator_manager.create_simulator(
                                board_id=board.id,
                                device_uuid=device.uuid,
                                total_channels=board.total_channels
                            )
                            
                            if result:
                                print(f"   ✅ Simulador criado para placa {board.id}")
                                await simulator_manager.remove_simulator(board.id)
                                return True
                            else:
                                print(f"   ❌ Falha ao criar simulador para placa {board.id}")
                                return False
                                
                        except Exception as e:
                            print(f"   ❌ Erro: {e}")
                            import traceback
                            traceback.print_exc()
                            return False
                    
                    if mqtt_ok:
                        real_ok = loop.run_until_complete(create_real_simulator())
                    else:
                        print("   Pulando (MQTT não está funcionando)")
                        
except Exception as e:
    print(f"   ❌ Erro: {e}")
    import traceback
    traceback.print_exc()

# Resumo
print("\n" + "=" * 60)
print("RESUMO DO DEBUG")
print("=" * 60)
print("\nProblemas encontrados:")

if not mqtt_ok:
    print("❌ MQTT não está funcionando - este é o problema principal!")
    print("   Soluções:")
    print("   1. Instalar Mosquitto: sudo apt-get install mosquitto")
    print("   2. Iniciar serviço: sudo systemctl start mosquitto")
    print("   3. Habilitar na inicialização: sudo systemctl enable mosquitto")
elif not sim_ok:
    print("❌ Simulador não consegue conectar ao MQTT")
    print("   Verifique as configurações de rede e firewall")
else:
    print("✅ Todos os testes passaram - o simulador deveria funcionar!")

print("\n" + "=" * 60)