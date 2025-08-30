#!/usr/bin/env python3
"""
Teste específico para o chassi real LA1BSK29242
"""
import sys
sys.path.append('src')
from pathlib import Path
from datetime import datetime
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from shared.vehicle_repository import VehicleRepository
import uuid as uuid_lib

# Database setup
DATABASE_URL = f"sqlite:///{Path(__file__).parent}/autocore.db"
engine = create_engine(DATABASE_URL, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def test_real_chassis():
    """Teste com o chassi real LA1BSK29242"""
    session = SessionLocal()
    repo = VehicleRepository(session)
    
    print("🧪 TESTANDO CHASSI REAL: LA1BSK29242")
    print("=" * 50)
    
    # Dados reais
    vehicle_data = {
        'uuid': str(uuid_lib.uuid4()),
        'plate': 'MNG4D56',
        'chassis': 'LA1BSK29242',  # 11 caracteres
        'renavam': '00179619063',
        'brand': 'FORD',
        'model': 'JEEP WILLYS',
        'version': 'RURAL 4X4',
        'year_manufacture': 1976,
        'year_model': 1976,
        'color': 'VERMELHA',
        'fuel_type': 'gasoline',
        'engine_capacity': 2.6,
        'engine_power': 69,
        'category': 'passenger',
        'status': 'active',
        'odometer': 0,
        'notes': 'Proprietário: LEE CHARDES THEOTONIO ALVES - CPF: 303.353.588-70'
    }
    
    try:
        print("1. Tentando criar veículo com chassi real...")
        vehicle = repo.create_or_update_vehicle(vehicle_data)
        session.commit()
        
        print(f"✅ SUCESSO! Veículo criado:")
        print(f"   ID: {vehicle['id']}")
        print(f"   Placa: {vehicle['plate']}")
        print(f"   Chassi: {vehicle['chassis']}")
        print(f"   Marca: {vehicle['brand']} {vehicle['model']}")
        print(f"   Ano: {vehicle['year_model']}")
        
        # Testar busca
        print("\n2. Testando busca do veículo...")
        found = repo.get_vehicle()
        if found:
            print(f"✅ Veículo encontrado: {found['chassis']}")
        else:
            print("❌ Veículo não encontrado!")
            
        return True
        
    except Exception as e:
        print(f"❌ ERRO: {str(e)}")
        session.rollback()
        return False
    finally:
        session.close()

if __name__ == "__main__":
    success = test_real_chassis()
    if success:
        print("\n🎉 TESTE CONCLUÍDO COM SUCESSO!")
        exit(0)
    else:
        print("\n💥 TESTE FALHOU!")
        exit(1)