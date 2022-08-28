.DEFAULT_GOAL := help

ALPINE_URL = https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/aarch64/alpine-rpi-3.16.2-aarch64.tar.gz
HEADLESS_BOOTSTRAP_URL = https://raw.githubusercontent.com/macmpi/alpine-linux-headless-bootstrap/089996a5283eb16d242a315b9b132e8706cbdbb7/headless.apkovl.tar.gz


.PHONY: download
download: ## Download alpine image and headless bootstrap into the bin/ folder
	@sh bin/download.sh ${ALPINE_URL}
	@sh bin/download.sh $(HEADLESS_BOOTSTRAP_URL)

.PHONY: clear
clear: ## Remove downloads from bin/downloads
	@rm bin/download/*

.PHONY: install
install: download ## Remove downloads from bin/downloads
	@echo -n "Copying alpine linux files"
	@tar -xzf bin/download/`echo ${ALPINE_URL} | rev | cut -d/ -f 1 | rev` -C $(path)  --checkpoint=1000 --checkpoint-action=dot && echo " done"
	@echo -n "Copying headless bootstrap files......"
	@cp bin/download/`echo ${HEADLESS_BOOTSTRAP_URL} | rev | cut -d/ -f 1 | rev` $(path) && echo " done"


.PHONY: help
help: ## Display this help
	@echo "Usage:\n  make \033[36m<target>\033[0m"
	@awk 'BEGIN {FS = ":.*##"}; \
		/^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } \
		/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } \
		/^###@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
