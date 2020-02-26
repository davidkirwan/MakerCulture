ORG ?= dkirwan_redhat
PROJECT ?= makerculture
REG=quay.io
SHELL=/bin/bash
TAG ?= 0.0.9
PKG=github.com/davidkirwan/makerculture
PWD=$(shell pwd)
DISCORD_TOKEN=$(shell cat discord_token.txt)

.DEFAULT_GOAL:=help

.PHONY: help
help: ## Show this help screen
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Image

.PHONY: build
build: ## Build the image
	podman image build -t "${REG}/${ORG}/${PROJECT}:${TAG}" .

.PHONY: push
push: ## Push the image to quay.io
	podman push ${REG}/${ORG}/${PROJECT}:${TAG}

.PHONY: run
run: ## Run the container
	podman run --rm -it -p 0.0.0.0:3000:3000 -v $(PWD):/root/src --name makerculture ${REG}/${ORG}/${PROJECT}:${TAG} $(DISCORD_TOKEN)

