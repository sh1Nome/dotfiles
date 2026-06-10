.PHONY: help build-zk install-zk uninstall-zk mkdir-usr-local-bin install-claude uninstall-claude

help:
	@echo "build-zk         Build zk from source"
	@echo "install-zk       Install zk to /usr/local/bin"
	@echo "uninstall-zk     Uninstall zk from /usr/local/bin"
	@echo "install-claude   Install Claude Code"
	@echo "uninstall-claude Uninstall Claude Code"

ZK_REPO ?= https://github.com/zk-org/zk.git
ZK_BUILD_DIR := .zk-build

UNAME_S := $(shell uname -s)
ifneq (,$(findstring MINGW,$(UNAME_S)))
	MAKE_CMD ?= mingw32-make
else
	MAKE_CMD ?= make
endif

ifneq (,$(findstring MINGW,$(UNAME_S)))
	ZK_BINARY = $(ZK_BUILD_DIR)/zk.exe
else
	ZK_BINARY = $(ZK_BUILD_DIR)/zk
endif

mkdir-usr-local-bin:
	mkdir -p /usr/local/bin

build-zk: $(ZK_BINARY)

$(ZK_BINARY):
	git clone $(ZK_REPO) $(ZK_BUILD_DIR)
	cd $(ZK_BUILD_DIR) && $(MAKE_CMD) build

install-zk: mkdir-usr-local-bin $(ZK_BINARY)
	mv $(ZK_BINARY) /usr/local/bin/
	rm -rf ./$(ZK_BUILD_DIR)

uninstall-zk:
	rm -f /usr/local/bin/zk*

install-claude:
ifeq ($(OS),Windows_NT)
	powershell -Command "irm https://claude.ai/install.ps1 | iex"
else
	curl -fsSL https://claude.ai/install.sh | bash
endif

uninstall-claude:
	rm -f ~/.local/bin/claude
	rm -rf ~/.local/share/claude
