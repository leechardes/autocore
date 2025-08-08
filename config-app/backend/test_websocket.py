#!/usr/bin/env python3
"""
Script de teste para WebSocket
"""
import asyncio
import websockets
import json

async def test_websocket():
    uri = "ws://localhost:8000/ws/mqtt"
    
    print(f"Tentando conectar em: {uri}")
    
    try:
        async with websockets.connect(uri) as websocket:
            print("✅ Conectado com sucesso!")
            
            # Receber mensagem inicial
            message = await websocket.recv()
            data = json.loads(message)
            print(f"📨 Mensagem recebida: {data['type']}")
            
            # Manter conexão por alguns segundos
            await asyncio.sleep(2)
            
            print("✅ Teste concluído com sucesso!")
            
    except Exception as e:
        print(f"❌ Erro: {e}")
        print(f"   Tipo: {type(e).__name__}")

if __name__ == "__main__":
    asyncio.run(test_websocket())