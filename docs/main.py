#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ESP32 WiFi Config v2.0 - Versão com Interface Melhorada
"""

import network
import socket
import time
import json
import os
import machine
import gc
import ubinascii
import _thread

# Imports MQTT
try:
    from umqtt.simple import MQTTClient
    print("📡 Using umqtt.simple")
except ImportError:
    try:
        from umqtt.robust import MQTTClient
        print("📡 Using umqtt.robust")
    except ImportError:
        print("⚠️ MQTT não disponível")
        MQTTClient = None

# Import para requests HTTP
try:
    import urequests
    print("🌐 urequests disponível")
except ImportError:
    print("⚠️ urequests não disponível - usando socket básico")
    urequests = None

# ============================================================================
# CONFIGURAÇÃO PADRÃO
# ============================================================================

def get_unique_id():
    """Gera ID único baseado no MAC"""
    try:
        mac = ubinascii.hexlify(network.WLAN().config('mac')).decode()
        return mac[-6:].lower()
    except:
        return "000001"

UNIQUE_ID = get_unique_id()

DEFAULT_CONFIG = {
    'device_id': f'esp32_relay_{UNIQUE_ID}',
    'device_name': f'ESP32 Relay {UNIQUE_ID}',
    'wifi_ssid': '',
    'wifi_password': '',
    'backend_ip': '192.168.1.100',
    'backend_port': 8081,
    'mqtt_broker': '192.168.1.100',
    'mqtt_port': 1883,
    'mqtt_user': '',
    'mqtt_password': '',
    'mqtt_registered': False,
    'relay_channels': 16,
    'relay_states': [0] * 16,  # Estado inicial dos relés
    'configured': False
}

def load_config():
    """Carrega configuração do arquivo"""
    try:
        if 'config.json' in os.listdir():
            with open('config.json', 'r') as f:
                config = json.load(f)
                for key in DEFAULT_CONFIG:
                    if key not in config:
                        config[key] = DEFAULT_CONFIG[key]
                return config
    except:
        pass
    return DEFAULT_CONFIG.copy()

def save_config(config):
    """Salva configuração em arquivo"""
    try:
        with open('config.json', 'w') as f:
            json.dump(config, f)
        return True
    except Exception as e:
        print(f"❌ Erro salvando config: {e}")
        return False

def delete_config():
    """Remove arquivo de configuração"""
    try:
        os.remove('config.json')
        return True
    except:
        return False

# ============================================================================
# SISTEMA MQTT E BACKEND
# ============================================================================

def http_request(method, url, data=None, timeout=10):
    """Faz requisição HTTP usando urequests ou socket"""
    try:
        if urequests:
            if method.upper() == 'POST':
                headers = {'Content-Type': 'application/json'}
                response = urequests.post(url, json=data, headers=headers, timeout=timeout)
                result = response.json() if response.text else {}
                response.close()
                return True, result
            else:
                response = urequests.get(url, timeout=timeout)
                result = response.json() if response.text else {}
                response.close()
                return True, result
        else:
            print("⚠️ Usando socket básico para HTTP")
            return False, {}
            
    except Exception as e:
        print(f"❌ Erro HTTP: {e}")
        return False, {}

def register_with_backend(config):
    """Registra dispositivo no backend e obtém configuração MQTT"""
    if not config.get('backend_ip') or config.get('mqtt_registered'):
        print("ℹ️ Registro não necessário")
        return True
    
    print("📞 Registrando com backend...")
    
    try:
        # Obter IP atual
        sta = network.WLAN(network.STA_IF)
        if not sta.isconnected():
            print("❌ WiFi não conectado para registro")
            return False
        
        device_ip = sta.ifconfig()[0]
        
        # Payload de registro
        payload = {
            "uuid": config['device_id'],
            "name": config['device_name'], 
            "type": "relay",
            "firmware_version": "2.0.0",
            "relay_channels": config.get('relay_channels', 16),
            "ip_address": device_ip
        }
        
        url = f"http://{config['backend_ip']}:{config['backend_port']}/api/devices/register"
        print(f"📡 POST {url}")
        
        success, response = http_request('POST', url, payload)
        
        if success and response:
            print("✅ Registro bem-sucedido!")
            
            # Atualizar configuração MQTT
            if 'mqtt_broker' in response:
                config['mqtt_broker'] = response['mqtt_broker']
            if 'mqtt_port' in response:
                config['mqtt_port'] = response['mqtt_port']
            if 'mqtt_user' in response:
                config['mqtt_user'] = response['mqtt_user']
            if 'mqtt_password' in response:
                config['mqtt_password'] = response['mqtt_password']
            
            config['mqtt_registered'] = True
            save_config(config)
            
            print(f"🔧 MQTT: {config['mqtt_broker']}:{config['mqtt_port']}")
            print(f"👤 User: {config.get('mqtt_user', 'N/A')}")
            
            return True
        else:
            print(f"❌ Falha no registro: {response}")
            return False
            
    except Exception as e:
        print(f"❌ Erro no registro: {e}")
        return False

def control_relay_gpio(channel, state):
    """Controla GPIO do relé (implementação básica)"""
    try:
        # Mapeamento de canais para pinos GPIO (ajustar conforme hardware)
        gpio_pins = [2, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 25, 26]
        
        if 0 <= channel < len(gpio_pins) and channel < 16:
            pin_num = gpio_pins[channel]
            
            # Configurar pino como saída se não configurado
            pin = machine.Pin(pin_num, machine.Pin.OUT)
            
            # Definir estado (1=ON, 0=OFF)
            pin.value(1 if state else 0)
            
            print(f"🔌 GPIO {pin_num} (Canal {channel}): {'ON' if state else 'OFF'}")
            return True
        else:
            print(f"⚠️ Canal {channel} inválido")
            return False
            
    except Exception as e:
        print(f"❌ Erro no GPIO: {e}")
        return False

def mqtt_callback(topic, msg):
    """Callback para mensagens MQTT"""
    global mqtt_client, global_config
    
    try:
        topic_str = topic.decode('utf-8')
        msg_str = msg.decode('utf-8')
        
        print(f"📨 MQTT: {topic_str} -> {msg_str}")
        
        # Parse do comando
        try:
            command_data = json.loads(msg_str)
        except:
            print("❌ JSON inválido")
            return
        
        command = command_data.get('command')
        
        if command == 'relay_on':
            channel = command_data.get('channel', 0)
            # Garantir que relay_states existe
            if 'relay_states' not in global_config:
                global_config['relay_states'] = [0] * global_config.get('relay_channels', 16)
            
            if 0 <= channel < len(global_config['relay_states']):
                global_config['relay_states'][channel] = 1
                control_relay_gpio(channel, True)
                print(f"✅ Relé {channel} LIGADO")
                # Salvar estado
                save_config(global_config)
                
        elif command == 'relay_off':
            channel = command_data.get('channel', 0)
            # Garantir que relay_states existe
            if 'relay_states' not in global_config:
                global_config['relay_states'] = [0] * global_config.get('relay_channels', 16)
            
            if 0 <= channel < len(global_config['relay_states']):
                global_config['relay_states'][channel] = 0
                control_relay_gpio(channel, False)
                print(f"✅ Relé {channel} DESLIGADO")
                # Salvar estado
                save_config(global_config)
                
        elif command == 'get_status':
            print("📊 Solicitação de status")
            publish_status(mqtt_client, global_config)
            
        elif command == 'reboot':
            print("🔄 Comando de reinicialização")
            time.sleep(1)
            machine.reset()
            
        else:
            print(f"❓ Comando desconhecido: {command}")
            
    except Exception as e:
        print(f"❌ Erro no callback MQTT: {e}")

def publish_status(client, config):
    """Publica status do dispositivo"""
    try:
        sta = network.WLAN(network.STA_IF)
        
        # Garantir que relay_states existe
        if 'relay_states' not in config:
            config['relay_states'] = [0] * config.get('relay_channels', 16)
        
        # Coletar métricas
        status_data = {
            "uuid": config['device_id'],
            "status": "online",
            "uptime": int(time.ticks_ms() / 1000),  # segundos desde boot
            "wifi_rssi": sta.status('rssi') if hasattr(sta, 'status') else -50,
            "free_memory": gc.mem_free(),
            "relay_states": config['relay_states']
        }
        
        topic = f"autocore/devices/{config['device_id']}/status"
        payload = json.dumps(status_data)
        
        client.publish(topic, payload)
        print(f"📊 Status publicado: {len(payload)} bytes")
        
    except Exception as e:
        print(f"❌ Erro publicando status: {e}")

def setup_mqtt(config):
    """Configura e conecta cliente MQTT"""
    global mqtt_client
    
    if not MQTTClient:
        print("❌ MQTT não disponível")
        return None
    
    if not config.get('mqtt_broker'):
        print("❌ Broker MQTT não configurado")
        return None
    
    try:
        print(f"🔗 Conectando MQTT: {config['mqtt_broker']}:{config['mqtt_port']}")
        
        # Configurar cliente
        client_id = config['device_id']
        broker = config['mqtt_broker']
        port = config.get('mqtt_port', 1883)
        user = config.get('mqtt_user', '')
        password = config.get('mqtt_password', '')
        
        if user and password:
            client = MQTTClient(client_id, broker, port=port, user=user, password=password)
        else:
            client = MQTTClient(client_id, broker, port=port)
        
        client.set_callback(mqtt_callback)
        client.connect()
        
        # Subscrever aos tópicos
        command_topic = f"autocore/devices/{config['device_id']}/command"
        client.subscribe(command_topic)
        
        print(f"✅ MQTT conectado!")
        print(f"📥 Subscrito: {command_topic}")
        
        # Publicar status inicial
        publish_status(client, config)
        
        return client
        
    except Exception as e:
        print(f"❌ Erro MQTT: {e}")
        return None

def mqtt_loop(client, config):
    """Loop principal MQTT em thread separada"""
    print("🔄 Iniciando loop MQTT")
    
    last_status = time.ticks_ms()
    status_interval = 30000  # 30 segundos
    
    reconnect_attempts = 0
    max_reconnect = 5
    
    while True:
        try:
            if client is None:
                time.sleep(5)
                continue
            
            # Verificar mensagens
            client.check_msg()
            
            # Publicar status a cada 30s
            now = time.ticks_ms()
            if time.ticks_diff(now, last_status) > status_interval:
                publish_status(client, config)
                last_status = now
                reconnect_attempts = 0  # Reset contador se tudo OK
            
            time.sleep(1)
            
        except Exception as e:
            print(f"❌ Erro no loop MQTT: {e}")
            reconnect_attempts += 1
            
            if reconnect_attempts > max_reconnect:
                print(f"💀 MQTT: Muitas tentativas ({max_reconnect}), parando")
                break
            
            print(f"🔄 Tentando reconectar MQTT ({reconnect_attempts}/{max_reconnect})...")
            
            try:
                client = setup_mqtt(config)
                if client:
                    reconnect_attempts = 0
                else:
                    time.sleep(10)  # Aguardar antes de tentar novamente
            except:
                time.sleep(10)
    
    print("🛑 Loop MQTT finalizado")

# Variáveis globais para cliente MQTT e configuração
mqtt_client = None
global_config = None

# ============================================================================
# GERENCIAMENTO WIFI
# ============================================================================

def setup_ap(config):
    """Configura Access Point"""
    ap = network.WLAN(network.AP_IF)
    ap.active(True)
    
    device_suffix = config['device_id'].split('_')[-1] if '_' in config['device_id'] else config['device_id'][-6:]
    ssid = f"ESP32-Relay-{device_suffix}"
    password = "12345678"
    
    ap.config(essid=ssid, password=password)
    
    print(f"📡 AP criado: {ssid}")
    print(f"🔑 Senha: {password}")
    print(f"📱 IP: {ap.ifconfig()[0]}")
    
    return ap

def connect_wifi(ssid, password, timeout=15):
    """Conecta ao WiFi"""
    print(f"📡 Conectando a {ssid}...")
    
    sta = network.WLAN(network.STA_IF)
    sta.active(True)
    
    if sta.isconnected():
        sta.disconnect()
        time.sleep(1)
    
    sta.connect(ssid, password)
    
    for i in range(timeout):
        if sta.isconnected():
            print(f"✅ Conectado! IP: {sta.ifconfig()[0]}")
            return True
        time.sleep(1)
        print(f"   Tentando... {i+1}/{timeout}")
    
    print("❌ Falha na conexão")
    return False

# ============================================================================
# INTERFACE WEB MELHORADA (usando web_page.py)
# ============================================================================

def generate_html_inline(config, message=""):
    """Gera HTML inline sem usar web_page.py"""
    
    # Status do WiFi
    sta = network.WLAN(network.STA_IF)
    wifi_status = "✅ Conectado" if sta.isconnected() else "❌ Desconectado"
    if sta.isconnected():
        wifi_status += f" ({sta.ifconfig()[0]})"
    
    # Mensagem de feedback
    msg_html = ""
    if message:
        msg_type, msg_text = message if isinstance(message, tuple) else ("info", message)
        color = {"success": "#4CAF50", "error": "#f44336", "info": "#2196F3"}.get(msg_type, "#2196F3")
        msg_html = f'<div style="padding: 10px; background: {color}; color: white; border-radius: 5px; margin: 10px 0;">{msg_text}</div>'
    
    # HTML simplificado mas com visual melhorado
    html = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ESP32 Config v2</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container { 
            background: white; 
            padding: 30px; 
            border-radius: 15px; 
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            width: 100%%;
            max-width: 500px;
        }
        h1 { 
            color: #333; 
            text-align: center;
            margin-bottom: 20px;
            font-size: 24px;
        }
        h3 {
            color: #555;
            margin-top: 20px;
            margin-bottom: 10px;
            padding-bottom: 5px;
            border-bottom: 2px solid #eee;
        }
        .status { 
            padding: 15px; 
            margin: 15px 0; 
            border-radius: 8px; 
            background: #f5f5f5;
            border-left: 4px solid #4CAF50;
        }
        .status strong { color: #333; }
        input, select { 
            width: 100%%; 
            padding: 12px; 
            margin: 8px 0; 
            border: 2px solid #ddd; 
            border-radius: 8px; 
            font-size: 14px;
        }
        input:focus, select:focus {
            outline: none;
            border-color: #667eea;
        }
        button { 
            width: 100%%; 
            padding: 14px; 
            margin: 10px 0; 
            border: none; 
            border-radius: 8px; 
            cursor: pointer; 
            font-size: 16px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .btn-primary { 
            background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);
            color: white;
        }
        .btn-warning { 
            background: #ff9800;
            color: white;
        }
        .btn-danger { 
            background: #f44336;
            color: white;
        }
        .info-text {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
        }
        .field-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            color: #555;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚙️ ESP32 Relay Config v2</h1>
        
        <div class="status">
            <strong>ID do Dispositivo:</strong> %s<br>
            <strong>Nome:</strong> %s<br>
            <strong>Status WiFi:</strong> %s<br>
            <strong>Backend:</strong> %s:%d<br>
            <strong>Canais de Relé:</strong> %d
        </div>
        
        %s
        
        <form action="/config" method="post" accept-charset="UTF-8">
            <h3>📱 Configuração do Dispositivo</h3>
            
            <div class="field-group">
                <label for="device_name">Nome do Dispositivo (somente leitura)</label>
                <input type="text" id="device_name" name="device_name" 
                       value="%s" 
                       readonly
                       style="background-color: #f5f5f5; color: #666;">
                <div class="info-text">ID gerado automaticamente: %s</div>
            </div>
            
            <h3>📶 Configuração WiFi</h3>
            
            <div class="field-group">
                <label for="wifi_ssid">Nome da Rede (SSID)</label>
                <input type="text" id="wifi_ssid" name="wifi_ssid" 
                       placeholder="Nome do seu WiFi" 
                       value="%s" required>
            </div>
            
            <div class="field-group">
                <label for="wifi_password">Senha do WiFi</label>
                <input type="password" id="wifi_password" name="wifi_password" 
                       placeholder="Deixe vazio para manter senha atual">
                <div class="info-text">Deixe vazio para manter a senha atual</div>
            </div>
            
            <h3>🌐 Configuração Backend</h3>
            
            <div class="field-group">
                <label for="backend_ip">IP do Backend</label>
                <input type="text" id="backend_ip" name="backend_ip" 
                       placeholder="Ex: 192.168.1.100" 
                       value="%s" required>
            </div>
            
            <div class="field-group">
                <label for="backend_port">Porta do Backend</label>
                <input type="number" id="backend_port" name="backend_port" 
                       placeholder="Ex: 8081" 
                       value="%d" 
                       min="1" max="65535" required>
            </div>
            
            <div class="field-group">
                <label for="relay_channels">Número de Canais de Relé</label>
                <input type="number" id="relay_channels" name="relay_channels" 
                       placeholder="Ex: 16" 
                       value="%d" 
                       min="1" max="16" required>
                <div class="info-text">Quantidade de canais de relé (1 a 16)</div>
            </div>
            
            <button type="submit" class="btn-primary">💾 Salvar Configuração</button>
        </form>
        
        <div style="margin-top: 30px; padding-top: 20px; border-top: 2px solid #eee;">
            <form action="/reboot" method="post">
                <button type="submit" class="btn-warning">🔄 Reiniciar Sistema</button>
            </form>
            
            <form action="/reset" method="post">
                <button type="submit" class="btn-danger">🗑️ Reset de Fábrica</button>
            </form>
        </div>
    </div>
</body>
</html>
""" % (
        config['device_id'],
        config['device_name'],
        wifi_status,
        config['backend_ip'],
        config['backend_port'],
        config.get('relay_channels', 16),
        msg_html,
        config['device_name'],
        config['device_id'],
        config['wifi_ssid'],
        config['backend_ip'],
        config['backend_port'],
        config.get('relay_channels', 16)
    )
    
    return html

