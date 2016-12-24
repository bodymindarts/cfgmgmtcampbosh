# genesis, available at https://github.com/starkandwayne/genesis

save_VAULT_ADDR := $(VAULT_ADDR)
VAULT_ADDR =
REDACT = yes

root_path := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))../..)
ifdef USE_SYSTEM_GENESIS
	PATH := $(PATH)
else
	PATH := $(root_path)/bin:$(PATH)
endif

help: check
	@PATH=$(PATH) genesis help makefile

version:
	@PATH=$(PATH) echo "using $$(which genesis)"
	@PATH=$(PATH) genesis version

manifest: check
	@REDACT=yes PATH=$(PATH) genesis build

deploy: check
	@REDACT= VAULT_ADDR=$(save_VAULT_ADDR) PATH=$(PATH) genesis deploy

refresh: check
	@PATH=$(PATH) genesis refresh

check:
	@PATH=$(PATH) genesis ping >/dev/null 2>&1 || (echo >&2 "You need to install Genesis first (see https://github.com/starkandwayne/genesis)" && exit 1)

.PHONY: help check manifest deploy refresh version
