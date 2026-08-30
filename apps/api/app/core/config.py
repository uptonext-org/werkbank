"""Application configuration.

Settings are sourced from environment variables (see .env.example at the
repo root). Nothing here is hardcoded for a specific environment.
"""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # General
    environment: str = "development"
    debug: bool = True
    api_v1_prefix: str = "/api/v1"

    # Database
    database_url: str = "postgresql+psycopg://werkbank:werkbank@localhost:5432/werkbank"

    # Auth (placeholders — wired up when app/shared/auth is implemented)
    secret_key: str = "change-me"
    access_token_expire_minutes: int = 60


@lru_cache
def get_settings() -> Settings:
    return Settings()
