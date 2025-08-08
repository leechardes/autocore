#!/usr/bin/env python3
"""
Script para atualizar permissões de macros nos canais
Define quais canais podem ou não ser usados em macros
"""
import sys
from pathlib import Path

# Adiciona ao path
sys.path.append(str(Path(__file__).parent.parent))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from src.models.models import RelayChannel, Base

# Configurar conexão
engine = create_engine('sqlite:///autocore.db', connect_args={'check_same_thread': False})
SessionLocal = sessionmaker(bind=engine)

def update_macro_permissions():
    """Atualiza permissões de uso em macros para canais específicos"""
    
    with SessionLocal() as session:
        # Buscar todos os canais
        channels = session.query(RelayChannel).all()
        
        print(f"📋 Total de canais encontrados: {len(channels)}")
        
        updated_count = 0
        
        for channel in channels:
            # Por padrão, todos podem ser usados em macros
            channel.allow_in_macro = True
            
            # Regras específicas:
            # 1. Canais momentâneos não podem ser usados em macros
            if channel.function_type == 'momentary':
                channel.allow_in_macro = False
                print(f"  ❌ Canal {channel.channel_number} ({channel.name}) - Momentâneo - Desabilitado para macros")
                updated_count += 1
                
            # 2. Canal do guincho (geralmente tem "guincho" ou "winch" no nome)
            elif any(keyword in channel.name.lower() for keyword in ['guincho', 'winch']):
                channel.allow_in_macro = False
                print(f"  ❌ Canal {channel.channel_number} ({channel.name}) - Guincho - Desabilitado para macros")
                updated_count += 1
                
            # 3. Canais com proteção por senha podem ser usados, mas com cuidado
            elif channel.protection_mode == 'password':
                # Mantém permitido, mas mostra aviso
                print(f"  ⚠️  Canal {channel.channel_number} ({channel.name}) - Protegido por senha - Permitido com cuidado")
            
            else:
                # Canal normal, permitido
                print(f"  ✅ Canal {channel.channel_number} ({channel.name}) - Permitido em macros")
        
        # Salvar alterações
        session.commit()
        
        print(f"\n✅ Atualização concluída!")
        print(f"   {updated_count} canais foram desabilitados para uso em macros")
        print(f"   {len(channels) - updated_count} canais podem ser usados em macros")
        
        # Mostrar resumo
        print(f"\n📊 Resumo:")
        allowed = session.query(RelayChannel).filter(RelayChannel.allow_in_macro == True).count()
        not_allowed = session.query(RelayChannel).filter(RelayChannel.allow_in_macro == False).count()
        print(f"   Permitidos em macros: {allowed}")
        print(f"   Não permitidos em macros: {not_allowed}")

if __name__ == "__main__":
    print("🔧 Atualizando permissões de macros nos canais...")
    print("-" * 50)
    
    try:
        update_macro_permissions()
    except Exception as e:
        print(f"❌ Erro ao atualizar: {e}")
        sys.exit(1)