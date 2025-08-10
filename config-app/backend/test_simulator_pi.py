#!/usr/bin/env python3
"""
Script de diagnóstico para testar criação de simulador no Raspberry Pi
"""

import sys
import os
import logging
from pathlib import Path

# Configurar logging completo para debug
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

def test_imports():
    """Testa se todas as importações funcionam"""
    print("\n=== TESTANDO IMPORTAÇÕES ===\n")
    
    # 1. Testar importação do paho-mqtt
    try:
        import paho.mqtt.client as mqtt
        print("✅ paho-mqtt importado com sucesso")
        print(f"   Versão: {mqtt.Client()._client_version()}")
    except ImportError as e:
        print(f"❌ Erro importando paho-mqtt: {e}")
        print("   Execute: pip install paho-mqtt")
        return False
    except Exception as e:
        print(f"❌ Erro inesperado com paho-mqtt: {e}")
        return False
    
    # 2. Testar importação do fastapi/websocket
    try:
        from fastapi import WebSocket
        print("✅ FastAPI WebSocket importado com sucesso")
    except ImportError as e:
        print(f"❌ Erro importando FastAPI: {e}")
        print("   Execute: pip install fastapi")
        return False
    
    # 3. Testar acesso ao database
    try:
        # Adicionar path para database
        db_path = str(Path(__file__).parent.parent.parent / "database")
        if db_path not in sys.path:
            sys.path.append(db_path)
        
        from shared.repositories import devices, relays
        print("✅ Repositórios do database importados com sucesso")
    except ImportError as e:
        print(f"❌ Erro importando repositórios: {e}")
        print(f"   Path do database: {db_path}")
        print(f"   sys.path: {sys.path}")
        return False
    except Exception as e:
        print(f"❌ Erro inesperado com repositórios: {e}")
        return False
    
    # 4. Testar importação do simulador
    try:
        from simulators.relay_simulator import RelayBoardSimulator, simulator_manager
        print("✅ Simulador de relé importado com sucesso")
    except ImportError as e:
        print(f"❌ Erro importando simulador: {e}")
        return False
    except Exception as e:
        print(f"❌ Erro inesperado com simulador: {e}")
        return False
    
    return True

def test_mqtt_connection():
    """Testa conexão MQTT"""
    print("\n=== TESTANDO CONEXÃO MQTT ===\n")
    
    try:
        import paho.mqtt.client as mqtt
        
        # Criar cliente de teste
        client = mqtt.Client(client_id="test_client_pi")
        
        # Variáveis de controle
        connected = False
        error_msg = None
        
        def on_connect(client, userdata, flags, rc):
            nonlocal connected, error_msg
            if rc == 0:
                connected = True
                print("✅ Conectado ao broker MQTT!")
            else:
                error_codes = {
                    1: "Protocolo incorreto",
                    2: "ID de cliente inválido",
                    3: "Servidor indisponível",
                    4: "Credenciais inválidas",
                    5: "Não autorizado"
                }
                error_msg = error_codes.get(rc, f"Erro desconhecido ({rc})")
                print(f"❌ Falha na conexão: {error_msg}")
        
        client.on_connect = on_connect
        
        # Tentar conectar
        print("Tentando conectar ao broker MQTT em localhost:1883...")
        try:
            client.connect("localhost", 1883, 60)
            client.loop_start()
            
            # Aguardar conexão
            import time
            for i in range(5):
                if connected:
                    break
                time.sleep(1)
                print(f"  Aguardando... {i+1}/5")
            
            client.loop_stop()
            client.disconnect()
            
            if not connected:
                print(f"❌ Timeout na conexão MQTT")
                if error_msg:
                    print(f"   Erro: {error_msg}")
                return False
                
        except Exception as e:
            print(f"❌ Erro ao conectar: {e}")
            print("\n   Possíveis soluções:")
            print("   1. Verifique se o Mosquitto está rodando: sudo systemctl status mosquitto")
            print("   2. Inicie o Mosquitto: sudo systemctl start mosquitto")
            print("   3. Verifique as configurações em /etc/mosquitto/mosquitto.conf")
            return False
            
    except Exception as e:
        print(f"❌ Erro inesperado: {e}")
        return False
    
    return True

