"""add ldl, hba1c, bmi to vitaltype enum

Revision ID: f5a7b9c1d3e6
Revises: e4f6a8b0c2d5
Create Date: 2026-06-25
"""
from alembic import op

revision = "f5a7b9c1d3e6"
down_revision = "e4f6a8b0c2d5"
branch_labels = None
depends_on = None


def upgrade():
    # ALTER TYPE ... ADD VALUE cannot run inside a transaction block.
    with op.get_context().autocommit_block():
        op.execute("ALTER TYPE vitaltype ADD VALUE IF NOT EXISTS 'ldl'")
        op.execute("ALTER TYPE vitaltype ADD VALUE IF NOT EXISTS 'hba1c'")
        op.execute("ALTER TYPE vitaltype ADD VALUE IF NOT EXISTS 'bmi'")


def downgrade():
    # Postgres does not support removing enum values; no-op.
    pass
