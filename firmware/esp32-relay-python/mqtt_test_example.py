#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Exemplo de teste MQTT para ESP32 Relay
Script para executar no computador/servidor para testar a comunicação MQTT
"""

import json
import time
import paho.mqtt.client as mqtt

# Configuração do MQTT (ajustar conforme necessário)
MQTT_BROKER = "192.168.1.100"
MQTT_PORT = 1883
DEVICE_ID = "esp32_relay_93ce30"  # Alterar conforme o ID real do dispositivo

# Tópicos MQTT
TOPIC_COMMAND = f"autocore/devices/{DEVICE_ID}/command"
TOPIC_STATUS = f"autocore/devices/{DEVICE_ID}/status"
TOPIC_TELEMETRY = f"autocore/devices/{DEVICE_ID}/telemetry"

def on_connect(client, userdata, flags, rc):
    """Callback de conexão"""
    if rc == 0:
        print("✅ Conectado ao broker MQTT")
        client.subscribe(TOPIC_STATUS)
        client.subscribe(TOPIC_TELEMETRY)
        print(f"📥 Subscrito aos tópicos de status e telemetria")
    else:
        print(f"❌ Falha na conexão: {rc}")

def on_message(client, userdata, msg):
    """Callback para mensagens recebidas"""
    try:
        topic = msg.topic
        payload = json.loads(msg.payload.decode())
        
        print(f"\n📨 Mensagem recebida:")
        print(f"   Tópico: {topic}")
        print(f"   Payload: {json.dumps(payload, indent=2)}")
        
        if topic == TOPIC_STATUS:
            print("📊 Status do dispositivo recebido!")
            print(f"   Status: {payload.get('status')}")
            print(f"   Uptime: {payload.get('uptime')}s")
            print(f"   Memória livre: {payload.get('free_memory')} bytes")
            print(f"   Estados dos relés: {payload.get('relay_states')}")
        
    except Exception as e:
        print(f"❌ Erro processando mensagem: {e}")

def send_command(client, command, **kwargs):
    """Envia comando para o ESP32"""
    payload = {"command": command, **kwargs}
    json_payload = json.dumps(payload)
    
    print(f"\n📤 Enviando comando:")
    print(f"   Tópico: {TOPIC_COMMAND}")
    print(f"   Payload: {json_payload}")
    
    result = client.publish(TOPIC_COMMAND, json_payload)
    
    if result.rc == mqtt.MQTT_ERR_SUCCESS:
        print("✅ Comando enviado com sucesso!")
    else:
        print(f"❌ Falha no envio: {result.rc}")

def main():
    """Função principal para testes"""
    print("🧪 ESP32 MQTT Test Client")
    print("=" * 50)
    
    # Criar cliente MQTT
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message
    
    try:
        # Conectar ao broker
        print(f"🔗 Conectando ao broker {MQTT_BROKER}:{MQTT_PORT}...")
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        
        # Iniciar loop em thread separada
        client.loop_start()
        
        # Aguardar conexão
        time.sleep(2)
        
        print("\n🎮 Comandos disponíveis:")
        print("1. get_status - Solicitar status do dispositivo")
        print("2. relay_on <canal> - Ligar relé")
        print("3. relay_off <canal> - Desligar relé") 
        print("4. reboot - Reiniciar ESP32")
        print("5. exit - Sair")
        
        while True:
            try:
                cmd = input("\n>>> Comando: ").strip().lower()
                
                if cmd == "exit":
                    break
                elif cmd == "get_status":
                    send_command(client, "get_status")
                elif cmd.startswith("relay_on"):
                    parts = cmd.split()
                    if len(parts) > 1:
                        try:
                            channel = int(parts[1])
                            send_command(client, "relay_on", channel=channel)
                        except ValueError:
                            print("❌ Canal deve ser um número")
                    else:
                        print("❌ Uso: relay_on <canal>")
                elif cmd.startswith("relay_off"):
                    parts = cmd.split()
                    if len(parts) > 1:
                        try:
                            channel = int(parts[1])
                            send_command(client, "relay_off", channel=channel)
                        except ValueError:
                            print("❌ Canal deve ser um número")
                    else:
                        print("❌ Uso: relay_off <canal>")
                elif cmd == "reboot":
                    confirm = input("⚠️ Confirma reinicialização do ESP32? (y/N): ")
                    if confirm.lower() == 'y':
                        send_command(client, "reboot")
                    else:
                        print("❌ Cancelado")
                elif cmd == "help":
                    print("\n🎮 Comandos disponíveis:")
                    print("get_status - Solicitar status do dispositivo")
                    print("relay_on <canal> - Ligar relé (0-15)")
                    print("relay_off <canal> - Desligar relé (0-15)")
                    print("reboot - Reiniciar ESP32")
                    print("exit - Sair")
                else:
                    print("❓ Comando inválido. Digite 'help' para ajuda.")
                
            except KeyboardInterrupt:
                break
            except Exception as e:
                print(f"❌ Erro: {e}")
        
    except Exception as e:
        print(f"❌ Erro na conexão: {e}")
    
    finally:
        print("\n🔌 Desconectando...")
        client.loop_stop()
        client.disconnect()
        print("👋 Até logo!")

if __name__ == "__main__":
    main()