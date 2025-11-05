#!/bin/bash

APP = base
VERSION := $(shell cat ./VERSION)
DOCKER_REPO_APP = ikerib/${APP}:${VERSION}-dev
DOCKER_REPO_APP_PROD = ikerib/${APP}:${VERSION}-prod
UID = $(shell id -u)
GROUP_ID= $(shell id -g)
user==appuser

# Plataformak definitu
PLATFORMS = linux/amd64,linux/arm64

help:
	@echo 'usage: make [target]'
	@echo
	@echo 'targets'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ":#"

setup-buildx: ## Docker buildx konfiguratu multi-plataformarako
	docker buildx create --name multiarch --driver docker-container --bootstrap --use || true
	docker buildx inspect --bootstrap

build: ## Docker irudia sortu plataforma anitzetan (linux/amd64 eta linux/arm64)
	docker buildx build --platform ${PLATFORMS} -t ${DOCKER_REPO_APP} -f Dockerfile .
	docker buildx build --platform ${PLATFORMS} -t ${DOCKER_REPO_APP_PROD} -f Dockerfile-prod .

build-local: ## Docker irudia sortu lokalean soilik (linux/amd64)
	docker build -t ${DOCKER_REPO_APP} -f Dockerfile .
	docker build -t ${DOCKER_REPO_APP_PROD} -f Dockerfile-prod .

push: ## docker irudia bidali registrira (plataforma anitzetan)
	docker buildx build --platform ${PLATFORMS} -t ${DOCKER_REPO_APP} -f Dockerfile --push .
	docker buildx build --platform ${PLATFORMS} -t ${DOCKER_REPO_APP_PROD} -f Dockerfile-prod --push .

push-local: ## docker irudia bidali registrira (lokalean build egindakoa)
	docker push ${DOCKER_REPO_APP}
	docker push ${DOCKER_REPO_APP_PROD}