#!/bin/bash

APP = base
VERSION := $(shell cat ./VERSION)
DOCKER_REPO_APP = ikerib/${APP}:${VERSION}
UID = $(shell id -u)
GROUP_ID= $(shell id -g)
user==appuser


help:
	@echo 'usage: make [target]'
	@echo
	@echo 'targets'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ":#"

build: ## Docker irudia sortu
	docker build -t ${DOCKER_REPO_APP} .

push: ## docker irudia bidali registrira
	docker push ${DOCKER_REPO_APP}