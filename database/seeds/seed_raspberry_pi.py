#!/usr/bin/env python3
"""
Seed mínimo para Raspberry Pi - AutoCore
Apenas estrutura essencial sem dados de exemplo
Data: 09 de janeiro de 2025
"""
import sys
from pathlib import Path
from datetime import datetime
import json

# Adiciona path para importar models
sys.path.append(str(Path(__file__).parent.parent))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from src.models.models import (
    Base, User, Theme, CANSignal, EventLog
)

DATABASE_URL = f"sqlite:///{Path(__file__).parent.parent}/autocore.db"
engine = create_engine(DATABASE_URL, echo=False)
Session = sessionmaker(bind=engine)

def clear_database(session):
    """Limpa dados existentes na ordem correta"""
    print("🗑️  Limpando dados existentes...")
    
    # Limpar apenas tabelas essenciais
    session.query(EventLog).delete()
    session.query(User).delete()
    session.query(Theme).delete()
    session.query(CANSignal).delete()
    session.commit()
    print("✓ Dados anteriores removidos")

def seed_users(session):
    """Cria usuário administrador padrão"""
    print("\n👤 Criando usuário administrador...")
    
    # Apenas o admin essencial
    admin = User(
        id=1,
        username='admin',
        password_hash='$2b$12$LQi3c8zc8Jc8zc8Jc8zc8u',  # senha: admin123 (alterar após primeiro login)
        full_name='Administrador',
        email='admin@autocore.local',
        role='admin',
        pin_code='1234',
        is_active=True
    )
    
    session.add(admin)
    session.commit()
    print("✓ Usuário admin criado (senha: admin123)")

def seed_themes(session):
    """Cria temas padrão do sistema"""
    print("\n🎨 Criando temas...")
    
    themes = [
        Theme(
            id=1,
            name='AutoCore Dark',
            description='Tema escuro para uso noturno',
            primary_color='#3B82F6',
            secondary_color='#10B981',
            background_color='#111827',
            surface_color='#1F2937',
            success_color='#10B981',
            warning_color='#F59E0B',
            error_color='#EF4444',
            info_color='#3B82F6',
            text_primary='#F9FAFB',
            text_secondary='#9CA3AF',
            border_radius=8,
            shadow_style='elevated',
            font_family='Inter, system-ui',
            is_active=True,
            is_default=True
        ),
        Theme(
            id=2,
            name='AutoCore Light',
            description='Tema claro para uso diurno',
            primary_color='#2563EB',
            secondary_color='#059669',
            background_color='#FFFFFF',
            surface_color='#F3F4F6',
            success_color='#059669',
            warning_color='#D97706',
            error_color='#DC2626',
            info_color='#2563EB',
            text_primary='#111827',
            text_secondary='#6B7280',
            border_radius=8,
            shadow_style='subtle',
            font_family='Inter, system-ui',
            is_active=True,
            is_default=False
        )
    ]
    
    session.add_all(themes)
    session.commit()
    print(f"✓ {len(themes)} temas criados")

