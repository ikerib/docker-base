#!/bin/bash

APP = base
VERSION := $(shell cat ./VERSION)
DOCKER_REPO_APP = ikerib/${APP}:${VERSION}
USER_ID = $(shell id -u)
GROUP_ID= $(shell id -g)
user==www-data

help:
	@echo 'usage: make [target]'
	@echo
	@echo 'targets'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ":#"

build: ## build
	docker build -t ${DOCKER_REPO_APP} .

push:
	docker push ${DOCKER_REPO_APP}