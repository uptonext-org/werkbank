"""FastAPI application entrypoint."""

from fastapi import APIRouter, FastAPI

from app.core.config import get_settings

settings = get_settings()

app = FastAPI(
    title="UpToWork API",
    version="0.1.0",
    debug=settings.debug,
)

# Versioned API router. Business module routers get included here as they
# are implemented, e.g.:
#   from app.modules.customers.router import router as customers_router
#   api_router.include_router(customers_router)
api_router = APIRouter(prefix=settings.api_v1_prefix)


@api_router.get("/health", tags=["health"])
def health() -> dict[str, str]:
    """Health check, matching packages/contract's /health path."""
    return {"status": "ok"}


app.include_router(api_router)


@app.get("/health", tags=["health"], include_in_schema=False)
def root_health() -> dict[str, str]:
    """Unversioned liveness check for infra (Docker healthcheck, load balancers)."""
    return {"status": "ok"}
