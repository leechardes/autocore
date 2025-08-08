"""Remove name and location fields from relay_boards

Revision ID: 6bae50cd6001
Revises: 
Create Date: 2025-08-08 06:11:34.006834

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '6bae50cd6001'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    # SQLite doesn't support dropping columns directly, so we need to recreate the table
    with op.batch_alter_table('relay_boards', schema=None) as batch_op:
        batch_op.drop_column('location')
        batch_op.drop_column('name')

def downgrade() -> None:
    # Revert changes for SQLite
    with op.batch_alter_table('relay_boards', schema=None) as batch_op:
        batch_op.add_column(sa.Column('name', sa.VARCHAR(length=100), nullable=False, server_default=''))
        batch_op.add_column(sa.Column('location', sa.VARCHAR(length=100), nullable=True))
