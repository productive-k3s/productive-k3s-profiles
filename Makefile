.PHONY: docs-build docs-serve docs-up docs-down docs-clean test-static test-contract test-live test-matrix test-live-matrix

SCRIPTS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))/scripts

docs-build:
	$(SCRIPTS_DIR)/productive-k3s-profiles-dev.sh docs-build

docs-serve:
	$(SCRIPTS_DIR)/productive-k3s-profiles-dev.sh docs-serve

docs-up:
	$(SCRIPTS_DIR)/productive-k3s-profiles-dev.sh docs-up

docs-down:
	$(SCRIPTS_DIR)/productive-k3s-profiles-dev.sh docs-down

docs-clean:
	$(SCRIPTS_DIR)/productive-k3s-profiles-dev.sh docs-clean

test-static:
	PROFILE="$(PROFILE)" SCENARIO="$(SCENARIO)" INFRA_VERSION="$(INFRA_VERSION)" PRODUCTIVE_K3S_INFRA_REPO_DIR="$(PRODUCTIVE_K3S_INFRA_REPO_DIR)" $(SCRIPTS_DIR)/productive-k3s-profiles-dev.sh test-static

test-contract:
	PROFILE="$(PROFILE)" SCENARIO="$(SCENARIO)" INFRA_VERSION="$(INFRA_VERSION)" PRODUCTIVE_K3S_INFRA_REPO_DIR="$(PRODUCTIVE_K3S_INFRA_REPO_DIR)" $(SCRIPTS_DIR)/productive-k3s-profiles-dev.sh test-contract

test-live:
	PROFILE="$(PROFILE)" SCENARIO="$(SCENARIO)" INFRA_VERSION="$(INFRA_VERSION)" PRODUCTIVE_K3S_INFRA_REPO_DIR="$(PRODUCTIVE_K3S_INFRA_REPO_DIR)" $(SCRIPTS_DIR)/productive-k3s-profiles-dev.sh test-live

test-matrix:
	INFRA_VERSION="$(INFRA_VERSION)" PRODUCTIVE_K3S_INFRA_REPO_DIR="$(PRODUCTIVE_K3S_INFRA_REPO_DIR)" $(SCRIPTS_DIR)/productive-k3s-profiles-dev.sh test-matrix

test-live-matrix:
	INFRA_VERSION="$(INFRA_VERSION)" PRODUCTIVE_K3S_INFRA_REPO_DIR="$(PRODUCTIVE_K3S_INFRA_REPO_DIR)" $(SCRIPTS_DIR)/productive-k3s-profiles-dev.sh test-live-matrix