def test_database_access():
    """Testa acesso ao banco de dados"""
    print("\n=== TESTANDO ACESSO AO BANCO DE DADOS ===\n")
    
    try:
        # Adicionar path para database
        db_path = str(Path(__file__).parent.parent.parent / "database")
        if db_path not in sys.path:
            sys.path.append(db_path)
        
        from shared.repositories import devices, relays
        
        # Testar leitura de placas
        with relays as repo:
            boards = repo.get_boards()
            print(f"✅ Banco de dados acessível!")
            print(f"   Placas encontradas: {len(boards)}")
            
            if boards:
                board = boards[0]
                print(f"   Primeira placa: ID={board.id}, Canais={board.total_channels}")
                
                # Testar leitura de dispositivo
                with devices as dev_repo:
                    device = dev_repo.get_by_id(board.device_id)
                    if device:
                        print(f"   Dispositivo: {device.name} (UUID: {device.uuid})")
                        return True
                    else:
                        print(f"❌ Dispositivo não encontrado para ID: {board.device_id}")
            else:
                print("⚠️ Nenhuma placa cadastrada no banco")
                
    except FileNotFoundError as e:
        print(f"❌ Banco de dados não encontrado: {e}")
        print(f"   Verifique se o arquivo existe em: {db_path}")
        return False
    except Exception as e:
        print(f"❌ Erro acessando banco: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    return True

def test_simulator_creation():
    """Testa criação do simulador"""
    print("\n=== TESTANDO CRIAÇÃO DO SIMULADOR ===\n")
    
    try:
        import asyncio
        from simulators.relay_simulator import RelayBoardSimulator
        
        # Criar simulador de teste
        simulator = RelayBoardSimulator(
            board_id=999,
            device_uuid="test-uuid-pi",
            total_channels=8
        )
        
        print("✅ Simulador criado com sucesso!")
        print(f"   Board ID: {simulator.board_id}")
        print(f"   Device UUID: {simulator.device_uuid}")
        print(f"   Total de canais: {simulator.total_channels}")
        
        # Testar conexão MQTT do simulador
        async def test_connect():
            result = await simulator.connect("localhost", 1883)
            if result:
                print("✅ Simulador conectado ao MQTT!")
                await simulator.disconnect()
                return True
            else:
                print("❌ Simulador não conseguiu conectar ao MQTT")
                return False
        
        # Executar teste assíncrono
        loop = asyncio.get_event_loop()
        return loop.run_until_complete(test_connect())
        
    except Exception as e:
        print(f"❌ Erro criando simulador: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Executa todos os testes"""
    print("=" * 60)
    print("DIAGNÓSTICO DE SIMULADOR NO RASPBERRY PI")
    print("=" * 60)
    
    # Informações do sistema
    print("\n=== INFORMAÇÕES DO SISTEMA ===\n")
    print(f"Python: {sys.version}")
    print(f"Platform: {sys.platform}")
    print(f"Working dir: {os.getcwd()}")
    print(f"Script path: {__file__}")
    
    # Executar testes
    tests = [
        ("Importações", test_imports),
        ("Conexão MQTT", test_mqtt_connection),
        ("Acesso ao Banco", test_database_access),
        ("Criação do Simulador", test_simulator_creation)
    ]
    
    results = []
    for name, test_func in tests:
        try:
            result = test_func()
            results.append((name, result))
        except Exception as e:
            print(f"\n❌ Erro executando teste '{name}': {e}")
            results.append((name, False))
    
    # Resumo
    print("\n" + "=" * 60)
    print("RESUMO DOS TESTES")
    print("=" * 60)
    
    for name, result in results:
        status = "✅ PASSOU" if result else "❌ FALHOU"
        print(f"{name:.<30} {status}")
    
    # Diagnóstico final
    all_passed = all(r for _, r in results)
    
    print("\n" + "=" * 60)
    if all_passed:
        print("✅ TODOS OS TESTES PASSARAM!")
        print("O simulador deveria funcionar corretamente.")
    else:
        print("❌ ALGUNS TESTES FALHARAM")
        print("\nPossíveis soluções:")
        print("1. Instale dependências faltantes com pip")
        print("2. Verifique se o Mosquitto está rodando")
        print("3. Verifique permissões de acesso ao banco de dados")
        print("4. Verifique os logs acima para detalhes específicos")
    print("=" * 60)

if __name__ == "__main__":
    main()