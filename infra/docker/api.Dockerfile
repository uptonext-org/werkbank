# Development image for apps/api.
#
# Built from the repo root (see docker-compose.yml) so it has access to
# apps/api. Not optimized for production yet — no multi-stage build,
# no non-root user — this is intentionally just enough to run the API
# alongside PostgreSQL in local development.

FROM python:3.12-slim

WORKDIR /app

COPY apps/api/ ./
RUN pip install --no-cache-dir -e .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