def parse_post_data(request):
    """Parse melhorado com suporte UTF-8"""
    try:
        body_start = request.find('\r\n\r\n')
        if body_start == -1:
            return {}
        
        body = request[body_start + 4:]
        
        params = {}
        for item in body.split('&'):
            if '=' in item:
                key, value = item.split('=', 1)
                value = value.replace('+', ' ')
                # Decodificar URL encoding básico
                value = value.replace('%40', '@')
                value = value.replace('%3A', ':')
                value = value.replace('%2F', '/')
                params[key] = value
        
        return params
        
    except Exception as e:
        print(f"❌ Erro no parse: {e}")
        return {}

# ============================================================================
# SERVIDOR HTTP
# ============================================================================

def handle_http_request(request, config):
    """Processa requisições HTTP"""
    try:
        lines = request.split('\n')
        if not lines:
            return b"HTTP/1.1 400 Bad Request\r\n\r\n"
        
        first_line = lines[0].split()
        if len(first_line) < 2:
            return b"HTTP/1.1 400 Bad Request\r\n\r\n"
        
        method = first_line[0]
        path = first_line[1]
        
        print(f"📨 {method} {path}")
        
        # GET / - Página principal
        if method == 'GET' and path == '/':
            html = generate_html_inline(config)
            response = f"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n{html}"
            return response.encode('utf-8')
        
        # POST /config - Salvar configuração
        elif method == 'POST' and path == '/config':
            params = parse_post_data(request)
            
            if params:
                original_config = config.copy()
                
                # Atualizar configuração
                config['wifi_ssid'] = params.get('wifi_ssid', '')
                
                # Senha inteligente
                if params.get('wifi_password'):
                    config['wifi_password'] = params.get('wifi_password')
                
                config['backend_ip'] = params.get('backend_ip', config['backend_ip'])
                config['backend_port'] = int(params.get('backend_port', config['backend_port']))
                config['relay_channels'] = int(params.get('relay_channels', config.get('relay_channels', 16)))
                config['configured'] = True
                
                # Verificar se algo mudou
                changed = False
                for key in ['wifi_ssid', 'wifi_password', 'backend_ip', 'backend_port', 'relay_channels']:
                    if key in ['backend_port', 'relay_channels']:
                        if int(original_config.get(key, 0)) != int(config[key]):
                            changed = True
                            break
                    else:
                        if original_config.get(key, '') != config.get(key, ''):
                            changed = True
                            break
                
                if not changed:
                    message = ("info", "ℹ️ Nenhuma alteração detectada.")
                    html = generate_html_inline(config, message)
                    response = f"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n{html}"
                    return response.encode('utf-8')
                
                # Salvar configuração
                if save_config(config):
                    print("✅ Configuração salva!")
                    
                    # Tentar conectar ao WiFi
                    if config['wifi_ssid'] and config.get('wifi_password'):
                        message = ("info", "✅ Configuração salva! Conectando ao WiFi...")
                        html = generate_html_inline(config, message)
                        response = f"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n{html}"
                        return response.encode('utf-8'), {'action': 'connect_wifi'}
                    else:
                        message = ("success", "✅ Configuração salva com sucesso!")
                        html = generate_html_inline(config, message)
                        response = f"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n{html}"
                        return response.encode('utf-8')
                else:
                    message = ("error", "❌ Erro ao salvar configuração!")
                    html = generate_html_inline(config, message)
                    response = f"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n{html}"
                    return response.encode('utf-8')
            else:
                message = ("error", "❌ Dados inválidos!")
                html = generate_html_inline(config, message)
                response = f"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n{html}"
                return response.encode('utf-8')
        
        # POST /reboot - Reiniciar
        elif method == 'POST' and path == '/reboot':
            html = '''<!DOCTYPE html><html><head><meta charset="UTF-8">
            <meta http-equiv="refresh" content="5;url=/"></head>
            <body style="text-align:center; padding:50px; font-family:Arial;">
            <h2>🔄 Reiniciando...</h2><p>Aguarde 5 segundos</p></body></html>'''
            response = f"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n{html}"
            return response.encode('utf-8'), {'action': 'reboot'}
        
        # POST /reset - Reset de fábrica
        elif method == 'POST' and path == '/reset':
            delete_config()
            html = '''<!DOCTYPE html><html><head><meta charset="UTF-8">
            <meta http-equiv="refresh" content="5;url=/"></head>
            <body style="text-align:center; padding:50px; font-family:Arial;">
            <h2>🗑️ Reset de Fábrica</h2><p>Configurações apagadas. Reiniciando...</p></body></html>'''
            response = f"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n{html}"
            return response.encode('utf-8'), {'action': 'reset'}
        
        # GET /api/status - Status JSON para testes
        elif method == 'GET' and path == '/api/status':
            global global_config
            if global_config:
                sta = network.WLAN(network.STA_IF)
                status_data = {
                    "device_id": global_config['device_id'],
                    "device_name": global_config['device_name'],
                    "wifi_connected": sta.isconnected(),
                    "ip": sta.ifconfig()[0] if sta.isconnected() else "N/A",
                    "mqtt_registered": global_config.get('mqtt_registered', False),
                    "relay_states": global_config.get('relay_states', []),
                    "uptime": int(time.ticks_ms() / 1000),
                    "free_memory": gc.mem_free()
                }
                json_response = json.dumps(status_data)
                response = f"HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{json_response}"
                return response.encode('utf-8')
            else:
                return b"HTTP/1.1 503 Service Unavailable\r\n\r\n"
        
        # 404 Not Found
        else:
            return b"HTTP/1.1 404 Not Found\r\n\r\n<h1>404 Not Found</h1>"
    
    except Exception as e:
        print(f"❌ Erro no servidor: {e}")
        return b"HTTP/1.1 500 Internal Server Error\r\n\r\n"

