"""Adjust vehicles for single record constraint

Revision ID: cdc207c0d60f
Revises: 8cb7e8483fa4
Create Date: 2025-08-28 17:35:26.584034

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'cdc207c0d60f'
down_revision = '8cb7e8483fa4'
branch_labels = None
depends_on = None

def upgrade() -> None:
    # ### AUTO-GENERATED - Field length adjustments ###
    op.alter_column('devices', 'type',
               existing_type=sa.VARCHAR(length=19),
               type_=sa.String(length=50),
               existing_nullable=False)
    op.alter_column('devices', 'status',
               existing_type=sa.VARCHAR(length=11),
               type_=sa.String(length=20),
               existing_nullable=False)
    op.alter_column('relay_channels', 'function_type',
               existing_type=sa.VARCHAR(length=9),
               type_=sa.String(length=20),
               existing_nullable=True)
    op.alter_column('relay_channels', 'protection_mode',
               existing_type=sa.VARCHAR(length=8),
               type_=sa.String(length=20),
               existing_nullable=False)
    op.alter_column('screen_items', 'item_type',
               existing_type=sa.VARCHAR(length=7),
               type_=sa.String(length=20),
               existing_nullable=False)
    op.alter_column('screen_items', 'action_type',
               existing_type=sa.VARCHAR(length=13),
               type_=sa.String(length=30),
               existing_nullable=True)
    
    # ### CUSTOM - VEHICLE SINGLE RECORD ADJUSTMENT ###
    
    print("🚗 Ajustando tabela vehicles para registro único...")
    
    # 1. Verificar se existem registros na tabela vehicles
    connection = op.get_bind()
    result = connection.execute(sa.text("SELECT COUNT(*) FROM vehicles"))
    vehicle_count = result.scalar()
    
    if vehicle_count > 1:
        print(f"⚠️  Encontrados {vehicle_count} veículos. Mantendo apenas o mais recente...")
        
        # Manter apenas o registro mais recente (maior ID ou created_at)
        connection.execute(sa.text("""
            DELETE FROM vehicles 
            WHERE id NOT IN (
                SELECT id FROM (
                    SELECT id FROM vehicles 
                    ORDER BY created_at DESC, id DESC 
                    LIMIT 1
                ) AS keeper
            )
        """))
        
        print("✅ Registros extras removidos.")
    
    # 2. Garantir que o registro restante tem ID = 1
    if vehicle_count > 0:
        print("🔧 Ajustando ID do veículo para 1...")
        
        # Se existe registro, forçar ID = 1
        connection.execute(sa.text("UPDATE vehicles SET id = 1 WHERE id != 1"))
        
        # Resetar sequence/autoincrement (SQLite não tem, mas fica para documentar)
        # connection.execute(sa.text("UPDATE sqlite_sequence SET seq = 1 WHERE name = 'vehicles'"))
    
    # 3. Adicionar constraint para garantir apenas ID = 1
    print("🛡️  Adicionando constraint de registro único...")
    
    try:
        op.create_check_constraint(
            'check_single_vehicle_record',
            'vehicles',
            'id = 1'
        )
        print("✅ Constraint check_single_vehicle_record adicionada.")
    except Exception as e:
        print(f"⚠️  Constraint não foi adicionada (pode já existir): {e}")
    
    print("🏁 Ajuste de registro único finalizado!")
    print("   • Sistema agora suporta apenas 1 veículo (ID = 1)")
    print("   • Use VehicleRepository.create_or_update_vehicle() para gerenciar")

def downgrade() -> None:
    # ### CUSTOM - ROLLBACK VEHICLE SINGLE RECORD ADJUSTMENT ###
    
    print("🔄 Removendo constraint de registro único...")
    
    try:
        op.drop_constraint('check_single_vehicle_record', 'vehicles')
        print("✅ Constraint check_single_vehicle_record removida.")
    except Exception as e:
        print(f"⚠️  Constraint não foi removida (pode não existir): {e}")
    
    print("🏁 Rollback de registro único finalizado!")
    print("   • Sistema volta a permitir múltiplos veículos")
    print("   • Use VehicleRepository.create_vehicle() normalmente")
    
    # ### AUTO-GENERATED - Field length rollback ###
    op.alter_column('screen_items', 'action_type',
               existing_type=sa.String(length=30),
               type_=sa.VARCHAR(length=13),
               existing_nullable=True)
    op.alter_column('screen_items', 'item_type',
               existing_type=sa.String(length=20),
               type_=sa.VARCHAR(length=7),
               existing_nullable=False)
    op.alter_column('relay_channels', 'protection_mode',
               existing_type=sa.String(length=20),
               type_=sa.VARCHAR(length=8),
               existing_nullable=False)
    op.alter_column('relay_channels', 'function_type',
               existing_type=sa.String(length=20),
               type_=sa.VARCHAR(length=9),
               existing_nullable=True)
    op.alter_column('devices', 'status',
               existing_type=sa.String(length=20),
               type_=sa.VARCHAR(length=11),
               existing_nullable=False)
    op.alter_column('devices', 'type',
               existing_type=sa.String(length=50),
               type_=sa.VARCHAR(length=19),
               existing_nullable=False)
