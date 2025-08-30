#!/usr/bin/env python3
"""
Script direto para aplicar constraint de registro único na tabela vehicles
Contorna limitações do Alembic com SQLite para ALTER COLUMN
"""
import sys
import sqlite3
from pathlib import Path
from datetime import datetime

# Adiciona ao path
sys.path.append(str(Path(__file__).parent.parent.parent))

from src.models.models import get_engine, get_session, Vehicle

class VehicleSingleRecordMigration:
    """Aplica constraint de registro único diretamente no SQLite"""
    
    def __init__(self):
        self.db_path = Path(__file__).parent.parent.parent / 'autocore.db'
        
    def apply_migration(self):
        """Aplica a migration de registro único"""
        print("🚗 Aplicando migration: Vehicle Single Record Constraint")
        print("="*60)
        
        try:
            # Conecta ao banco
            engine = get_engine(str(self.db_path))
            session = get_session(engine)
            
            # 1. Verificar registros existentes
            print("1. Verificando registros existentes...")
            vehicles = session.query(Vehicle).all()
            vehicle_count = len(vehicles)
            
            print(f"   • Encontrados {vehicle_count} veículos")
            
            if vehicle_count > 1:
                print("2. Limpando registros extras...")
                # Manter apenas o mais recente
                latest_vehicle = session.query(Vehicle).order_by(
                    Vehicle.created_at.desc(), 
                    Vehicle.id.desc()
                ).first()
                
                if latest_vehicle:
                    print(f"   • Mantendo veículo ID {latest_vehicle.id}: {latest_vehicle.plate}")
                    
                    # Remove outros registros
                    session.query(Vehicle).filter(
                        Vehicle.id != latest_vehicle.id
                    ).delete()
                    
                    # Forçar ID = 1 no registro mantido
                    session.execute(
                        f"UPDATE vehicles SET id = 1 WHERE id = {latest_vehicle.id}"
                    )
                    
                    print(f"   • {vehicle_count - 1} registros removidos")
                    print("   • ID do veículo ajustado para 1")
                
            elif vehicle_count == 1:
                print("2. Ajustando ID do veículo único...")
                vehicle = vehicles[0]
                if vehicle.id != 1:
                    session.execute(f"UPDATE vehicles SET id = 1 WHERE id = {vehicle.id}")
                    print("   • ID ajustado para 1")
                else:
                    print("   • ID já é 1, nenhum ajuste necessário")
            
            elif vehicle_count == 0:
                print("2. Nenhum veículo encontrado")
                print("   • Constraint será aplicada quando o primeiro veículo for criado")
            
            # 3. Aplicar constraint usando SQL direto
            print("3. Aplicando constraint de registro único...")
            
            try:
                # Usa conexão SQLite direta para aplicar constraint
                conn = sqlite3.connect(str(self.db_path))
                cursor = conn.cursor()
                
                # Verifica se constraint já existe
                cursor.execute("""
                    SELECT sql FROM sqlite_master 
                    WHERE type='table' AND name='vehicles'
                """)
                
                table_sql = cursor.fetchone()[0]
                
                if 'check_single_vehicle_record' not in table_sql:
                    print("   • Recriando tabela com constraint...")
                    
                    # Como SQLite não suporta ADD CONSTRAINT para CHECK,
                    # vamos fazer backup dos dados e recriar a tabela
                    
                    # 1. Backup dos dados
                    cursor.execute("SELECT * FROM vehicles")
                    vehicle_data = cursor.fetchall()
                    
                    # 2. Renomear tabela original
                    cursor.execute("ALTER TABLE vehicles RENAME TO vehicles_backup")
                    
                    # 3. Recriar tabela com constraint (usando definição do modelo)
                    cursor.execute("""
                    CREATE TABLE vehicles (
                        id INTEGER NOT NULL, 
                        uuid VARCHAR(36) NOT NULL, 
                        plate VARCHAR(10) NOT NULL, 
                        chassis VARCHAR(30) NOT NULL, 
                        renavam VARCHAR(20) NOT NULL, 
                        brand VARCHAR(50) NOT NULL, 
                        model VARCHAR(100) NOT NULL, 
                        version VARCHAR(100), 
                        year_manufacture INTEGER NOT NULL, 
                        year_model INTEGER NOT NULL, 
                        color VARCHAR(30), 
                        color_code VARCHAR(10), 
                        fuel_type VARCHAR(20) NOT NULL, 
                        engine_capacity INTEGER, 
                        engine_power INTEGER, 
                        engine_torque INTEGER, 
                        transmission VARCHAR(20), 
                        category VARCHAR(30) NOT NULL, 
                        usage_type VARCHAR(30), 
                        user_id INTEGER NOT NULL, 
                        primary_device_id INTEGER, 
                        status VARCHAR(20) NOT NULL, 
                        odometer INTEGER NOT NULL, 
                        odometer_unit VARCHAR(5) NOT NULL, 
                        last_location TEXT, 
                        next_maintenance_date DATETIME, 
                        next_maintenance_km INTEGER, 
                        last_maintenance_date DATETIME, 
                        last_maintenance_km INTEGER, 
                        insurance_expiry DATETIME, 
                        license_expiry DATETIME, 
                        inspection_expiry DATETIME, 
                        vehicle_config TEXT, 
                        notes TEXT, 
                        tags TEXT, 
                        is_active BOOLEAN NOT NULL, 
                        is_tracked BOOLEAN NOT NULL, 
                        created_at DATETIME NOT NULL, 
                        updated_at DATETIME NOT NULL, 
                        deleted_at DATETIME, 
                        PRIMARY KEY (id), 
                        UNIQUE (uuid), 
                        UNIQUE (plate), 
                        UNIQUE (chassis), 
                        UNIQUE (renavam), 
                        CHECK (id = 1), 
                        CHECK (fuel_type IN ('flex', 'gasoline', 'ethanol', 'diesel', 'electric', 'hybrid')), 
                        CHECK (category IN ('passenger', 'commercial', 'motorcycle', 'truck', 'bus')), 
                        CHECK (status IN ('active', 'inactive', 'maintenance', 'retired', 'sold')), 
                        CHECK (year_manufacture >= 1900 AND year_manufacture <= 2030), 
                        CHECK (year_model >= year_manufacture AND year_model <= (year_manufacture + 1)), 
                        CHECK (odometer >= 0), 
                        CHECK (length(plate) >= 7 AND length(plate) <= 8), 
                        CHECK (length(chassis) >= 17), 
                        FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
                        FOREIGN KEY(primary_device_id) REFERENCES devices (id) ON DELETE SET NULL
                    )
                    """)
                    
                    # 4. Restaurar dados (se existirem)
                    if vehicle_data:
                        # Forçar ID = 1 para o primeiro (e único) registro
                        placeholders = ','.join(['?' for _ in range(len(vehicle_data[0]))])
                        
                        for i, row in enumerate(vehicle_data[:1]):  # Apenas primeiro registro
                            row_list = list(row)
                            row_list[0] = 1  # ID = 1
                            cursor.execute(f"INSERT INTO vehicles VALUES ({placeholders})", row_list)
                    
                    # 5. Remover backup
                    cursor.execute("DROP TABLE vehicles_backup")
                    
                    conn.commit()
                    print("   • Constraint CHECK (id = 1) aplicada com sucesso")
                    
                else:
                    print("   • Constraint já existe na tabela")
                
                conn.close()
                
            except Exception as e:
                print(f"   ❌ Erro ao aplicar constraint: {e}")
                return False
            
            # Commit das mudanças do SQLAlchemy
            session.commit()
            session.close()
            
            print("4. Validando resultado...")
            
            # Reabrir sessão para validação
            session = get_session(engine)
            vehicles = session.query(Vehicle).all()
            
            if len(vehicles) <= 1:
                if len(vehicles) == 1:
                    vehicle = vehicles[0]
                    print(f"   ✅ Encontrado 1 veículo único (ID: {vehicle.id}, Placa: {vehicle.plate})")
                else:
                    print("   ✅ Nenhum veículo (constraint aplicada para próximo registro)")
                print("   ✅ Sistema configurado para registro único")
            else:
                print(f"   ❌ ERRO: Ainda existem {len(vehicles)} veículos!")
                return False
            
            session.close()
            
            print("="*60)
            print("🎉 Migration aplicada com sucesso!")
            print("🔧 Sistema agora suporta apenas 1 veículo (ID = 1)")
            print("📚 Use VehicleRepository.create_or_update_vehicle() para gerenciar")
            
            return True
            
        except Exception as e:
            print(f"❌ ERRO na migration: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    def rollback_migration(self):
        """Remove a constraint de registro único"""
        print("🔄 Rollback: Removendo constraint de registro único")
        print("="*50)
        
        try:
            conn = sqlite3.connect(str(self.db_path))
            cursor = conn.cursor()
            
            # Backup dos dados
            cursor.execute("SELECT * FROM vehicles")
            vehicle_data = cursor.fetchall()
            
            # Renomear tabela
            cursor.execute("ALTER TABLE vehicles RENAME TO vehicles_backup")
            
            # Recriar sem constraint
            cursor.execute("""
            CREATE TABLE vehicles (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
                uuid VARCHAR(36) NOT NULL, 
                plate VARCHAR(10) NOT NULL, 
                chassis VARCHAR(30) NOT NULL, 
                renavam VARCHAR(20) NOT NULL, 
                brand VARCHAR(50) NOT NULL, 
                model VARCHAR(100) NOT NULL, 
                version VARCHAR(100), 
                year_manufacture INTEGER NOT NULL, 
                year_model INTEGER NOT NULL, 
                color VARCHAR(30), 
                color_code VARCHAR(10), 
                fuel_type VARCHAR(20) NOT NULL, 
                engine_capacity INTEGER, 
                engine_power INTEGER, 
                engine_torque INTEGER, 
                transmission VARCHAR(20), 
                category VARCHAR(30) NOT NULL, 
                usage_type VARCHAR(30), 
                user_id INTEGER NOT NULL, 
                primary_device_id INTEGER, 
                status VARCHAR(20) NOT NULL, 
                odometer INTEGER NOT NULL, 
                odometer_unit VARCHAR(5) NOT NULL, 
                last_location TEXT, 
                next_maintenance_date DATETIME, 
                next_maintenance_km INTEGER, 
                last_maintenance_date DATETIME, 
                last_maintenance_km INTEGER, 
                insurance_expiry DATETIME, 
                license_expiry DATETIME, 
                inspection_expiry DATETIME, 
                vehicle_config TEXT, 
                notes TEXT, 
                tags TEXT, 
                is_active BOOLEAN NOT NULL, 
                is_tracked BOOLEAN NOT NULL, 
                created_at DATETIME NOT NULL, 
                updated_at DATETIME NOT NULL, 
                deleted_at DATETIME, 
                UNIQUE (uuid), 
                UNIQUE (plate), 
                UNIQUE (chassis), 
                UNIQUE (renavam), 
                CHECK (fuel_type IN ('flex', 'gasoline', 'ethanol', 'diesel', 'electric', 'hybrid')), 
                CHECK (category IN ('passenger', 'commercial', 'motorcycle', 'truck', 'bus')), 
                CHECK (status IN ('active', 'inactive', 'maintenance', 'retired', 'sold')), 
                CHECK (year_manufacture >= 1900 AND year_manufacture <= 2030), 
                CHECK (year_model >= year_manufacture AND year_model <= (year_manufacture + 1)), 
                CHECK (odometer >= 0), 
                CHECK (length(plate) >= 7 AND length(plate) <= 8), 
                CHECK (length(chassis) >= 17), 
                FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
                FOREIGN KEY(primary_device_id) REFERENCES devices (id) ON DELETE SET NULL
            )
            """)
            
            # Restaurar dados
            if vehicle_data:
                placeholders = ','.join(['?' for _ in range(len(vehicle_data[0]))])
                for row in vehicle_data:
                    cursor.execute(f"INSERT INTO vehicles VALUES ({placeholders})", row)
            
            # Remover backup
            cursor.execute("DROP TABLE vehicles_backup")
            
            conn.commit()
            conn.close()
            
            print("✅ Constraint de registro único removida")
            print("📚 Sistema volta a permitir múltiplos veículos")
            
            return True
            
        except Exception as e:
            print(f"❌ ERRO no rollback: {e}")
            return False

def main():
    """CLI para aplicar/remover migration"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Vehicle Single Record Migration')
    parser.add_argument('action', choices=['apply', 'rollback'], 
                       help='Ação a executar')
    
    args = parser.parse_args()
    
    migrator = VehicleSingleRecordMigration()
    
    if args.action == 'apply':
        success = migrator.apply_migration()
    else:
        success = migrator.rollback_migration()
    
    exit(0 if success else 1)

if __name__ == '__main__':
    main()