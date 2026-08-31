# Image for apps/api (FastAPI backend).
#
# Built from the repo root (see docker-compose.yml) so it has access to
# apps/api. Two stages:
#   1. builder — resolves and installs the package (runtime dependencies
#      only, not the "dev" extra) into a throwaway virtualenv.
#   2. runtime — copies just that virtualenv plus the files needed to run
#      the app and Alembic migrations, and runs as a non-root user.

# --- Builder -------------------------------------------------------------
FROM python:3.12-slim AS builder

WORKDIR /build

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# pyproject.toml + app/ are copied together because the build backend
# (hatchling) packages app/ directly from source — there's no separate
# lockfile/requirements layer to install ahead of the source for caching.
COPY apps/api/pyproject.toml ./
COPY apps/api/app ./app

RUN pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir .

# --- Runtime ---------------------------------------------------------------
FROM python:3.12-slim AS runtime

RUN groupadd --system app \
  && useradd --system --gid app --home-dir /app --no-create-home app

WORKDIR /app

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    WEB_CONCURRENCY=2

# The "app" package itself was installed into the venv's site-packages by
# the builder stage — only Alembic's config/migrations need to be copied
# separately, since they're invoked as files (alembic.ini, alembic/) via
# the CLI, not imported as part of the package.
COPY --from=builder /opt/venv /opt/venv
COPY apps/api/alembic ./alembic
COPY apps/api/alembic.ini ./

RUN chown -R app:app /app
USER app

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request as u; u.urlopen('http://localhost:8000/health', timeout=2)" || exit 1

# WEB_CONCURRENCY controls the number of uvicorn worker processes; override
# per-environment (e.g. WEB_CONCURRENCY=4 in production). For local
# development with autoreload, override the compose command instead, e.g.:
#   command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers ${WEB_CONCURRENCY}"]
