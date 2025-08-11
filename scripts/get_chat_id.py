#!/usr/bin/env python3
"""
Script para descobrir seu Chat ID do Telegram
"""

import requests
import json

TELEGRAM_BOT_TOKEN = "8364500593:AAG-F57bNhpREYZ4iGPSTXgQhiKQMqutqPQ"

def get_chat_id():
    """Obtém o Chat ID das mensagens recentes"""
    
    print("🔍 Buscando seu Chat ID...")
    print("\n📱 IMPORTANTE: Antes de continuar:")
    print("1. Abra o Telegram")
    print("2. Procure por seu bot (deve terminar com _bot)")
    print("3. Envie uma mensagem qualquer para ele (ex: 'oi')")
    print("4. Depois pressione ENTER aqui para continuar...")
    
    input()
    
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/getUpdates"
    
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            
            if data["ok"] and data["result"]:
                # Pegar o chat_id da última mensagem
                chats_found = set()
                
                for update in data["result"]:
                    if "message" in update:
                        chat = update["message"]["chat"]
                        chat_id = chat["id"]
                        chat_name = chat.get("first_name", "Unknown")
                        chat_username = chat.get("username", "")
                        
                        chats_found.add((chat_id, chat_name, chat_username))
                
                if chats_found:
                    print("\n✅ Chat IDs encontrados:\n")
                    for chat_id, name, username in chats_found:
                        print(f"Chat ID: {chat_id}")
                        print(f"Nome: {name}")
                        if username:
                            print(f"Username: @{username}")
                        print("-" * 40)
                    
                    print("\n📝 Para usar, atualize o script notify.py:")
                    print(f'TELEGRAM_CHAT_ID = "{list(chats_found)[0][0]}"')
                    
                    # Testar envio
                    print("\n🧪 Deseja enviar uma mensagem de teste? (s/n): ", end="")
                    if input().lower() == 's':
                        test_chat_id = list(chats_found)[0][0]
                        test_url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
                        test_payload = {
                            "chat_id": test_chat_id,
                            "text": "✅ Teste bem-sucedido! AutoCore Telegram configurado!",
                            "parse_mode": "HTML"
                        }
                        test_response = requests.post(test_url, json=test_payload)
                        if test_response.status_code == 200:
                            print("✅ Mensagem de teste enviada com sucesso!")
                        else:
                            print("❌ Erro ao enviar mensagem de teste")
                else:
                    print("\n❌ Nenhuma mensagem encontrada!")
                    print("Certifique-se de ter enviado uma mensagem para o bot")
            else:
                print("❌ Nenhuma mensagem encontrada. Envie uma mensagem para o bot primeiro!")
        else:
            print(f"❌ Erro ao conectar com Telegram: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Erro: {e}")

if __name__ == "__main__":
    get_chat_id()