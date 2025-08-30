#!/usr/bin/env python3
"""
Teste do VehicleRepository
"""
import sys
from pathlib import Path

# Adiciona o path para os imports
sys.path.append(str(Path(__file__).parent))

from shared.vehicle_repository import create_vehicle_repository
from shared.repositories import DeviceRepository, SessionLocal
from src.models.models import User, Device
import uuid
import json

def create_test_user():
    """Cria usuário de teste se não existir"""
    with SessionLocal() as session:
        # Verifica se já existe usuário de teste
        test_user = session.query(User).filter_by(username='test_user').first()
        if test_user:
            print(f"✅ Usuário de teste já existe: ID {test_user.id}")
            return test_user.id
        
        # Cria usuário de teste
        user = User(
            username='test_user',
            password_hash='$2b$12$test_hash',
            full_name='Usuário de Teste',
            email='test@autocore.com',
            role='admin'
        )
        session.add(user)
        session.commit()
        session.refresh(user)
        
        print(f"✅ Usuário de teste criado: ID {user.id}")
        return user.id

def create_test_device():
    """Cria device de teste se não existir"""
    device_repo = DeviceRepository()
    
    try:
        # Tenta buscar device existente
        existing = device_repo.get_by_uuid('test-device-uuid-001')
        if existing:
            print(f"✅ Device de teste já existe: ID {existing.id}")
            return existing.id
        
        # Cria device de teste
        device_data = {
            'uuid': 'test-device-uuid-001',
            'name': 'ESP32 Test Device',
            'type': 'esp32_display',
            'mac_address': '00:11:22:33:44:55',
            'ip_address': '192.168.1.100',
            'firmware_version': '1.0.0'
        }
        
        device = device_repo.create(device_data)
        print(f"✅ Device de teste criado: ID {device.id}")
        return device.id
        
    except Exception as e:
        print(f"❌ Erro ao criar device: {e}")
        return None

def test_vehicle_creation():
    """Testa criação de veículo"""
    print("\n🚗 Testando criação de veículo...")
    
    # Cria dependências
    user_id = create_test_user()
    device_id = create_test_device()
    
    # Cria repository
    vehicle_repo = create_vehicle_repository()
    
    try:
        # Dados do veículo de teste
        vehicle_data = {
            'plate': 'ABC1234',
            'chassis': '9BWZZZ377VT004251',
            'renavam': '12345678901',
            'brand': 'Toyota',
            'model': 'Corolla',
            'version': 'XEI 2.0',
            'year_manufacture': 2020,
            'year_model': 2021,
            'color': 'Prata',
            'fuel_type': 'flex',
            'engine_capacity': 2000,
            'engine_power': 154,
            'transmission': 'automatic',
            'category': 'passenger',
            'usage_type': 'personal',
            'user_id': user_id,
            'primary_device_id': device_id,
            'status': 'active',
            'odometer': 15000,
            'notes': 'Veículo de teste para validação do sistema'
        }
        
        # Cria veículo
        vehicle = vehicle_repo.create_vehicle(vehicle_data)
        print(f"✅ Veículo criado com sucesso!")
        print(f"   ID: {vehicle['id']}")
        print(f"   Placa: {vehicle['plate']}")
        print(f"   Modelo: {vehicle['full_name']}")
        print(f"   Status: {vehicle['status']}")
        
        # Comita a transação
        vehicle_repo.session.commit()
        
        return vehicle['id']
        
    except Exception as e:
        print(f"❌ Erro ao criar veículo: {e}")
        vehicle_repo.session.rollback()
        return None
    finally:
        vehicle_repo.session.close()

