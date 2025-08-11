#!/usr/bin/env python3
"""
Script de teste para notificações Telegram
"""

from services.telegram_notifier import telegram, notify, alert, device_status
import time

def test_telegram():
    print("🔧 Testando notificações Telegram...")
    
    # 1. Teste de mensagem simples
    print("\n1. Enviando mensagem simples...")
    if notify("✅ Teste de notificação do AutoCore!"):
        print("   ✓ Mensagem enviada")
    else:
        print("   ✗ Falha ao enviar")
        print("   Verifique TELEGRAM_BOT_TOKEN e TELEGRAM_CHAT_ID no .env")
        return
    
    time.sleep(1)
    
    # 2. Teste de alerta
    print("\n2. Enviando alerta...")
    if alert("Teste de Alerta", "Este é um teste do sistema de alertas", "WARNING"):
        print("   ✓ Alerta enviado")
    
    time.sleep(1)
    
    # 3. Teste de status de dispositivo
    print("\n3. Enviando status de dispositivo...")
    if device_status("ESP32_Relay_93ce30", "online", "IP: 192.168.1.100"):
        print("   ✓ Status enviado")
    
    time.sleep(1)
    
    # 4. Teste de mensagem de inicialização
    print("\n4. Enviando mensagem de startup...")
    if telegram.send_startup_message():
        print("   ✓ Startup enviado")
    
    time.sleep(1)
    
    # 5. Teste de ação de relé
    print("\n5. Enviando ação de relé...")
    if telegram.notify_relay_action(1, "ON", "ESP32_Relay_93ce30"):
        print("   ✓ Ação de relé enviada")
    
    print("\n✅ Todos os testes concluídos!")
    print("Verifique seu Telegram para ver as mensagens")

if __name__ == "__main__":
    test_telegram()