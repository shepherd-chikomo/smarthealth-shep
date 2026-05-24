FROM node:22-alpine AS runner

RUN apk add --no-cache wget

WORKDIR /app
ENV NODE_ENV=production

COPY package.json package-lock.json* ./
RUN npm ci

COPY tsconfig.json ./
COPY src ./src

EXPOSE 3000
USER node
CMD ["npx", "tsx", "src/index.ts"]
