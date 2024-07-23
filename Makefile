# Variables
CONTAINER_PHP = app
CONTAINER_DB = mysql

# Docker commands

init:
	cp .env.example .env
	docker compose up -d --build
	docker compose exec $(CONTAINER_PHP) composer install
	docker compose exec $(CONTAINER_PHP) php artisan key:generate
	docker compose exec $(CONTAINER_PHP) php artisan migrate
	docker compose exec $(CONTAINER_PHP) php artisan db:seed

up:
	docker compose up -d
up-build:
	docker compose up -d --build
down:
	docker compose down
down-v:
	docker compose down -v
build:
	docker compose build
shell:
	docker compose exec $(CONTAINER_PHP) bash
