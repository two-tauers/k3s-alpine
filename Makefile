.DEFAULT_GOAL := help
SETTINGS:=settings.yaml

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))


.PHONY: download ## Download file to a place: make download https://www.somewhere.com/file.tar /path/to/download
download:
	$(call check_defined, url)
	$(call check_defined, target)
	@sh scripts/download.sh ${url} ${target}

.PHONY: download-all ## Download alpine and k3s to bin/ directory, as defined in settings.yaml: make download-all
download-all:
	@$(MAKE) --no-print-directory download url=$(shell yq -M '.download.alpine.url' < ${SETTINGS}) target=$(shell yq -M '.download.alpine.path' < ${SETTINGS})
	@$(MAKE) --no-print-directory download url=$(shell yq -M '.download.k3s.url' < ${SETTINGS}) target=$(shell yq -M '.download.k3s.path' < ${SETTINGS})
	@$(MAKE) --no-print-directory download url=$(shell yq -M '.download."k3s-installer".url' < ${SETTINGS}) target=$(shell yq -M '.download."k3s-installer".path' < ${SETTINGS})

.PHONY: overlay
overlay: ## Build bootstrap overlay, runs scripts/build-overlay.sh: make overlay config=config/server-init.yaml
	$(call check_defined, config)
	@sh scripts/build-overlay.sh ${config}

.PHONY: clean
clean: ## Remove all files from bin/: make clean
	@rm -r bin/*

.PHONY: install
install: download-all overlay ## Install the OS onto a path, runs download-all and overlay beforehand: make install path=/mnt/sd
	$(call check_defined, path)
	@sh scripts/install.sh $(shell yq -M '.download.alpine.path' < ${SETTINGS}) bin/overlay.apkovl.tar.gz ${path}

.PHONY: boot
boot: ## !!! WILL DELETE DATA, LOOK AT CONTENTS BEFORE RUNNING !!! Make a bootable drive: sudo make boot drive=/dev/sdb config=config/server-init.yaml
	$(call check_defined, drive)
	$(call check_defined, config)
	@lsblk ${drive}
	@echo -n "This will ERASE ALL DATA ON ${drive}. Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo "Partitioning ${drive}"
	@parted ${drive}  rm 1  mkpart primary FAT32 1M 100%  set 1 boot on  print
	@sleep 2
	@echo "Formatting ${drive}1"
	@mkfs.fat ${drive}1
	@echo "Mounting ${drive}"
	@mount ${drive}1 /mnt/sd
	@echo "Installing onto ${drive}"
	@$(MAKE) --no-print-directory install path=/mnt/sd config=${config}
	@echo "Unmounting ${drive}"
	@umount /mnt/sd

.PHONY: help
help: ## Display this help
	@echo "Usage:\n  make \033[36m<target>\033[0m"
	@awk 'BEGIN {FS = ":.*##"}; \
		/^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } \
		/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } \
		/^###@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
