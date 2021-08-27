PROJECT_DIR := $(CURDIR)
MC_DIR := $(PROJECT_DIR)/minecraft

SHELL = /bin/bash
.SHELLFLAGS = -e -o pipefail -c

.PHONY: build
build: ## build paper docker container
	docker-compose build

.PHONY: clean build
clean build: ## clean build (no use docker cache)
	docker-compose build --no-cache

.PHONY: delete
delete: ## delete minecraft data
	rm -rf $(MC_DIR)/*

.PHONY: deploy
deploy: ## deploy minecraft server
	docker-compose up -d

.PHONY: run
run: ## run minecraft server
	docker-compose up