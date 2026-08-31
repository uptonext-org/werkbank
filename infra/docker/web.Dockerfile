# Image for apps/web (React + Vite).
#
# Built from the repo root (see docker-compose.yml) so it can see the rest
# of the pnpm/Turborepo workspace. Three stages:
#   1. pruner   — uses `turbo prune` to cut the monorepo down to just what
#                 apps/web needs (its own files + the root workspace
#                 manifests), so later stages don't install or copy
#                 apps/mobile or unrelated packages.
#   2. builder  — installs the pruned dependencies with pnpm and runs the
#                 production Vite build.
#   3. runtime  — serves the built static files with nginx. Contains no
#                 Node.js, source code, or dependencies — only the
#                 compiled output.

# --- Pruner ----------------------------------------------------------------
FROM node:22-alpine AS pruner

WORKDIR /app
RUN npm install -g turbo@^2.3.3

COPY . .
RUN turbo prune web --docker

# --- Builder -----------------------------------------------------------
FROM node:22-alpine AS builder

WORKDIR /app
RUN corepack enable

# Install dependencies first, from the pruned manifests only, so this
# layer is cached unless a package.json/lockfile actually changed.
COPY --from=pruner /app/out/json/ .
RUN pnpm install --frozen-lockfile

# Now bring in the pruned source and build.
COPY --from=pruner /app/out/full/ .

# Vite inlines VITE_* variables into the built bundle at build time (not
# read at container runtime) — see the .env.example comment and README for
# how to override this. Defaults to same-origin `/api`, proxied by nginx
# (see nginx.web.conf), which needs no rebuild to retarget.
ARG VITE_API_URL=/api
ENV VITE_API_URL=${VITE_API_URL}

RUN pnpm exec turbo run build --filter=web

# --- Runtime -------------------------------------------------------------
# nginx-unprivileged runs the master process as a non-root user on port
# 8080 instead of the usual root-owned port 80.
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime

COPY infra/docker/nginx.web.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/apps/web/dist /usr/share/nginx/html

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://localhost:8080/ || exit 1
