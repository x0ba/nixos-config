# Darwin: LocalHostName → darwinConfigurations.<host>
# Linux: homeConfigurations.tp
UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
HOST ?= $(shell scutil --get LocalHostName 2>/dev/null || hostname -s)
else
HOST ?= tp
endif

FLAKE := $(CURDIR)#$(HOST)

.DEFAULT_GOAL := help

.PHONY: help build check fmt switch update

help:
	@printf '%s\n' \
		'make build   build $(HOST) without activating' \
		'make check   format check + flake check' \
		'make fmt     format nix files' \
		'make switch  build and activate $(HOST)' \
		'make update  update flake.lock'

ifeq ($(UNAME),Darwin)
build:
	darwin-rebuild build --flake $(FLAKE)

switch:
	sudo --preserve-env=PATH darwin-rebuild switch --flake $(FLAKE)
else
build:
	nix build --no-link $(CURDIR)#homeConfigurations.$(HOST).activationPackage

switch:
	nix run $(CURDIR)#home-manager -- switch -b backup --flake $(FLAKE)
endif

check:
	nix fmt -- --ci
	nix flake check

fmt:
	nix fmt

update:
	nix flake update
