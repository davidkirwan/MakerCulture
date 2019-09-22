ORG ?= dkirwan_redhat
PROJECT ?= makerculture
REG=quay.io
SHELL=/bin/bash
TAG ?= 0.0.5
PKG=github.com/davidkirwan/makerculture
PWD=$(shell pwd)
DISCORD_TOKEN=$(shell cat discord_token.txt)

.PHONY: default
default: list

.PHONY: list
list:
	@echo --- Printing targets: ---
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' -e "list" -e "default"
	@echo --- Printing Complete ---


.PHONY: image/build
image/build:
	docker image build -t "${REG}/${ORG}/${PROJECT}:${TAG}" .

.PHONY: image/push
image/push:
	docker push ${REG}/${ORG}/${PROJECT}:${TAG}

.PHONY: run
run:
	docker run --rm -it -p 0.0.0.0:3000:3000 -v $(PWD):/root/src --name makerculture ${REG}/${ORG}/${PROJECT}:${TAG} $(DISCORD_TOKEN)

