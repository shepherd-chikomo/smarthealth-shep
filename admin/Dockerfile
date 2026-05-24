FROM node:22-alpine AS builder

WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .

ARG VITE_API_BASE=/v1
ENV VITE_API_BASE=$VITE_API_BASE

RUN npm run build

FROM nginx:1.27-alpine AS runner

COPY docker/nginx/admin.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html/admin

EXPOSE 80
HEALTHCHECK CMD wget -qO- http://localhost:80/admin/ || exit 1
