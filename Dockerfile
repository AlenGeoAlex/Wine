#--------------------------------------------------------------------
# STAGE 1: The "Builder" Stage
#--------------------------------------------------------------------
FROM node:20-alpine AS builder
RUN corepack enable
WORKDIR /app

# This part remains the same: we need the full monorepo context to build.
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./
COPY apps/ /app/apps/
COPY packages/ /app/packages/

RUN pnpm install --filter 'wine-server...'

COPY . .

RUN pnpm --filter wine-server exec -- nest build

# --- THIS IS THE KEY COMMAND ---
# Now that `wine-server/package.json` has the correct config, this command will succeed.
# It will copy the built `dist` and a flat `node_modules` (with common-models included)
# into the /app/deploy directory.
RUN pnpm --legacy --filter wine-server deploy /app/deploy


#--------------------------------------------------------------------
# STAGE 2: The "Production" Stage (Simple and Robust)
#--------------------------------------------------------------------
FROM node:20-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app

# Copy the ENTIRE prepared deployment bundle from the builder stage.
COPY --from=builder --chown=appuser:appgroup /app/deploy/ .

# Copy and make the entrypoint script executable
COPY --chown=appuser:appgroup entrypoint.sh .
RUN chmod +x ./entrypoint.sh

USER appuser
ENV NODE_ENV=production
EXPOSE 3000

ENTRYPOINT ["./entrypoint.sh"]
CMD []