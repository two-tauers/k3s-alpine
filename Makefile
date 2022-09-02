.DEFAULT_GOAL := help

ALPINE_URL = https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/aarch64/alpine-rpi-3.16.2-aarch64.tar.gz

.PHONY: download
download: ## Download alpine image and headless bootstrap into the bin/ folder
	@sh bin/download.sh ${ALPINE_URL}

.PHONY: clear
clear: ## Remove downloads from bin/downloads
	@rm bin/download/*

.PHONY: install
install: download build ## Install the OS onto a drive, usage: make install path=/mnt/sd
	@echo -n "Copying alpine linux files"
	@tar -xzf bin/download/`echo ${ALPINE_URL} | rev | cut -d/ -f 1 | rev` -C $(path) --checkpoint=1000 --checkpoint-action=dot && echo " done"
	@echo -n "Copying bootstrap file."
	@cp bootstrap/bootstrap.apkovl.tar.gz $(path) && echo " done"

.PHONY: build
build: ## Build bootstrap overlay
	@echo "Building alkovl"
	@cd bootstrap && sh build.sh ${name}


.PHONY: help
help: ## Display this help
	@echo "Usage:\n  make \033[36m<target>\033[0m"
	@awk 'BEGIN {FS = ":.*##"}; \
		/^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } \
		/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } \
		/^###@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
