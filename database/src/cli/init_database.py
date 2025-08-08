#!/usr/bin/env python3
"""
Script de inicialização do database AutoCore usando SQLAlchemy ORM
Cria tabelas e aplica seeds de desenvolvimento
"""
import os
import sys
from pathlib import Path
from datetime import datetime
from tabulate import tabulate
import click

# Adiciona paths necessários
sys.path.append(str(Path(__file__).parent.parent.parent))

from src.models import create_all_tables, get_engine
from sqlalchemy import inspect, text

@click.command()
@click.option('--reset', is_flag=True, help='Remove banco existente antes de criar')
@click.option('--seeds', is_flag=True, default=True, help='Aplicar seeds de desenvolvimento')
@click.option('--verbose', is_flag=True, help='Mostrar detalhes da execução')
def init_db(reset, seeds, verbose):
    """
    Inicializa o banco de dados AutoCore com SQLAlchemy ORM
    """
    click.echo(click.style("🚀 Inicializando Database AutoCore (ORM)", fg='cyan', bold=True))
    click.echo("=" * 50)
    
    db_path = Path(__file__).parent.parent.parent / 'autocore.db'
    
    # Reset se solicitado
    if reset and db_path.exists():
        if click.confirm('⚠️  Tem certeza que deseja remover o banco existente?'):
            os.remove(db_path)
            click.echo(click.style("✓ Banco anterior removido", fg='green'))
        else:
            click.echo("Operação cancelada")
            return
    
    # Criar tabelas usando SQLAlchemy
    click.echo("\n📊 Criando estrutura do banco com SQLAlchemy...")
    try:
        engine = create_all_tables()
        click.echo(click.style("✓ Tabelas criadas com sucesso via ORM", fg='green'))
        
        # Listar tabelas criadas
        if verbose:
            inspector = inspect(engine)
            tables = inspector.get_table_names()
            click.echo(f"\n📑 Tabelas criadas ({len(tables)}):")
            for table in sorted(tables):
                click.echo(f"  • {table}")
    except Exception as e:
        click.echo(click.style(f"✗ Erro ao criar tabelas: {e}", fg='red'))
        return
    
    # Aplicar seeds usando ORM
    if seeds:
        click.echo("\n🌱 Aplicando seeds de desenvolvimento com ORM...")
        try:
            # Importar e executar seed ORM
            from seeds.seed_development import main as seed_main
            seed_main()
            click.echo(click.style("✓ Seeds aplicados com sucesso", fg='green'))
        except Exception as e:
            click.echo(click.style(f"✗ Erro ao aplicar seeds: {e}", fg='red'))
            import traceback
            if verbose:
                traceback.print_exc()
    
    # Mostrar estatísticas usando SQLAlchemy
    click.echo("\n📊 Estatísticas do banco:")
    
    stats = []
    tables_to_check = [
        ('devices', 'Dispositivos'),
        ('relay_channels', 'Canais de Relé'),
        ('screens', 'Telas'),
        ('screen_items', 'Itens de Tela'),
        ('users', 'Usuários'),
        ('themes', 'Temas'),
        ('telemetry_data', 'Telemetria'),
        ('event_logs', 'Eventos')
    ]
    
    with engine.connect() as conn:
        for table_name, display_name in tables_to_check:
            try:
                result = conn.execute(text(f"SELECT COUNT(*) FROM {table_name}"))
                count = result.scalar()
                stats.append([display_name, count])
            except:
                stats.append([display_name, 0])
    
    click.echo(tabulate(stats, headers=['Entidade', 'Registros'], tablefmt='simple'))
    
    # Tamanho do banco
    if db_path.exists():
        size_mb = db_path.stat().st_size / (1024 * 1024)
        click.echo(f"\n💾 Tamanho do banco: {size_mb:.2f} MB")
        click.echo(f"📂 Localização: {db_path}")
    
    click.echo("\n" + "=" * 50)
    click.echo(click.style("✅ Banco de dados inicializado com SQLAlchemy ORM!", fg='green', bold=True))
    click.echo("\n💡 Próximos passos:")
    click.echo("  1. Testar repositories: python scripts/test_repositories.py")
    click.echo("  2. Iniciar backend: cd ../config-app/backend && python main.py")
    click.echo("  3. Verificar integridade: sqlite3 autocore.db 'PRAGMA integrity_check'")
    
    click.echo("\n📝 Nota: Usando SQLAlchemy ORM para todas as operações")
    click.echo("    - Repositories: shared/repositories.py")
    click.echo("    - Models: src/models/models.py")
    click.echo("    - Seeds: seeds/seed_development.py")

if __name__ == '__main__':
    init_db()