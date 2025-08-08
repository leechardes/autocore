"""Remove default_state and current_state from relay_channels

Revision ID: 1a1a631ee7ec
Revises: 6bae50cd6001
Create Date: 2025-08-08 06:30:15.735328

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '1a1a631ee7ec'
down_revision = '6bae50cd6001'
branch_labels = None
depends_on = None

def upgrade() -> None:
    # SQLite doesn't support dropping columns directly, use batch mode
    with op.batch_alter_table('relay_channels', schema=None) as batch_op:
        batch_op.drop_column('current_state')
        batch_op.drop_column('default_state')

def downgrade() -> None:
    # Revert changes for SQLite
    with op.batch_alter_table('relay_channels', schema=None) as batch_op:
        batch_op.add_column(sa.Column('default_state', sa.BOOLEAN(), nullable=True, server_default='0'))
        batch_op.add_column(sa.Column('current_state', sa.BOOLEAN(), nullable=True, server_default='0'))
