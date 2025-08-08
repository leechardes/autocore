#!/usr/bin/env python3
"""
Setup Alembic para auto-migrations baseadas nos models
"""
import os
import sys
from pathlib import Path

def setup_alembic():
    """Configura Alembic para usar os models do SQLAlchemy"""
    
    # Cria diretório alembic se não existir
    alembic_dir = Path(__file__).parent.parent.parent / 'alembic'
    alembic_dir.mkdir(exist_ok=True)
    
    # Cria env.py para Alembic
    env_content = '''"""Alembic Environment Configuration"""
from logging.config import fileConfig
from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context
import sys
from pathlib import Path

# Adiciona o diretório pai ao path
sys.path.append(str(Path(__file__).parent.parent.parent))

# Importa os models - IMPORTANTE!
from src.models import Base, get_engine

# this is the Alembic Config object
config = context.config

# Interpret the config file for Python logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Model's MetaData object for 'autogenerate' support
target_metadata = Base.metadata

def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url", "sqlite:///autocore.db")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    engine = get_engine()

    with engine.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata
        )

        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
'''
    
    env_file = alembic_dir / 'env.py'
    with open(env_file, 'w') as f:
        f.write(env_content)
    
    # Cria script.py.mako (template para migrations)
    script_template = '''"""${message}

Revision ID: ${up_revision}
Revises: ${down_revision | comma,n}
Create Date: ${create_date}

"""
from alembic import op
import sqlalchemy as sa
${imports if imports else ""}

# revision identifiers, used by Alembic.
revision = ${repr(up_revision)}
down_revision = ${repr(down_revision)}
branch_labels = ${repr(branch_labels)}
depends_on = ${repr(depends_on)}

def upgrade() -> None:
    ${upgrades if upgrades else "pass"}

def downgrade() -> None:
    ${downgrades if downgrades else "pass"}
'''
    
    script_file = alembic_dir / 'script.py.mako'
    with open(script_file, 'w') as f:
        f.write(script_template)
    
    # Cria diretório versions
    versions_dir = alembic_dir / 'versions'
    versions_dir.mkdir(exist_ok=True)
    
    print("✅ Alembic configurado com sucesso!")
    print("\n📝 Comandos disponíveis:")
    print("  alembic revision --autogenerate -m 'descrição'  # Gera migration automática")
    print("  alembic upgrade head                             # Aplica migrations")
    print("  alembic downgrade -1                             # Desfaz última migration")
    print("  alembic history                                  # Ver histórico")
    print("  alembic current                                  # Ver versão atual")
    
    return True

if __name__ == '__main__':
    setup_alembic()