#!/usr/bin/env python3
"""
Script automático para descobrir Chat ID do Telegram
"""

import requests
import json

TELEGRAM_BOT_TOKEN = "8364500593:AAG-F57bNhpREYZ4iGPSTXgQhiKQMqutqPQ"

def get_chat_id():
    """Obtém o Chat ID das mensagens recentes"""
    
    print("🔍 Buscando mensagens recentes do bot...")
    
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/getUpdates"
    
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            
            if data["ok"] and data["result"]:
                # Pegar o chat_id da última mensagem
                chats_found = {}
                
                for update in data["result"]:
                    if "message" in update:
                        chat = update["message"]["chat"]
                        chat_id = str(chat["id"])
                        chat_name = chat.get("first_name", chat.get("title", "Unknown"))
                        chat_username = chat.get("username", "")
                        message_text = update["message"].get("text", "")
                        
                        if chat_id not in chats_found:
                            chats_found[chat_id] = {
                                "name": chat_name,
                                "username": chat_username,
                                "last_message": message_text
                            }
                
                if chats_found:
                    print("\n✅ Chats encontrados:\n")
                    print("=" * 50)
                    for chat_id, info in chats_found.items():
                        print(f"📱 Chat ID: {chat_id}")
                        print(f"👤 Nome: {info['name']}")
                        if info['username']:
                            print(f"🔗 Username: @{info['username']}")
                        print(f"💬 Última mensagem: {info['last_message'][:50]}...")
                        print("-" * 50)
                    
                    # Pegar o primeiro chat_id
                    first_chat_id = list(chats_found.keys())[0]
                    
                    print(f"\n📝 Para configurar, atualize o arquivo notify.py:")
                    print(f'TELEGRAM_CHAT_ID = "{first_chat_id}"')
                    
                    print(f"\n🧪 Enviando mensagem de teste para Chat ID: {first_chat_id}...")
                    
                    # Enviar mensagem de teste
                    test_url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
                    test_payload = {
                        "chat_id": first_chat_id,
                        "text": "✅ <b>AutoCore Telegram Configurado!</b>\n\n🤖 Bot conectado com sucesso!\n💬 Você receberá notificações aqui.",
                        "parse_mode": "HTML"
                    }
                    test_response = requests.post(test_url, json=test_payload)
                    if test_response.status_code == 200:
                        print("✅ Mensagem de teste enviada! Verifique seu Telegram.")
                        return first_chat_id
                    else:
                        print("❌ Erro ao enviar mensagem de teste")
                        print(f"Resposta: {test_response.text}")
                else:
                    print("\n❌ Nenhuma mensagem encontrada!")
                    print("\n📱 Para configurar:")
                    print("1. Abra o Telegram")
                    print("2. Procure pelo bot usando o token fornecido")
                    print("3. Envie /start ou qualquer mensagem")
                    print("4. Execute este script novamente")
            else:
                print("❌ Nenhuma mensagem encontrada.")
                print("\n📱 Instruções:")
                print("1. Abra o Telegram")  
                print("2. Procure o bot pelo username ou token")
                print("3. Envie uma mensagem (ex: /start)")
                print("4. Execute este script novamente")
        else:
            print(f"❌ Erro ao conectar com Telegram: {response.status_code}")
            print(f"Resposta: {response.text}")
            
    except Exception as e:
        print(f"❌ Erro: {e}")
        
    return None

if __name__ == "__main__":
    chat_id = get_chat_id()
    if chat_id:
        print(f"\n✅ Sucesso! Seu Chat ID é: {chat_id}")
        print("\nPróximos passos:")
        print(f"1. Edite /Users/leechardes/Projetos/AutoCore/scripts/notify.py")
        print(f"2. Substitua TELEGRAM_CHAT_ID = \"SEU_CHAT_ID_AQUI\" por:")
        print(f"   TELEGRAM_CHAT_ID = \"{chat_id}\"")
        print(f"3. Teste: python3 scripts/notify.py \"Teste de notificação\"")