def get_simple_html(config):
    """HTML minimalista para ESP32"""
    
    html = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ESP32 Config</title>
<style>
body{{font-family:Arial;margin:20px;background:#f0f0f0}}
h1{{color:#333}}
.box{{background:white;padding:20px;border-radius:5px;margin:20px 0}}
input,button{{width:100%;padding:10px;margin:5px 0;border:1px solid #ddd;border-radius:3px}}
button{{background:#4CAF50;color:white;cursor:pointer}}
.info{{color:#666;font-size:12px}}
</style>
</head>
<body>
<h1>ESP32 Relay Config</h1>
<div class="box">
<b>Device:</b> {config['device_id']}<br>
<b>WiFi:</b> {config.get('wifi_ssid', 'Not configured')}<br>
<b>Backend:</b> {config.get('backend_ip', '')}:{config.get('backend_port', '')}<br>
<b>MQTT:</b> {'OK' if config.get('mqtt_registered') else 'Not registered'}
</div>
<form action="/config" method="post">
<div class="box">
<h3>WiFi Settings</h3>
<input type="text" name="wifi_ssid" placeholder="WiFi Name" value="{config.get('wifi_ssid', '')}" required>
<input type="password" name="wifi_password" placeholder="WiFi Password">
<div class="info">Leave empty to keep current password</div>
</div>
<div class="box">
<h3>Backend Settings</h3>
<input type="text" name="backend_ip" placeholder="Backend IP" value="{config.get('backend_ip', '')}" required>
<input type="number" name="backend_port" placeholder="Port" value="{config.get('backend_port', 8081)}" required>
<input type="number" name="relay_channels" placeholder="Relay Channels" value="{config.get('relay_channels', 16)}" min="1" max="16">
</div>
<button type="submit">Save Configuration</button>
</form>
<div class="box">
<form action="/reboot" method="post" style="display:inline">
<button type="submit" style="background:#ff9800">Reboot</button>
</form>
<form action="/reset" method="post" style="display:inline">
<button type="submit" style="background:#f44336">Factory Reset</button>
</form>
</div>
</body>
</html>"""
    
    return html