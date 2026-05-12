.PHONY: help install-zk uninstall-zk mkdir-usr-local-bin

help:
	@echo "install-zk    Install zk to /usr/local/bin"
	@echo "uninstall-zk  Uninstall zk from /usr/local/bin"

ZK_REPO ?= https://github.com/zk-org/zk.git
ZK_BUILD_DIR := .zk-build

UNAME_S := $(shell uname -s)
ifneq (,$(findstring MINGW,$(UNAME_S)))
	MAKE_CMD ?= mingw32-make
else
	MAKE_CMD ?= make
endif

mkdir-usr-local-bin:
	mkdir -p /usr/local/bin

install-zk: mkdir-usr-local-bin
	git clone $(ZK_REPO) $(ZK_BUILD_DIR)
	cd $(ZK_BUILD_DIR) && $(MAKE_CMD) build
	mv $(ZK_BUILD_DIR)/zk* /usr/local/bin/
	rm -rf ./$(ZK_BUILD_DIR)

uninstall-zk:
	rm -f /usr/local/bin/zk*
