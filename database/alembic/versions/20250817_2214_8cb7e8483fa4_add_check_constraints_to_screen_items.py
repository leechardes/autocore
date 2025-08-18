"""Add check constraints to screen_items

Revision ID: 8cb7e8483fa4
Revises: cc3149ee98bd
Create Date: 2025-08-17 22:14:16.278548

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '8cb7e8483fa4'
down_revision = 'cc3149ee98bd'
branch_labels = None
depends_on = None

def upgrade() -> None:
    # Adiciona Check Constraints usando batch mode para screen_items
    with op.batch_alter_table('screen_items') as batch_op:
        batch_op.create_check_constraint(
            'check_item_action_consistency',
            "(item_type IN ('DISPLAY', 'GAUGE') AND action_type IS NULL) OR "
            "(item_type IN ('BUTTON', 'SWITCH') AND action_type IS NOT NULL)"
        )
        
        batch_op.create_check_constraint(
            'check_relay_control_requirements',
            "action_type != 'RELAY_CONTROL' OR "
            "(action_type = 'RELAY_CONTROL' AND relay_board_id IS NOT NULL AND relay_channel_id IS NOT NULL)"
        )
        
        batch_op.create_check_constraint(
            'check_display_data_requirements',
            "item_type NOT IN ('DISPLAY', 'GAUGE') OR "
            "(item_type IN ('DISPLAY', 'GAUGE') AND data_source IS NOT NULL AND data_path IS NOT NULL)"
        )

def downgrade() -> None:
    # Remove Check Constraints usando batch mode
    with op.batch_alter_table('screen_items') as batch_op:
        batch_op.drop_constraint('check_item_action_consistency', type_='check')
        batch_op.drop_constraint('check_relay_control_requirements', type_='check')
        batch_op.drop_constraint('check_display_data_requirements', type_='check')
