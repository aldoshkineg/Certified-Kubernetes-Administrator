# Makefile for managing bootstrap mode in Vagrantfile and Kubernetes version in bootstrap.sh
# Targets:
#   pure, base, full      - change bootstrap mode in Vagrantfile
#   status                - show current bootstrap mode
#   set-version [version] - change K8s version in bootstrap.sh (with or without VER=)
#   get-version           - show current K8s version in bootstrap.sh
#   help                  - show this help

VAGRANTFILE = Vagrantfile
BOOTSTRAP_SCRIPT = bootstrap/bootstrap.sh

.PHONY: pure base full status set-version get-version help

pure:
	@echo "Setting bootstrap mode to 'pure'"
	@sed -i -E 's|^([[:space:]]*/bootstrap/bootstrap\.sh )[a-z]+|\1pure|' $(VAGRANTFILE)

base:
	@echo "Setting bootstrap mode to 'base'"
	@sed -i -E 's|^([[:space:]]*/bootstrap/bootstrap\.sh )[a-z]+|\1base|' $(VAGRANTFILE)

full:
	@echo "Setting bootstrap mode to 'full'"
	@sed -i -E 's|^([[:space:]]*/bootstrap/bootstrap\.sh )[a-z]+|\1full|' $(VAGRANTFILE)

status:
	@echo "Current bootstrap mode:"
	@awk 'match($$0, /\/bootstrap\/bootstrap\.sh[[:space:]]+([a-z]+)/, m) {print m[1]}' $(VAGRANTFILE)

set-version:
	@$(eval VERSION := $(if $(VER),$(VER),$(word 2,$(MAKECMDGOALS))))
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make set-version [version]   or   make set-version VER=version"; \
		exit 1; \
	fi
	@echo "Setting Kubernetes version to '$(VERSION)' in $(BOOTSTRAP_SCRIPT)"
	@sed -i -E 's/^(K8S_VERSION=")[0-9.]+(")/\1$(VERSION)\2/' $(BOOTSTRAP_SCRIPT)
	@# Prevent make from interpreting the version as a target
	@true

# Dummy target to consume the version argument when passed as a separate word
%:
	@:

get-version:
	@echo "Current Kubernetes version in $(BOOTSTRAP_SCRIPT):"
	@awk -F'"' '/^K8S_VERSION=/ {print $$2}' $(BOOTSTRAP_SCRIPT)

help:
	@echo "Available targets:"
	@echo "  pure, base, full     - change bootstrap mode in Vagrantfile"
	@echo "  status               - show current bootstrap mode"
	@echo "  set-version [x.yy]   - set Kubernetes version in bootstrap.sh"
	@echo "                         (use 'VER=x.yy' or just 'x.yy' as argument)"
	@echo "  get-version          - show current Kubernetes version"
	@echo "  help                 - show this help"
