#!/usr/bin/env python3
"""
Script de teste de conexão MQTT do Gateway
"""
import os
import sys
from pathlib import Path
from dotenv import load_dotenv
import paho.mqtt.client as mqtt
import time

# Carregar .env
env_path = Path(__file__).parent / '.env'
load_dotenv(env_path)

def on_connect(client, userdata, flags, rc):
    """Callback de conexão"""
    if rc == 0:
        print("✅ Conectado ao MQTT com sucesso!")
        print(f"   Broker: {os.getenv('MQTT_BROKER')}:{os.getenv('MQTT_PORT')}")
        print(f"   Client ID: {os.getenv('MQTT_CLIENT_ID')}")
        client.disconnect()
    else:
        error_codes = {
            1: "Protocolo incorreto",
            2: "ID de cliente inválido",
            3: "Servidor indisponível",
            4: "Credenciais inválidas",
            5: "Não autorizado",
            7: "Conexão recusada - não autorizado"
        }
        error_msg = error_codes.get(rc, f"Erro desconhecido ({rc})")
        print(f"❌ Falha na conexão: {error_msg}")
        
def on_disconnect(client, userdata, rc):
    """Callback de desconexão"""
    if rc == 0:
        print("📴 Desconectado normalmente")
    else:
        print(f"⚠️ Desconexão inesperada: {rc}")

def test_mqtt_connection():
    """Testa conexão MQTT com as configurações do .env"""
    print("🔧 Testando conexão MQTT do Gateway...")
    print("=" * 50)
    
    # Ler configurações
    broker = os.getenv('MQTT_BROKER', 'localhost')
    port = int(os.getenv('MQTT_PORT', '1883'))
    username = os.getenv('MQTT_USERNAME')
    password = os.getenv('MQTT_PASSWORD')
    client_id = os.getenv('MQTT_CLIENT_ID', 'gateway-test')
    
    print(f"📋 Configurações:")
    print(f"   Broker: {broker}:{port}")
    print(f"   Client ID: {client_id}")
    print(f"   Autenticação: {'Sim' if username else 'Não'}")
    if username:
        print(f"   Usuário: {username}")
    print()
    
    # Criar cliente MQTT
    client = mqtt.Client(client_id=client_id)
    
    # Configurar callbacks
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    
    # Configurar autenticação se necessário
    if username and password:
        client.username_pw_set(username, password)
        print("🔐 Usando autenticação")
    else:
        print("🔓 Sem autenticação")
    
    print("🔄 Conectando...")
    print()
    
    try:
        # Tentar conectar
        client.connect(broker, port, keepalive=60)
        
        # Loop para processar callbacks
        client.loop_start()
        time.sleep(2)  # Aguardar conexão
        client.loop_stop()
        
    except Exception as e:
        print(f"❌ Erro ao conectar: {e}")
        return False
    
    return True

def check_database():
    """Verifica se o database está acessível"""
    print("\n🗄️ Verificando Database...")
    print("=" * 50)
    
    db_path = os.getenv('DATABASE_PATH', '../database/autocore.db')
    db_file = Path(db_path)
    
    if db_file.exists():
        print(f"✅ Database encontrado: {db_file.absolute()}")
        print(f"   Tamanho: {db_file.stat().st_size / 1024:.2f} KB")
    else:
        print(f"❌ Database não encontrado: {db_path}")
        print(f"   Path absoluto: {db_file.absolute()}")
    
def check_environment():
    """Verifica todas as variáveis de ambiente"""
    print("\n🔍 Variáveis de Ambiente:")
    print("=" * 50)
    
    important_vars = [
        'MQTT_BROKER',
        'MQTT_PORT',
        'MQTT_USERNAME',
        'MQTT_PASSWORD',
        'MQTT_CLIENT_ID',
        'DATABASE_PATH',
        'LOG_LEVEL',
        'SECRET_KEY',
        'ENV'
    ]
    
    for var in important_vars:
        value = os.getenv(var)
        if value:
            if var == 'SECRET_KEY':
                print(f"✅ {var}: ***{value[-8:]}")  # Mostrar apenas últimos 8 chars
            elif var == 'MQTT_PASSWORD':
                print(f"✅ {var}: {'*' * len(value)}")
            else:
                print(f"✅ {var}: {value}")
        else:
            print(f"⚠️ {var}: Não definido")

if __name__ == "__main__":
    print("🚀 AutoCore Gateway - Teste de Configuração")
    print("=" * 50)
    
    # Verificar ambiente
    check_environment()
    
    # Verificar database
    check_database()
    
    # Testar MQTT
    print()
    success = test_mqtt_connection()
    
    print("\n" + "=" * 50)
    if success:
        print("✅ Gateway pronto para execução!")
    else:
        print("❌ Corrija os problemas acima antes de executar o Gateway")