def start_http_server(config):
    """Inicia servidor HTTP"""
    addr = socket.getaddrinfo('0.0.0.0', 80)[0][-1]
    s = socket.socket()
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(addr)
    s.listen(5)
    
    print("🌐 Servidor HTTP rodando na porta 80")
    
    while True:
        try:
            conn, addr = s.accept()
            request = conn.recv(2048).decode('utf-8')
            
            # Processar requisição
            result = handle_http_request(request, config)
            
            # Se retornar tupla, tem ação adicional
            if isinstance(result, tuple):
                response, action = result
                conn.send(response)
                conn.close()
                
                # Executar ação
                if action.get('action') == 'connect_wifi':
                    print("📡 Tentando conectar ao WiFi...")
                    if connect_wifi(config['wifi_ssid'], config['wifi_password']):
                        print("✅ WiFi conectado! Reiniciando...")
                        time.sleep(3)
                        machine.reset()
                    else:
                        print("❌ Falha na conexão WiFi")
                
                elif action.get('action') == 'reboot':
                    time.sleep(2)
                    machine.reset()
                
                elif action.get('action') == 'reset':
                    time.sleep(2)
                    machine.reset()
            else:
                conn.send(result)
                conn.close()
            
            # Limpeza de memória
            gc.collect()
            
        except Exception as e:
            print(f"❌ Erro: {e}")
            try:
                conn.close()
            except:
                pass

