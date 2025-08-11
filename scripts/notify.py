#!/usr/bin/env python3
"""
Script simples para enviar notificações via Telegram
Uso: python notify.py "Sua mensagem aqui"
"""

import sys
import os
import requests
from datetime import datetime

# Token e Chat ID do Telegram
TELEGRAM_BOT_TOKEN = "8364500593:AAG-F57bNhpREYZ4iGPSTXgQhiKQMqutqPQ"
TELEGRAM_CHAT_ID = "5644979847"  # Chat ID do Lee

def send_telegram_message(message, chat_id=None):
    """Envia mensagem via Telegram"""
    
    # Usar chat_id fornecido ou o padrão
    target_chat_id = chat_id or TELEGRAM_CHAT_ID
    
    if target_chat_id == "SEU_CHAT_ID_AQUI":
        print("❌ ERRO: Você precisa configurar seu TELEGRAM_CHAT_ID!")
        print("\n📱 Para obter seu Chat ID:")
        print("1. Abra o Telegram")
        print("2. Envie uma mensagem para seu bot: @AutoCoreNotifyBot")
        print("3. Execute: python scripts/get_chat_id.py")
        return False
    
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    
    # Adicionar timestamp
    timestamp = datetime.now().strftime("%H:%M:%S")
    formatted_message = f"🤖 <b>AutoCore Notification</b>\n\n{message}\n\n⏰ {timestamp}"
    
    payload = {
        "chat_id": target_chat_id,
        "text": formatted_message,
        "parse_mode": "HTML"
    }
    
    try:
        response = requests.post(url, json=payload, timeout=10)
        if response.status_code == 200:
            print(f"✅ Notificação enviada com sucesso!")
            return True
        else:
            print(f"❌ Erro ao enviar notificação: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Erro ao enviar notificação: {e}")
        return False

def main():
    """Função principal"""
    
    # Verificar argumentos
    if len(sys.argv) < 2:
        print("Uso: python notify.py \"Sua mensagem aqui\" [chat_id_opcional]")
        print("\nExemplos:")
        print('  python notify.py "Tarefa concluída!"')
        print('  python notify.py "Deploy finalizado" 123456789')
        sys.exit(1)
    
    message = sys.argv[1]
    chat_id = sys.argv[2] if len(sys.argv) > 2 else None
    
    # Enviar mensagem
    send_telegram_message(message, chat_id)

if __name__ == "__main__":
    main()