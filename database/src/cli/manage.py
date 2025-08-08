#!/usr/bin/env python3
"""
Database Manager - AutoCore
Gerencia migrations, seeds e manutenção do banco de dados
"""
import os
import sys
import sqlite3
import argparse
from pathlib import Path
from datetime import datetime

# Adiciona shared ao path
sys.path.append(str(Path(__file__).parent.parent.parent))

from shared.connection import get_db, DB_PATH, init_database, get_db_size
from scripts.maintenance import DatabaseMaintenance

class DatabaseManager:
    """Gerenciador principal do banco de dados"""
    
    def __init__(self):
        self.db_path = DB_PATH
        self.migrations_dir = Path(__file__).parent.parent.parent / 'migrations'
        self.seeds_dir = Path(__file__).parent.parent.parent / 'seeds'
        self.schema_file = Path(__file__).parent.parent.parent / 'schema.sql'
        
    def init(self):
        """Inicializa o banco de dados do zero"""
        print("🚀 Inicializando banco de dados AutoCore...")
        
        # Remove banco existente se houver
        if os.path.exists(self.db_path):
            response = input(f"⚠️  Banco existente em {self.db_path}. Remover? (y/N): ")
            if response.lower() == 'y':
                os.remove(self.db_path)
                print("✅ Banco anterior removido")
            else:
                print("❌ Operação cancelada")
                return
        
        # Cria estrutura inicial
        init_database()
        
        # Aplica schema
        if self.schema_file.exists():
            self.apply_schema()
        
        # Aplica seeds
        self.seed()
        
        print("✅ Banco de dados inicializado com sucesso!")
        self.status()
    
    def apply_schema(self):
        """Aplica o schema.sql"""
        print("📋 Aplicando schema...")
        
        with open(self.schema_file, 'r') as f:
            schema = f.read()
        
        with get_db() as conn:
            conn.executescript(schema)
        
        print("✅ Schema aplicado")
    
    def migrate(self, direction='up'):
        """Executa migrations"""
        print(f"🔄 Executando migrations ({direction})...")
        
        # Cria tabela de controle de migrations
        with get_db() as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS schema_migrations (
                    version VARCHAR(255) PRIMARY KEY,
                    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
        
        # Lista migrations
        migration_files = sorted(self.migrations_dir.glob('*.sql'))
        
        with get_db() as conn:
            for migration_file in migration_files:
                version = migration_file.stem
                
                # Verifica se já foi aplicada
                applied = conn.execute(
                    "SELECT 1 FROM schema_migrations WHERE version = ?",
                    (version,)
                ).fetchone()
                
                if direction == 'up' and not applied:
                    print(f"  ↑ Aplicando {version}...")
                    
                    with open(migration_file, 'r') as f:
                        conn.executescript(f.read())
                    
                    conn.execute(
                        "INSERT INTO schema_migrations (version) VALUES (?)",
                        (version,)
                    )
                    print(f"  ✅ {version} aplicada")
                    
                elif direction == 'down' and applied:
                    # TODO: Implementar rollback
                    print(f"  ↓ Rollback {version} não implementado")
        
        print("✅ Migrations concluídas")
    
    def seed(self, specific=None):
        """Aplica seeds (dados iniciais)"""
        print("🌱 Aplicando seeds...")
        
        seed_files = sorted(self.seeds_dir.glob('*.sql'))
        
        if specific:
            seed_files = [f for f in seed_files if specific in f.name]
        
        with get_db() as conn:
            for seed_file in seed_files:
                print(f"  🌱 Aplicando {seed_file.name}...")
                
                with open(seed_file, 'r') as f:
                    try:
                        conn.executescript(f.read())
                        print(f"  ✅ {seed_file.name} aplicado")
                    except sqlite3.IntegrityError as e:
                        print(f"  ⚠️  {seed_file.name} já aplicado ou erro: {e}")
        
        print("✅ Seeds aplicados")
    
    def status(self):
        """Mostra status do banco"""
        print("\n📊 Status do Banco de Dados")
        print("=" * 40)
        
        # Tamanho
        size_info = get_db_size()
        print(f"📁 Arquivo: {size_info['path']}")
        print(f"💾 Tamanho: {size_info['total_size_mb']} MB")
        
        # Tabelas e registros
        with get_db() as conn:
            tables = conn.execute("""
                SELECT name FROM sqlite_master 
                WHERE type='table' AND name NOT LIKE 'sqlite_%'
                ORDER BY name
            """).fetchall()
            
            print(f"\n📋 Tabelas ({len(tables)}):")
            for table in tables:
                count = conn.execute(f"SELECT COUNT(*) FROM {table['name']}").fetchone()[0]
                print(f"  • {table['name']}: {count} registros")
            
            # Migrations aplicadas
            try:
                migrations = conn.execute("""
                    SELECT version, applied_at FROM schema_migrations 
                    ORDER BY applied_at DESC LIMIT 5
                """).fetchall()
                
                if migrations:
                    print(f"\n🔄 Últimas migrations:")
                    for m in migrations:
                        print(f"  • {m['version']} ({m['applied_at']})")
            except:
                print("\n⚠️  Tabela de migrations não existe")
    
    def backup(self, output_dir=None):
        """Cria backup do banco"""
        if not output_dir:
            output_dir = Path.home() / 'backups'
        
        output_dir = Path(output_dir)
        output_dir.mkdir(exist_ok=True)
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_file = output_dir / f"autocore_backup_{timestamp}.db"
        
        print(f"💾 Criando backup em {backup_file}...")
        
        with get_db() as conn:
            # Backup usando SQL
            conn.execute(f"VACUUM INTO '{backup_file}'")
        
        # Compacta
        import gzip
        with open(backup_file, 'rb') as f_in:
            with gzip.open(f"{backup_file}.gz", 'wb') as f_out:
                f_out.writelines(f_in)
        
        os.remove(backup_file)
        print(f"✅ Backup criado: {backup_file}.gz")
        
        # Tamanho
        size = os.path.getsize(f"{backup_file}.gz") / 1024 / 1024
        print(f"📦 Tamanho: {size:.2f} MB")
    
    def restore(self, backup_file):
        """Restaura backup"""
        backup_path = Path(backup_file)
        
        if not backup_path.exists():
            print(f"❌ Arquivo não encontrado: {backup_file}")
            return
        
        print(f"⚠️  ATENÇÃO: Isso irá sobrescrever o banco atual!")
        response = input("Continuar? (y/N): ")
        
        if response.lower() != 'y':
            print("❌ Operação cancelada")
            return
        
        print(f"📥 Restaurando de {backup_file}...")
        
        # Descompacta se necessário
        if backup_file.endswith('.gz'):
            import gzip
            import tempfile
            
            with tempfile.NamedTemporaryFile(delete=False) as tmp:
                with gzip.open(backup_file, 'rb') as f_in:
                    tmp.write(f_in.read())
                backup_file = tmp.name
        
        # Substitui banco atual
        import shutil
        shutil.copy2(backup_file, self.db_path)
        
        print("✅ Backup restaurado com sucesso!")
        self.status()
    
    def clean(self, days=7):
        """Executa limpeza de dados antigos"""
        maintenance = DatabaseMaintenance()
        maintenance.full_maintenance(telemetry_days=days, log_days=days*4)
    
    def console(self):
        """Abre console SQL interativo"""
        print("🔍 Console SQLite - Digite .exit para sair")
        os.system(f"sqlite3 {self.db_path}")

def main():
    parser = argparse.ArgumentParser(
        description='Gerenciador de Banco de Dados AutoCore',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos:
  python manage.py init              # Inicializa banco do zero
  python manage.py migrate           # Aplica migrations pendentes
  python manage.py seed              # Aplica seeds
  python manage.py status            # Mostra status do banco
  python manage.py backup            # Cria backup
  python manage.py clean             # Limpa dados antigos
  python manage.py console           # Console SQL interativo
        """
    )
    
    parser.add_argument('command', 
        choices=['init', 'migrate', 'seed', 'status', 'backup', 
                'restore', 'clean', 'console'],
        help='Comando a executar'
    )
    
    parser.add_argument('--file', '-f', help='Arquivo para restore')
    parser.add_argument('--days', '-d', type=int, default=7, 
                       help='Dias para manter na limpeza')
    parser.add_argument('--output', '-o', help='Diretório para backup')
    
    args = parser.parse_args()
    
    manager = DatabaseManager()
    
    if args.command == 'init':
        manager.init()
    elif args.command == 'migrate':
        manager.migrate()
    elif args.command == 'seed':
        manager.seed()
    elif args.command == 'status':
        manager.status()
    elif args.command == 'backup':
        manager.backup(args.output)
    elif args.command == 'restore':
        if not args.file:
            print("❌ Use --file para especificar o arquivo de backup")
        else:
            manager.restore(args.file)
    elif args.command == 'clean':
        manager.clean(args.days)
    elif args.command == 'console':
        manager.console()

if __name__ == '__main__':
    main()