# ============================================================================
# MAIN
# ============================================================================

def main():
    """Função principal"""
    global mqtt_client, global_config
    
    print("=" * 50)
    print("🚀 ESP32 WiFi Config v2.0 + MQTT")
    print("=" * 50)
    
    # Carregar configuração
    config = load_config()
    global_config = config  # Para acesso global
    
    print(f"📱 Device: {config['device_name']} ({config['device_id']})")
    print(f"⚙️ Configurado: {'Sim' if config['configured'] else 'Não'}")
    print(f"🔌 MQTT: {'Registrado' if config.get('mqtt_registered') else 'Não registrado'}")
    
    # Se configurado, tentar conectar ao WiFi
    if config['configured'] and config['wifi_ssid']:
        print(f"📡 Tentando conectar a {config['wifi_ssid']}...")
        if connect_wifi(config['wifi_ssid'], config['wifi_password']):
            # Modo Station - servidor rodando no IP da rede
            sta = network.WLAN(network.STA_IF)
            print(f"📱 Acesse: http://{sta.ifconfig()[0]}")
            
            # ==========================================================
            # INTEGRAÇÃO MQTT APÓS CONEXÃO WIFI
            # ==========================================================
            
            print("\n" + "=" * 50)
            print("🔌 INICIANDO INTEGRAÇÃO MQTT")
            print("=" * 50)
            
            # 1. Registrar com backend
            try:
                if register_with_backend(config):
                    print("✅ Registro com backend concluído")
                    
                    # 2. Configurar MQTT
                    mqtt_client = setup_mqtt(config)
                    
                    if mqtt_client:
                        print("✅ MQTT configurado com sucesso")
                        
                        # 3. Iniciar loop MQTT em thread separada
                        try:
                            _thread.start_new_thread(mqtt_loop, (mqtt_client, config))
                            print("✅ Thread MQTT iniciada")
                        except Exception as e:
                            print(f"⚠️ Erro iniciando thread MQTT: {e}")
                            print("⚠️ Continuando sem MQTT...")
                    else:
                        print("⚠️ Falha na configuração MQTT")
                else:
                    print("⚠️ Falha no registro - continuando sem MQTT")
            except Exception as e:
                print(f"⚠️ Erro na integração MQTT: {e}")
                print("⚠️ Continuando apenas com servidor HTTP...")
            
            print("=" * 50)
            print("🌐 SISTEMA PRONTO")
            print("=" * 50)
            
        else:
            print("❌ Falha na conexão, iniciando AP...")
            setup_ap(config)
            print("📱 Acesse: http://192.168.4.1")
    else:
        # Modo AP
        setup_ap(config)
        print("📱 Modo AP ativo - acesse http://192.168.4.1")
    
    # Iniciar servidor HTTP (sempre roda)
    start_http_server(config)

# Executar
if __name__ == "__main__":
    main()