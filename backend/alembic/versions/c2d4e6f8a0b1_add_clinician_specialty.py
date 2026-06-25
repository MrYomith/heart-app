"""add clinician_specialty to users

Revision ID: c2d4e6f8a0b1
Revises: 4f96b3d2c5ff
Create Date: 2026-06-24

Lets a clinician account carry its specialty (surgeon/nurse/physio/psychokardiologist)
so the care team can be auto-assigned when a patient is approved at a hospital.
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "c2d4e6f8a0b1"
down_revision = "4f96b3d2c5ff"
branch_labels = None
depends_on = None

# Reuse the existing Postgres enum type created by clinician_assignments.
clinicianrole = postgresql.ENUM(
    "surgeon", "nurse", "physio", "psychokardiologist", "admin",
    name="clinicianrole", create_type=False,
)


def upgrade():
    op.add_column("users", sa.Column("clinician_specialty", clinicianrole, nullable=True))


def downgrade():
    op.drop_column("users", "clinician_specialty")
