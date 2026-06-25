"""add app_content table (admin-managed content & catalogs)

Revision ID: e4f6a8b0c2d5
Revises: d3e5f7a9b2c4
Create Date: 2026-06-25
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "e4f6a8b0c2d5"
down_revision = "d3e5f7a9b2c4"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "app_content",
        sa.Column("id", postgresql.UUID(as_uuid=True), server_default=sa.text("gen_random_uuid()"), nullable=False),
        sa.Column("category", sa.String(), nullable=False),
        sa.Column("item_key", sa.String(), nullable=True),
        sa.Column("title", sa.String(), nullable=False),
        sa.Column("body", sa.Text(), nullable=True),
        sa.Column("emoji", sa.String(), nullable=True),
        sa.Column("severity", sa.String(), nullable=True),
        sa.Column("stage", sa.String(), nullable=True),
        sa.Column("section", sa.String(), nullable=True),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("sort_order", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("hospital_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("locale", sa.String(), nullable=False, server_default="en"),
        sa.Column("published", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["hospital_id"], ["hospitals.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_app_content_category", "app_content", ["category"])
    op.create_index("ix_app_content_stage", "app_content", ["stage"])


def downgrade():
    op.drop_index("ix_app_content_stage", table_name="app_content")
    op.drop_index("ix_app_content_category", table_name="app_content")
    op.drop_table("app_content")
