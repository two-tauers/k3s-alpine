.DEFAULT_GOAL := help

ALPINE_FILENAME:=`cat alpine-url | grep -o '[^/]*.tar.gz'`

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

.PHONY: download-alpine
download-alpine: ## Download alpine image into the bin/ folder
	@echo "Downloading alpine"
	@sh scripts/download-alpine.sh

.PHONY: build-overlay
build-overlay: ## Build bootstrap overlay
	$(call check_defined, name)
	@echo "Building alkovl"
	@sh scripts/build-overlay.sh ${name}

.PHONY: clean
clean: ## Remove downloads from bin/downloads
	@rm -r bin/*

.PHONY: install
install: download-alpine build-overlay ## Install the OS onto a drive, usage: make install path=/mnt/sd
	$(call check_defined, path)
	@echo -n "Copying contents of ${ALPINE_FILENAME}"
	@tar -xzf bin/${ALPINE_FILENAME} -C $(path) --checkpoint=1000 --checkpoint-action=dot && echo " done"
	@echo -n "Copying bootstrap file."
	@cp bin/overlay.apkovl.tar.gz $(path) && echo " done"

.PHONY: boot
boot: ## Make a bootable drive, required `drive` argument (WILL DELETE DATA)
	$(call check_defined, drive)
	$(call check_defined, name)
	@lsblk ${drive}
	@echo -n "This will ERASE ALL DATA ON ${drive}. Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo "Partitioning ${drive}"
	@parted ${drive}  rm 1  mkpart primary FAT32 2048 100%  set 1 boot on  print
	@sleep 2
	@echo "Formatting ${drive}"
	@mkfs.fat ${drive}1
	@echo "Mounting ${drive}"
	@mount ${drive}1 /mnt/sd
	@echo "Formatting ${drive}"
	@$(MAKE) install path=/mnt/sd name=${name}
	@echo "Unmounting ${drive}"
	@sudo umount /mnt/sd

.PHONY: help
help: ## Display this help
	@echo "Usage:\n  make \033[36m<target>\033[0m"
	@awk 'BEGIN {FS = ":.*##"}; \
		/^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } \
		/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } \
		/^###@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
