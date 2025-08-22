#!/usr/bin/env python3
"""
Teste simples para o endpoint /api/config/full em modo preview
"""
import requests
import json
import sys

def test_preview_endpoint():
    """Testa o endpoint preview"""
    base_url = "http://localhost:8081"
    
    print("🧪 Testando endpoint /api/config/full em modo preview\n")
    
    # Teste 1: Endpoint sem UUID (modo preview padrão)
    print("1️⃣ Testando GET /api/config/full")
    try:
        response = requests.get(f"{base_url}/api/config/full", timeout=5)
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   Preview mode: {data.get('preview_mode', False)}")
            print(f"   Screens: {len(data.get('screens', []))}")
            print(f"   Telemetria: {len(data.get('telemetry', {}))}")
            print("   ✅ Sucesso")
        else:
            print(f"   ❌ Erro: {response.text}")
    except requests.exceptions.ConnectionError:
        print("   ⚠️ Servidor não está rodando")
    except Exception as e:
        print(f"   ❌ Erro: {e}")
    
    print()
    
    # Teste 2: Endpoint com UUID "preview"
    print("2️⃣ Testando GET /api/config/full/preview")
    try:
        response = requests.get(f"{base_url}/api/config/full/preview", timeout=5)
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   Preview mode: {data.get('preview_mode', False)}")
            print(f"   Device UUID: {data.get('device', {}).get('uuid')}")
            print("   ✅ Sucesso")
        else:
            print(f"   ❌ Erro: {response.text}")
    except requests.exceptions.ConnectionError:
        print("   ⚠️ Servidor não está rodando")
    except Exception as e:
        print(f"   ❌ Erro: {e}")
    
    print()
    
    # Teste 3: Endpoint com query param preview=true
    print("3️⃣ Testando GET /api/config/full?preview=true")
    try:
        response = requests.get(f"{base_url}/api/config/full?preview=true", timeout=5)
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   Preview mode: {data.get('preview_mode', False)}")
            print("   ✅ Sucesso")
        else:
            print(f"   ❌ Erro: {response.text}")
    except requests.exceptions.ConnectionError:
        print("   ⚠️ Servidor não está rodando")
    except Exception as e:
        print(f"   ❌ Erro: {e}")
    
    print()
    print("🏁 Testes concluídos!")

if __name__ == "__main__":
    test_preview_endpoint()