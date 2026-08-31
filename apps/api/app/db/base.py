"""Declarative base for SQLAlchemy models.

Model modules (added under app/modules/*/models.py as those modules are
implemented) should import `Base` from here and be imported into
alembic/env.py so Alembic autogenerate can discover them. No models are
defined yet.
"""

from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass
