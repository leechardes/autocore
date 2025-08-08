#!/usr/bin/env python3
"""
Script de teste para verificar funcionamento MQTT
"""
import paho.mqtt.client as mqtt
import json
import time

# Configuração
MQTT_BROKER = "localhost"
MQTT_PORT = 1883

# Cliente MQTT
client = mqtt.Client(client_id="test_monitor")

# Variáveis globais
messages_received = []

def on_connect(client, userdata, flags, rc):
    print(f"✅ Conectado ao broker MQTT (código: {rc})")
    # Subscrever em todos os tópicos AutoCore
    client.subscribe("autocore/#", qos=1)
    print("📡 Inscrito em autocore/#")

def on_message(client, userdata, message):
    topic = message.topic
    try:
        payload = json.loads(message.payload.decode())
    except:
        payload = message.payload.decode()
    
    msg = f"📨 {topic}: {payload}"
    print(msg)
    messages_received.append(msg)

# Configurar callbacks
client.on_connect = on_connect
client.on_message = on_message

# Conectar
print(f"🔗 Conectando ao broker MQTT em {MQTT_BROKER}:{MQTT_PORT}...")
client.connect(MQTT_BROKER, MQTT_PORT, 60)

# Loop em thread separada
client.loop_start()

print("\n📊 Monitor MQTT rodando. Pressione Ctrl+C para sair.\n")
print("Aguardando mensagens...")

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print(f"\n\n✅ Total de mensagens recebidas: {len(messages_received)}")
    client.loop_stop()
    client.disconnect()