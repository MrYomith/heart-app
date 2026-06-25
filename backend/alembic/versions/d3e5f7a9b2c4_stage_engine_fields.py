"""add discharge_date and stage_paused to users (FR-035 stage engine)

Revision ID: d3e5f7a9b2c4
Revises: c2d4e6f8a0b1
Create Date: 2026-06-24

discharge_date drives the Stage 5 (rehab) / Stage 6 (thriving) date rules;
stage_paused lets a clinician pause auto-advancement when surgery is delayed.
"""
from alembic import op
import sqlalchemy as sa

revision = "d3e5f7a9b2c4"
down_revision = "c2d4e6f8a0b1"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("users", sa.Column("discharge_date", sa.Date(), nullable=True))
    op.add_column("users", sa.Column("stage_paused", sa.Boolean(), nullable=False, server_default=sa.false()))


def downgrade():
    op.drop_column("users", "stage_paused")
    op.drop_column("users", "discharge_date")
