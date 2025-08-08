#!/usr/bin/env python3
"""
Auto-migration usando SQLAlchemy + Alembic
Detecta mudanças nos models e gera migrations automaticamente
"""
import os
import sys
import subprocess
from datetime import datetime
from pathlib import Path

# Adiciona ao path
sys.path.append(str(Path(__file__).parent.parent.parent))

from src.models import Base, get_engine, create_all_tables
from src.migrations.alembic_setup import setup_alembic

class AutoMigration:
    """Gerencia migrations automáticas baseadas nos models"""
    
    def __init__(self):
        self.db_path = 'autocore.db'
        self.models_checksum = None
        
    def init_alembic(self):
        """Inicializa Alembic se necessário"""
        alembic_dir = Path(__file__).parent / 'alembic'
        if not alembic_dir.exists():
            print("🔧 Configurando Alembic...")
            setup_alembic()
            
            # Inicializa Alembic usando python -m
            result = subprocess.run(
                ['python3', '-m', 'alembic', 'init', 'alembic'],
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0 and 'already exists' not in result.stderr:
                print(f"❌ Erro ao inicializar Alembic: {result.stderr}")
                return False
                
        return True
    
    def check_models_changed(self):
        """Verifica se os models mudaram"""
        # TODO: Implementar checksum dos models
        # Por enquanto, sempre retorna True para forçar verificação
        return True
    
    def generate_migration(self, message=None):
        """Gera migration automática baseada nos models"""
        if not message:
            message = f"Auto migration {datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        print(f"🔄 Gerando migration: {message}")
        
        # Garante que Alembic está configurado
        if not self.init_alembic():
            return False
        
        # Gera migration automática
        result = subprocess.run(
            ['python3', '-m', 'alembic', 'revision', '--autogenerate', '-m', message],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            print(f"❌ Erro ao gerar migration: {result.stderr}")
            return False
        
        # Extrai nome do arquivo criado
        for line in result.stdout.split('\n'):
            if 'Generating' in line:
                print(f"✅ {line.strip()}")
                
        return True
    
    def apply_migrations(self):
        """Aplica todas as migrations pendentes"""
        print("📦 Aplicando migrations...")
        
        result = subprocess.run(
            ['python3', '-m', 'alembic', 'upgrade', 'head'],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            print(f"❌ Erro ao aplicar migrations: {result.stderr}")
            return False
        
        print(result.stdout)
        print("✅ Migrations aplicadas com sucesso!")
        return True
    
    def rollback(self, steps=1):
        """Desfaz migrations"""
        print(f"↩️  Desfazendo {steps} migration(s)...")
        
        result = subprocess.run(
            ['python3', '-m', 'alembic', 'downgrade', f'-{steps}'],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            print(f"❌ Erro ao desfazer: {result.stderr}")
            return False
        
        print("✅ Rollback executado!")
        return True
    
    def get_current_revision(self):
        """Mostra revisão atual"""
        result = subprocess.run(
            ['python3', '-m', 'alembic', 'current'],
            capture_output=True,
            text=True
        )
        
        return result.stdout.strip()
    
    def get_history(self):
        """Mostra histórico de migrations"""
        result = subprocess.run(
            ['python3', '-m', 'alembic', 'history'],
            capture_output=True,
            text=True
        )
        
        return result.stdout
    
    def sync_database(self):
        """Sincroniza banco com os models (modo desenvolvimento)"""
        print("🔄 Sincronizando banco com models...")
        
        # Para desenvolvimento, podemos usar create_all direto
        engine = create_all_tables()
        
        print("✅ Banco sincronizado com models!")
        print("\n⚠️  ATENÇÃO: Em produção, use migrations!")
        
        # Lista tabelas criadas
        from sqlalchemy import inspect
        inspector = inspect(engine)
        tables = inspector.get_table_names()
        print(f"\n📋 Tabelas no banco ({len(tables)}):")
        for table in sorted(tables):
            print(f"  • {table}")
    
    def auto_migrate(self, message=None):
        """Processo completo de auto-migration"""
        print("🚀 Auto-migration iniciada...")
        
        # 1. Verifica se models mudaram
        if not self.check_models_changed():
            print("ℹ️  Nenhuma mudança detectada nos models")
            return True
        
        # 2. Gera migration
        if not self.generate_migration(message):
            return False
        
        # 3. Pergunta se quer aplicar
        response = input("\n🤔 Aplicar migration agora? (y/N): ")
        if response.lower() == 'y':
            return self.apply_migrations()
        
        print("ℹ️  Migration gerada mas não aplicada")
        print("   Use: alembic upgrade head")
        return True

def main():
    """CLI para auto-migration"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='Auto-migration para AutoCore Database',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos:
  python auto_migrate.py sync              # Sincroniza banco com models (dev)
  python auto_migrate.py generate          # Gera migration automática
  python auto_migrate.py apply             # Aplica migrations pendentes
  python auto_migrate.py auto              # Gera e aplica automaticamente
  python auto_migrate.py rollback          # Desfaz última migration
  python auto_migrate.py history           # Ver histórico
        """
    )
    
    parser.add_argument('command',
        choices=['sync', 'generate', 'apply', 'auto', 'rollback', 'history', 'current'],
        help='Comando a executar'
    )
    
    parser.add_argument('-m', '--message',
        help='Mensagem para a migration'
    )
    
    parser.add_argument('-s', '--steps',
        type=int,
        default=1,
        help='Número de steps para rollback'
    )
    
    args = parser.parse_args()
    
    migrator = AutoMigration()
    
    if args.command == 'sync':
        migrator.sync_database()
        
    elif args.command == 'generate':
        migrator.generate_migration(args.message)
        
    elif args.command == 'apply':
        migrator.apply_migrations()
        
    elif args.command == 'auto':
        migrator.auto_migrate(args.message)
        
    elif args.command == 'rollback':
        migrator.rollback(args.steps)
        
    elif args.command == 'history':
        print(migrator.get_history())
        
    elif args.command == 'current':
        print(f"Revisão atual: {migrator.get_current_revision()}")

if __name__ == '__main__':
    main()