#!/usr/bin/env python3
"""
Simulador Simples de Relés para AutoCore
Escuta comandos MQTT e responde com status
"""
import paho.mqtt.client as mqtt
import json
from datetime import datetime
import sys

# Configuração
MQTT_BROKER = "localhost"
MQTT_PORT = 1883

# Estado dos relés (16 canais)
relay_states = {i: False for i in range(1, 17)}
relay_states["all"] = False  # Estado global

def on_connect(client, userdata, flags, rc):
    """Callback de conexão"""
    print(f"✅ Simulador de Relés conectado ao MQTT (código: {rc})")
    
    # Subscrever em todos os comandos de relé
    client.subscribe("autocore/relay/+/command", qos=1)
    print("📡 Inscrito em autocore/relay/+/command")
    
    # Publicar status inicial
    publish_all_states(client)

def on_message(client, userdata, message):
    """Callback para processar comandos"""
    try:
        topic = message.topic
        payload = json.loads(message.payload.decode())
        
        # Extrair ID do relé do tópico
        # autocore/relay/{id}/command
        parts = topic.split("/")
        if len(parts) >= 3 and parts[1] == "relay":
            relay_id = parts[2]
            command = payload.get("command", "toggle")
            source = payload.get("source", "unknown")
            label = payload.get("label", "")
            
            print(f"\n📨 Comando recebido:")
            print(f"   Relé: {relay_id}")
            print(f"   Comando: {command}")
            print(f"   Origem: {source}")
            if label:
                print(f"   Label: {label}")
            
            # Processar comando
            if relay_id == "all":
                # Comando para todos os relés
                new_state = command == "on"
                for i in range(1, 17):
                    relay_states[i] = new_state
                relay_states["all"] = new_state
                print(f"   ➡️ Todos os relés: {'LIGADOS' if new_state else 'DESLIGADOS'}")
                
                # Publicar status de todos
                publish_all_states(client)
                
            elif relay_id.isdigit():
                # Comando para relé específico
                relay_num = int(relay_id)
                if 1 <= relay_num <= 16:
                    if command == "on":
                        relay_states[relay_num] = True
                    elif command == "off":
                        relay_states[relay_num] = False
                    elif command == "toggle":
                        relay_states[relay_num] = not relay_states[relay_num]
                    
                    print(f"   ➡️ Relé {relay_num}: {'LIGADO' if relay_states[relay_num] else 'DESLIGADO'}")
                    
                    # Publicar status do relé
                    publish_relay_status(client, relay_num)
                else:
                    print(f"   ⚠️ Relé {relay_num} inválido (1-16)")
            
            # Mostrar estado atual de todos os relés
            print("\n📊 Estado Atual dos Relés:")
            print_relay_grid()
            
    except Exception as e:
        print(f"❌ Erro processando comando: {e}")

def publish_relay_status(client, relay_id):
    """Publica status de um relé específico"""
    topic = f"autocore/relay/{relay_id}/status"
    payload = {
        "channel": relay_id,
        "state": relay_states[relay_id],
        "timestamp": datetime.now().isoformat(),
        "source": "simulator"
    }
    
    client.publish(topic, json.dumps(payload), qos=1, retain=True)
    print(f"📤 Status publicado: {topic}")

def publish_all_states(client):
    """Publica status de todos os relés"""
    # Status geral
    topic = "autocore/relay/status"
    payload = {
        "timestamp": datetime.now().isoformat(),
        "source": "simulator",
        "states": {str(k): v for k, v in relay_states.items() if k != "all"},
        "active_count": sum(1 for v in relay_states.values() if v and v != "all"),
        "total_channels": 16
    }
    
    client.publish(topic, json.dumps(payload), qos=1, retain=True)
    print(f"📤 Status geral publicado: {topic}")
    
    # Status individual de cada relé
    for i in range(1, 17):
        publish_relay_status(client, i)

def print_relay_grid():
    """Imprime grid visual do estado dos relés"""
    print("┌────────────────────────────────┐")
    for row in range(4):
        line = "│"
        for col in range(4):
            relay_num = row * 4 + col + 1
            if relay_states[relay_num]:
                line += f" [R{relay_num:2}:ON ] "
            else:
                line += f"  R{relay_num:2}:OFF  "
        line += "│"
        print(line)
    print("└────────────────────────────────┘")

def on_disconnect(client, userdata, rc):
    """Callback de desconexão"""
    print(f"\n⚠️ Desconectado do MQTT (código: {rc})")

# Criar cliente MQTT
client = mqtt.Client(client_id="relay_simulator_simple")
client.on_connect = on_connect
client.on_message = on_message
client.on_disconnect = on_disconnect

# Conectar
print("🚀 Iniciando Simulador de Relés AutoCore")
print(f"🔗 Conectando ao broker MQTT em {MQTT_BROKER}:{MQTT_PORT}...")

try:
    client.connect(MQTT_BROKER, MQTT_PORT, 60)
    
    print("\n📊 Simulador rodando. Pressione Ctrl+C para sair.\n")
    print("Aguardando comandos...")
    print("\nComandos aceitos:")
    print("  - autocore/relay/{1-16}/command - Controla relé específico")
    print("  - autocore/relay/all/command - Controla todos os relés")
    print("\nPayload esperado:")
    print('  {"command": "on|off|toggle", "source": "...", "label": "..."}\n')
    
    # Loop principal
    client.loop_forever()
    
except KeyboardInterrupt:
    print("\n\n🛑 Encerrando simulador...")
    
    # Publicar status offline antes de sair
    offline_status = {
        "timestamp": datetime.now().isoformat(),
        "status": "offline",
        "source": "simulator"
    }
    client.publish("autocore/relay/status", json.dumps(offline_status), retain=True)
    
    client.disconnect()
    print("✅ Simulador encerrado")
    
except Exception as e:
    print(f"❌ Erro fatal: {e}")
    sys.exit(1)