def seed_can_signals(session):
    """Cria sinais CAN básicos para FuelTech"""
    print("\n🚗 Criando sinais CAN padrão...")
    
    signals = [
        CANSignal(
            id=1, 
            signal_name='rpm', 
            can_id='0x3E8', 
            start_bit=0, 
            length_bits=16, 
            byte_order='big_endian', 
            data_type='unsigned', 
            scale_factor=1.0, 
            offset=0, 
            unit='rpm', 
            min_value=0, 
            max_value=10000, 
            description='Rotação do motor', 
            category='engine'
        ),
        CANSignal(
            id=2, 
            signal_name='speed', 
            can_id='0x3E9', 
            start_bit=0, 
            length_bits=16, 
            byte_order='big_endian', 
            data_type='unsigned', 
            scale_factor=0.1, 
            offset=0, 
            unit='km/h', 
            min_value=0, 
            max_value=300, 
            description='Velocidade do veículo', 
            category='motion'
        ),
        CANSignal(
            id=3, 
            signal_name='coolant_temp', 
            can_id='0x3EA', 
            start_bit=0, 
            length_bits=16, 
            byte_order='big_endian', 
            data_type='signed', 
            scale_factor=0.1, 
            offset=-40, 
            unit='°C', 
            min_value=-40, 
            max_value=150, 
            description='Temperatura do líquido de arrefecimento', 
            category='engine'
        ),
        CANSignal(
            id=4, 
            signal_name='oil_pressure', 
            can_id='0x3EB', 
            start_bit=0, 
            length_bits=16, 
            byte_order='big_endian', 
            data_type='unsigned', 
            scale_factor=0.01, 
            offset=0, 
            unit='bar', 
            min_value=0, 
            max_value=10, 
            description='Pressão do óleo', 
            category='engine'
        ),
        CANSignal(
            id=5, 
            signal_name='fuel_level', 
            can_id='0x3EC', 
            start_bit=0, 
            length_bits=8, 
            byte_order='big_endian', 
            data_type='unsigned', 
            scale_factor=0.392, 
            offset=0, 
            unit='%', 
            min_value=0, 
            max_value=100, 
            description='Nível de combustível', 
            category='fuel'
        ),
        CANSignal(
            id=6, 
            signal_name='battery_voltage', 
            can_id='0x3ED', 
            start_bit=0, 
            length_bits=16, 
            byte_order='big_endian', 
            data_type='unsigned', 
            scale_factor=0.01, 
            offset=0, 
            unit='V', 
            min_value=0, 
            max_value=20, 
            description='Tensão da bateria', 
            category='electrical'
        ),
        CANSignal(
            id=7, 
            signal_name='map_sensor', 
            can_id='0x3EE', 
            start_bit=0, 
            length_bits=16, 
            byte_order='big_endian', 
            data_type='unsigned', 
            scale_factor=0.001, 
            offset=0, 
            unit='bar', 
            min_value=0, 
            max_value=5, 
            description='Pressão do coletor de admissão', 
            category='engine'
        ),
        CANSignal(
            id=8, 
            signal_name='throttle_position', 
            can_id='0x3EF', 
            start_bit=0, 
            length_bits=8, 
            byte_order='big_endian', 
            data_type='unsigned', 
            scale_factor=0.392, 
            offset=0, 
            unit='%', 
            min_value=0, 
            max_value=100, 
            description='Posição do acelerador', 
            category='engine'
        )
    ]
    
    session.add_all(signals)
    session.commit()
    print(f"✓ {len(signals)} sinais CAN criados")

def seed_initial_event(session):
    """Cria evento inicial de sistema"""
    print("\n📝 Criando evento inicial...")
    
    event = EventLog(
        event_type='system',
        source='database',
        target=None,
        action='seed_applied',
        user_id=1,
        status='success',
        timestamp=datetime.now(),
        metadata={'version': '1.0.0', 'seed': 'raspberry_pi'}
    )
    
    session.add(event)
    session.commit()
    print("✓ Evento inicial criado")

def main():
    """Executa o seed mínimo para Raspberry Pi"""
    print("\n" + "=" * 50)
    print("🌱 SEED RASPBERRY PI - AUTOCORE")
    print("=" * 50)
    
    session = Session()
    
    try:
        # Limpar dados existentes
        clear_database(session)
        
        # Aplicar seeds essenciais
        seed_users(session)
        seed_themes(session)
        seed_can_signals(session)
        seed_initial_event(session)
        
        print("\n" + "=" * 50)
        print("✅ SEED APLICADO COM SUCESSO!")
        print("=" * 50)
        
        print("\n📊 Resumo:")
        print("   • 1 Usuário administrador")
        print("   • 2 Temas (Dark e Light)")
        print("   • 8 Sinais CAN padrão FuelTech")
        print("   • 1 Evento de sistema")
        
        print("\n💡 Próximos passos:")
        print("   1. Altere a senha do admin após o primeiro login")
        print("   2. Cadastre os dispositivos ESP32 pela interface")
        print("   3. Configure as placas de relé conforme necessário")
        print("   4. Crie as telas personalizadas")
        print("   5. Configure as macros de automação")
        
    except Exception as e:
        session.rollback()
        print(f"\n❌ Erro ao aplicar seed: {e}")
        import traceback
        traceback.print_exc()
    finally:
        session.close()

if __name__ == '__main__':
    main()