def test_vehicle_queries():
    """Testa queries de veículos"""
    print("\n🔍 Testando queries de veículos...")
    
    vehicle_repo = create_vehicle_repository()
    
    try:
        # Lista todos os veículos ativos
        active_vehicles = vehicle_repo.get_active_vehicles()
        print(f"✅ Veículos ativos encontrados: {len(active_vehicles)}")
        
        for vehicle in active_vehicles:
            print(f"   - {vehicle['plate']} - {vehicle['full_name']}")
        
        # Busca por placa
        if active_vehicles:
            plate = active_vehicles[0]['plate']
            found_vehicle = vehicle_repo.get_vehicle_by_plate(plate)
            if found_vehicle:
                print(f"✅ Busca por placa '{plate}' funcionou!")
            else:
                print(f"❌ Busca por placa '{plate}' falhou!")
        
        # Lista veículos de um usuário
        if active_vehicles:
            user_id = active_vehicles[0].get('owner', {}).get('id')
            if user_id:
                user_vehicles = vehicle_repo.get_user_vehicles(user_id)
                print(f"✅ Veículos do usuário {user_id}: {len(user_vehicles)}")
        
    except Exception as e:
        print(f"❌ Erro nas queries: {e}")
    finally:
        vehicle_repo.session.close()

def test_vehicle_location():
    """Testa atualização de localização"""
    print("\n📍 Testando atualização de localização...")
    
    vehicle_repo = create_vehicle_repository()
    
    try:
        # Busca veículo para testar
        active_vehicles = vehicle_repo.get_active_vehicles()
        if not active_vehicles:
            print("❌ Nenhum veículo ativo para testar localização")
            return
        
        vehicle_id = active_vehicles[0]['id']
        
        # Atualiza localização (coordenadas de São Paulo)
        success = vehicle_repo.update_location(
            vehicle_id=vehicle_id,
            latitude=-23.5505,
            longitude=-46.6333,
            accuracy=5
        )
        
        if success:
            print(f"✅ Localização atualizada para veículo ID {vehicle_id}")
            vehicle_repo.session.commit()
            
            # Verifica se foi salvo
            vehicle = vehicle_repo.get_vehicle(vehicle_id)
            if vehicle and vehicle['last_location']:
                location = vehicle['last_location']
                print(f"   Localização: {location['lat']}, {location['lng']}")
                print(f"   Precisão: {location.get('accuracy', 'N/A')} metros")
            
        else:
            print(f"❌ Falha ao atualizar localização")
            
    except Exception as e:
        print(f"❌ Erro na atualização de localização: {e}")
        vehicle_repo.session.rollback()
    finally:
        vehicle_repo.session.close()

def test_vehicle_maintenance():
    """Testa funcionalidades de manutenção"""
    print("\n🔧 Testando funcionalidades de manutenção...")
    
    vehicle_repo = create_vehicle_repository()
    
    try:
        # Busca veículo para testar
        active_vehicles = vehicle_repo.get_active_vehicles()
        if not active_vehicles:
            print("❌ Nenhum veículo ativo para testar manutenção")
            return
        
        vehicle_id = active_vehicles[0]['id']
        
        # Agenda próxima manutenção
        from datetime import datetime, timedelta
        next_maintenance = datetime.now() + timedelta(days=30)
        
        maintenance_data = {
            'next_maintenance_date': next_maintenance,
            'next_maintenance_km': 20000
        }
        
        success = vehicle_repo.update_maintenance(vehicle_id, maintenance_data)
        
        if success:
            print(f"✅ Manutenção agendada para veículo ID {vehicle_id}")
            vehicle_repo.session.commit()
            
            # Verifica veículos com manutenção próxima
            due_vehicles = vehicle_repo.get_maintenance_due(days_ahead=45)
            print(f"✅ Veículos com manutenção próxima: {len(due_vehicles)}")
            
            for vehicle in due_vehicles:
                print(f"   - {vehicle['plate']}: {vehicle.get('maintenance_urgency', 'normal')}")
        
        else:
            print(f"❌ Falha ao agendar manutenção")
            
    except Exception as e:
        print(f"❌ Erro no teste de manutenção: {e}")
        vehicle_repo.session.rollback()
    finally:
        vehicle_repo.session.close()

def main():
    """Executa todos os testes"""
    print("🚀 Iniciando testes do VehicleRepository...")
    
    # Testa criação
    vehicle_id = test_vehicle_creation()
    
    if vehicle_id:
        # Testa queries
        test_vehicle_queries()
        
        # Testa localização
        test_vehicle_location()
        
        # Testa manutenção
        test_vehicle_maintenance()
        
        print("\n✅ Todos os testes concluídos!")
    else:
        print("\n❌ Falha na criação do veículo - testes interrompidos")

if __name__ == '__main__':
    main()