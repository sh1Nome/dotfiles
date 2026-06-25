.PHONY: help build-zk install-zk uninstall-zk mkdir-local-bin install-claude uninstall-claude install-rust uninstall-rust

UNAME_S := $(shell uname -s)

ifneq (,$(findstring MINGW,$(UNAME_S)))
	MAKE_CMD ?= mingw32-make
else
	MAKE_CMD ?= make
endif

help:
	@echo "install-zk       Install zk"
	@echo "uninstall-zk     Uninstall zk"
	@echo "install-claude   Install Claude Code"
	@echo "uninstall-claude Uninstall Claude Code"
	@echo "install-rust     Install Rust via rustup"
	@echo "uninstall-rust   Uninstall Rust via rustup"
ifeq ($(UNAME_S),Linux)
	@echo "install-keyd     Install keyd"
	@echo "uninstall-keyd   Uninstall keyd"
endif

mkdir-local-bin:
	mkdir -p ~/.local/bin


ZK_REPO ?= https://github.com/zk-org/zk.git
ZK_BUILD_DIR := .zk-build

ifneq (,$(findstring MINGW,$(UNAME_S)))
	ZK_BINARY = $(ZK_BUILD_DIR)/zk.exe
else
	ZK_BINARY = $(ZK_BUILD_DIR)/zk
endif

install-zk: mkdir-local-bin
	git clone $(ZK_REPO) $(ZK_BUILD_DIR)
	cd $(ZK_BUILD_DIR) && $(MAKE_CMD) build
	mv $(ZK_BINARY) ~/.local/bin/
	rm -rf ./$(ZK_BUILD_DIR)

uninstall-zk:
	rm -f ~/.local/bin/zk*


install-claude:
ifeq ($(OS),Windows_NT)
	powershell -Command "irm https://claude.ai/install.ps1 | iex"
else
	curl -fsSL https://claude.ai/install.sh | bash
endif

uninstall-claude:
	rm -f ~/.local/bin/claude
	rm -rf ~/.local/share/claude


install-rust:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

uninstall-rust:
	@if command -v rustup >/dev/null 2>&1; then \
		rustup self uninstall; \
	else \
		echo "rustup not found, skipping"; \
	fi


ifeq ($(UNAME_S),Linux)
.PHONY: install-keyd uninstall-keyd

KEYD_REPO ?= https://github.com/rvaiya/keyd.git
KEYD_BUILD_DIR := .keyd-build

install-keyd:
	git clone $(KEYD_REPO) $(KEYD_BUILD_DIR)
	cd $(KEYD_BUILD_DIR) && make && sudo make install
	sudo systemctl enable --now keyd
	rm -rf ./$(KEYD_BUILD_DIR)

uninstall-keyd:
	sudo systemctl disable --now keyd
	git clone $(KEYD_REPO) $(KEYD_BUILD_DIR)
	cd $(KEYD_BUILD_DIR) && sudo make uninstall
	sudo systemctl daemon-reload
	rm -rf ./$(KEYD_BUILD_DIR)
endif
