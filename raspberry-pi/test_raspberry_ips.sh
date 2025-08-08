#!/bin/bash

echo "🔍 Testando IPs com SSH para encontrar o Raspberry Pi..."
echo ""

# Lista de IPs para testar
IPS="10.0.10.1 10.0.10.2 10.0.10.3 10.0.10.5 10.0.10.8 10.0.10.11"

for IP in $IPS; do
    echo "Testando $IP..."
    
    # Tentar obter o banner SSH
    BANNER=$(timeout 2 nc -v $IP 22 2>&1 | grep -i "ssh\|openssh" | head -1)
    
    if [ ! -z "$BANNER" ]; then
        echo "  ✓ SSH ativo: $BANNER"
        
        # Tentar conectar como pi (vai pedir senha)
        echo "  Tentando conectar como usuário 'pi'..."
        ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no -o PasswordAuthentication=yes pi@$IP "echo '✅ ESTE É O RASPBERRY PI!'; hostname; uname -a" 2>&1 | grep -v "Warning" | grep -v "password"
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "🎉 RASPBERRY PI ENCONTRADO!"
            echo "  IP: $IP"
            echo "  Para conectar: ssh pi@$IP"
            echo "  Senha: raspberry"
            exit 0
        fi
    else
        echo "  ✗ Sem SSH"
    fi
    echo ""
done

echo "❌ Raspberry Pi não encontrado nos IPs testados"
echo ""
echo "Possíveis problemas:"
echo "1. O Raspberry Pi ainda está inicializando (aguarde mais 1-2 minutos)"
echo "2. As credenciais WiFi podem estar incorretas"
echo "3. O Pi pode ter obtido um IP diferente"
echo ""
echo "Tente verificar no seu roteador por novos dispositivos"