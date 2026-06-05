FROM node:22-alpine AS runner

RUN apk add --no-cache wget

WORKDIR /app
ENV NODE_ENV=production

# Repo root context (see docker-compose.yml) — package + source + migrations for import CLI scripts
COPY backend/package.json backend/package-lock.json* ./
RUN npm ci

COPY backend/tsconfig.json ./
COPY backend/src ./src
COPY supabase/migrations ./supabase/migrations

EXPOSE 3000
USER node
CMD ["node_modules/.bin/tsx", "src/index.ts"]
