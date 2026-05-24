.PHONY: help up down build logs health bootstrap migrate backup monitoring deploy-local

help:
	@echo "SmartHealth DevOps commands"
	@echo "  make bootstrap   — First-time local setup"
	@echo "  make up          — Start all services"
	@echo "  make down        — Stop all services"
	@echo "  make build       — Build application images"
	@echo "  make logs        — Tail API logs"
	@echo "  make health      — Run health check script"
	@echo "  make migrate     — Run database migrations"
	@echo "  make backup      — Run manual backup"
	@echo "  make monitoring  — Start Grafana/Prometheus/Uptime Kuma"

bootstrap:
	sh docker/scripts/bootstrap.sh

up:
	docker compose up -d

down:
	docker compose down

build:
	docker compose build smarthealth-api smarthealth-admin smarthealth-facility-portal

logs:
	docker compose logs -f smarthealth-api

health:
	sh docker/scripts/healthcheck.sh

migrate:
	docker compose run --rm smarthealth-migrate

backup:
	docker compose --profile backup run --rm smarthealth-backup /backup.sh

monitoring:
	docker compose --profile monitoring up -d

deploy-local: bootstrap
