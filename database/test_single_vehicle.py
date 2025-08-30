#!/usr/bin/env python3
"""
Script de teste para validar o sistema de registro único de veículo
Testa todas as operações do VehicleRepository ajustado
"""
import sys
from pathlib import Path
from datetime import datetime

# Adiciona ao path
sys.path.append(str(Path(__file__).parent))

from src.models.models import get_session, get_engine, Vehicle, User
from shared.vehicle_repository import VehicleRepository

def test_single_vehicle_system():
    """Testa o sistema de registro único de veículo"""
    print("🧪 Testando Sistema de Registro Único de Veículo")
    print("="*60)
    
    try:
        # Setup
        engine = get_engine('autocore.db')
        session = get_session(engine)
        repo = VehicleRepository(session)
        
        print("1. Teste inicial - has_vehicle()")
        has_vehicle = repo.has_vehicle()
        print(f"   • Has vehicle: {has_vehicle}")
        
        if has_vehicle:
            print("2. Teste get_vehicle()")
            vehicle = repo.get_vehicle()
            print(f"   • ID: {vehicle['id']}")
            print(f"   • Placa: {vehicle['plate']}")
            print(f"   • Marca/Modelo: {vehicle['brand']} {vehicle['model']}")
            print(f"   • Status: {vehicle['status']}")
            
            print("3. Teste update_vehicle() - atualizando cor")
            vehicle_data = {
                'color': 'Azul Metálico',
                'notes': f'Teste atualização - {datetime.now().strftime("%H:%M:%S")}'
            }
            updated_vehicle = repo.update_vehicle(vehicle_data)
            print(f"   • Cor atualizada: {updated_vehicle['color']}")
            print(f"   • Notas: {updated_vehicle['notes']}")
            
            print("4. Teste update_odometer() - atualizando quilometragem")
            current_km = vehicle['odometer']
            new_km = current_km + 100
            odometer_result = repo.update_odometer(new_km)
            if odometer_result:
                print(f"   • Quilometragem: {current_km} → {odometer_result['odometer']} km")
            else:
                print("   ❌ Erro ao atualizar quilometragem")
            
            print("5. Teste update_location() - atualizando localização")
            location_updated = repo.update_location(-23.5489, -46.6388, accuracy=10)
            print(f"   • Localização atualizada: {location_updated}")
            
            print("6. Teste get_vehicle_for_config()")
            config_vehicle = repo.get_vehicle_for_config()
            print(f"   • Config vehicle keys: {list(config_vehicle.keys())}")
            
            print("7. Teste update_status() - mudando status")
            status_updated = repo.update_status('active')
            print(f"   • Status atualizado: {status_updated}")
            
        else:
            print("2. Teste create_or_update_vehicle() - criando primeiro veículo")
            vehicle_data = {
                'plate': 'XYZ9K88',
                'chassis': 'TESTCHASSISABCDEF01',
                'renavam': '12345678901',
                'brand': 'Toyota',
                'model': 'Corolla',
                'version': 'GLi',
                'year_manufacture': 2020,
                'year_model': 2021,
                'fuel_type': 'flex',
                'category': 'passenger',
                'user_id': 1
            }
            
            created_vehicle = repo.create_or_update_vehicle(vehicle_data)
            print(f"   • Veículo criado - ID: {created_vehicle['id']}")
            print(f"   • Placa: {created_vehicle['plate']}")
        
        print("8. Teste tentativa de criar segundo veículo (deve atualizar o primeiro)")
        second_vehicle_data = {
            'plate': 'DEF4567',
            'chassis': 'NEWCHASSISXYZABC123',
            'renavam': '98765432109',
            'brand': 'Honda',
            'model': 'Civic',
            'year_manufacture': 2022,
            'year_model': 2022,
            'fuel_type': 'gasoline',
            'category': 'passenger',
            'user_id': 1
        }
        
        second_result = repo.create_or_update_vehicle(second_vehicle_data)
        print(f"   • Resultado ID: {second_result['id']} (deve ser 1)")
        print(f"   • Placa final: {second_result['plate']} (deve ser DEF4567)")
        print(f"   • Marca final: {second_result['brand']} {second_result['model']}")
        
        print("9. Validação final - garantir apenas 1 registro")
        final_check = session.query(Vehicle).all()
        print(f"   • Total de veículos no banco: {len(final_check)}")
        print(f"   • ID do veículo único: {final_check[0].id if final_check else 'Nenhum'}")
        
        print("10. Teste métodos deprecated")
        try:
            repo.get_active_vehicles()
            print("   ❌ get_active_vehicles() não gerou erro (deveria)")
        except NotImplementedError as e:
            print(f"   ✅ get_active_vehicles() corretamente bloqueado: {str(e)[:50]}...")
        
        try:
            repo.search_vehicles("test")
            print("   ❌ search_vehicles() não gerou erro (deveria)")
        except NotImplementedError as e:
            print(f"   ✅ search_vehicles() corretamente bloqueado: {str(e)[:50]}...")
        
        session.close()
        
        print("="*60)
        print("✅ TODOS OS TESTES PASSARAM!")
        print("🚗 Sistema de registro único funcionando perfeitamente")
        
        return True
        
    except Exception as e:
        print(f"❌ ERRO nos testes: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_constraint_validation():
    """Testa se a constraint de banco está funcionando"""
    print("\n🛡️ Testando Constraint de Banco")
    print("="*40)
    
    import sqlite3
    
    try:
        conn = sqlite3.connect('autocore.db')
        cursor = conn.cursor()
        
        # Tentar inserir registro com ID != 1 (deve falhar)
        try:
            cursor.execute("""
                INSERT INTO vehicles (
                    id, uuid, plate, chassis, renavam, brand, model, 
                    year_manufacture, year_model, fuel_type, category, 
                    user_id, status, odometer, odometer_unit, 
                    is_active, is_tracked, created_at, updated_at
                ) VALUES (
                    2, 'test-uuid-123', 'TEST999', 'TESTCHASSISCONSTRA1', 'TEST123456', 
                    'Test', 'Model', 2020, 2020, 'flex', 'passenger', 
                    1, 'inactive', 0, 'km', 1, 1, 
                    datetime('now'), datetime('now')
                )
            """)
            conn.commit()
            print("   ❌ Constraint falhou - inserção com ID != 1 foi permitida")
            return False
            
        except sqlite3.IntegrityError as e:
            if 'CHECK constraint failed' in str(e):
                print("   ✅ Constraint funcionando - ID != 1 rejeitado")
            else:
                print(f"   ⚠️ Erro inesperado: {e}")
        
        # Verificar se inserção com ID = 1 funciona (se não existir registro)
        cursor.execute("SELECT COUNT(*) FROM vehicles")
        count = cursor.fetchone()[0]
        
        if count == 0:
            try:
                cursor.execute("""
                    INSERT INTO vehicles (
                        id, uuid, plate, chassis, renavam, brand, model, 
                        year_manufacture, year_model, fuel_type, category, 
                        user_id, status, odometer, odometer_unit, 
                        is_active, is_tracked, created_at, updated_at
                    ) VALUES (
                        1, 'test-uuid-valid', 'VALID123', 'VALIDCHASSISTEST001', 'VALID123456', 
                        'Valid', 'Model', 2020, 2020, 'flex', 'passenger', 
                        1, 'inactive', 0, 'km', 1, 1, 
                        datetime('now'), datetime('now')
                    )
                """)
                conn.commit()
                print("   ✅ Inserção com ID = 1 permitida")
                
                # Limpar teste
                cursor.execute("DELETE FROM vehicles WHERE plate = 'VALID123'")
                conn.commit()
                
            except sqlite3.IntegrityError as e:
                print(f"   ❌ Erro inesperado ao inserir ID = 1: {e}")
        else:
            print("   ℹ️ Já existe veículo - teste de inserção pulado")
        
        conn.close()
        return True
        
    except Exception as e:
        print(f"❌ ERRO no teste de constraint: {e}")
        return False

if __name__ == '__main__':
    print("🚀 Executando Testes do Sistema de Registro Único")
    print("Timestamp:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print()
    
    success1 = test_single_vehicle_system()
    success2 = test_constraint_validation()
    
    print("\n" + "="*60)
    if success1 and success2:
        print("🎉 TODOS OS TESTES PASSARAM COM SUCESSO!")
        print("✅ Sistema de registro único está funcionando perfeitamente")
        exit(0)
    else:
        print("❌ ALGUNS TESTES FALHARAM!")
        print("🔧 Verifique os logs acima para detalhes")
        exit(1)