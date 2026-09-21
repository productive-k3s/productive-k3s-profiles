.PHONY: tofu-init infra-up infra-down preflight cluster-up stack-up validate up down status clean test-clean test-checkstatus test-static test-contract test-live scenario-test-static scenario-test-contract scenario-test-live

.EXPORT_ALL_VARIABLES:

SCENARIO_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
export SCENARIO_DIR
export CASE_PREFIX := HETZNER
PRODUCTIVE_K3S_INFRA_REPO_DIR ?= $(shell candidate="$(abspath $(SCENARIO_DIR)/../../../productive-k3s-infra)"; if [ -d "$$candidate/tests" ] && [ -d "$$candidate/scripts" ]; then printf '%s' "$$candidate"; fi)
GENERATED_DIR := $(SCENARIO_DIR)/generated
SCRIPTS_DIR := $(SCENARIO_DIR)/scripts
SHARED_SCRIPTS_DIR := $(if $(wildcard $(SCENARIO_DIR)/../../../ansible/roles/remote_cluster/files/common.sh),$(SCENARIO_DIR)/../../../ansible/roles/remote_cluster/files,$(PRODUCTIVE_K3S_INFRA_REPO_DIR)/ansible/roles/remote_cluster/files)
TESTS_DIR := $(SCENARIO_DIR)/../../../tests
DEV_SCRIPTS_DIR := $(SCENARIO_DIR)/../../../scripts
REMOTE_TESTS_DIR := $(if $(wildcard $(TESTS_DIR)/test-remote-telemetry-consent.sh),$(TESTS_DIR),$(PRODUCTIVE_K3S_INFRA_REPO_DIR)/tests)
export REMOTE_CLUSTER_REFRESH_SCRIPT := $(SCRIPTS_DIR)/refresh-generated-artifacts.sh
OPENTOFU_DIR := $(SCENARIO_DIR)/opentofu
HETZNER_ENV_FILE ?= $(SCENARIO_DIR)/hetzner.env
TOFU_BIN ?= $(shell if command -v tofu >/dev/null 2>&1; then echo tofu; elif command -v terraform >/dev/null 2>&1; then echo terraform; fi)

-include $(HETZNER_ENV_FILE)

PRODUCTIVE_K3S_REPO ?= $(shell candidate="$(abspath $(SCENARIO_DIR)/../../../productive-k3s-core)"; if [ -d "$$candidate" ]; then printf '%s' "$$candidate"; fi)
PRODUCTIVE_K3S_SOURCE ?= remote
PRODUCTIVE_K3S_VERSION ?=
PRODUCTIVE_K3S_RELEASE_REPO ?= productive-k3s/productive-k3s-core
TELEMETRY_ENABLED ?=
TELEMETRY_ENDPOINT ?=
TELEMETRY_MAX_RETRIES ?= 3
TELEMETRY_CONNECT_TIMEOUT_SECONDS ?= 5
TELEMETRY_REQUEST_TIMEOUT_SECONDS ?= 10
TELEMETRY_OUTBOX_DIR ?=
TELEMETRY_USER_AGENT ?= productive-k3s-profiles/hetzner-single-node

HETZNER_CLUSTER_NAME ?= productive-k3s-hetzner
HETZNER_LOCATION ?= fsn1
HETZNER_SERVER_TYPE ?= cx32
HETZNER_IMAGE ?= ubuntu-24.04
HETZNER_SSH_KEY_NAME ?= productive-k3s
HETZNER_SSH_PUBLIC_KEY_PATH ?=
HETZNER_SSH_PRIVATE_KEY_PATH ?=
HETZNER_SSH_USER ?= root
HETZNER_SSH_PORT ?= 22
HETZNER_SSH_ALLOWED_CIDR ?= 0.0.0.0/0
HETZNER_HTTP_ALLOWED_CIDR ?= 0.0.0.0/0
HETZNER_API_ALLOWED_CIDR ?= 0.0.0.0/0
HETZNER_BASE_DOMAIN ?= k3s.lab.internal
HETZNER_RANCHER_HOST ?= rancher.$(HETZNER_BASE_DOMAIN)
HETZNER_REGISTRY_HOST ?= registry.$(HETZNER_BASE_DOMAIN)
HETZNER_REMOTE_DIR ?= /root/productive-k3s-core

export TF_VAR_hcloud_token := $(HCLOUD_TOKEN)
export TF_VAR_cluster_name := $(HETZNER_CLUSTER_NAME)
export TF_VAR_location := $(HETZNER_LOCATION)
export TF_VAR_server_type := $(HETZNER_SERVER_TYPE)
export TF_VAR_image := $(HETZNER_IMAGE)
export TF_VAR_ssh_key_name := $(HETZNER_SSH_KEY_NAME)
export TF_VAR_ssh_public_key_path := $(HETZNER_SSH_PUBLIC_KEY_PATH)
export TF_VAR_ssh_user := $(HETZNER_SSH_USER)
export TF_VAR_ssh_allowed_cidr := $(HETZNER_SSH_ALLOWED_CIDR)
export TF_VAR_http_allowed_cidr := $(HETZNER_HTTP_ALLOWED_CIDR)
export TF_VAR_api_allowed_cidr := $(HETZNER_API_ALLOWED_CIDR)
export TF_VAR_base_domain := $(HETZNER_BASE_DOMAIN)
export TF_VAR_remote_dir := $(HETZNER_REMOTE_DIR)

tofu-init:
	$(TOFU_BIN) -chdir=$(OPENTOFU_DIR) init

infra-up: tofu-init
	$(TOFU_BIN) -chdir=$(OPENTOFU_DIR) apply -auto-approve
	$(SCRIPTS_DIR)/refresh-generated-artifacts.sh

infra-down: tofu-init
	$(TOFU_BIN) -chdir=$(OPENTOFU_DIR) destroy -auto-approve

preflight:
	$(SCRIPTS_DIR)/refresh-generated-artifacts.sh
	$(SHARED_SCRIPTS_DIR)/preflight.sh
	$(SHARED_SCRIPTS_DIR)/push-productive-k3s-core.sh
	bash $(SHARED_SCRIPTS_DIR)/preflight-productive-k3s-core.sh

cluster-up:
	$(SHARED_SCRIPTS_DIR)/cluster-up.sh

stack-up:
	$(SCRIPTS_DIR)/refresh-generated-artifacts.sh
	$(SHARED_SCRIPTS_DIR)/bootstrap-stack.sh

validate:
	$(SCRIPTS_DIR)/refresh-generated-artifacts.sh
	$(SHARED_SCRIPTS_DIR)/validate-cluster.sh

up: infra-up cluster-up validate

down: infra-down clean

status:
	@if [ -d "$(OPENTOFU_DIR)/.terraform" ] || [ -f "$(OPENTOFU_DIR)/terraform.tfstate" ]; then \
		$(SCRIPTS_DIR)/refresh-generated-artifacts.sh; \
	fi
	@cat $(GENERATED_DIR)/cluster.json

test-clean:
	TEST_SCENARIO=hetzner-single-node $(DEV_SCRIPTS_DIR)/productive-k3s-infra-dev.sh test-clean

test-checkstatus:
	TEST_SCENARIO=hetzner-single-node $(DEV_SCRIPTS_DIR)/productive-k3s-infra-dev.sh test-checkstatus

test-static:
	bash $(TESTS_DIR)/run-scenario-test.sh static hetzner-single-node $(SCENARIO_DIR) scenario-test-static

test-contract:
	bash $(TESTS_DIR)/run-scenario-test.sh contract hetzner-single-node $(SCENARIO_DIR) scenario-test-contract

test-live:
	bash $(TESTS_DIR)/run-scenario-test.sh live hetzner-single-node $(SCENARIO_DIR) scenario-test-live

scenario-test-static: tofu-init
	bash -n $(SHARED_SCRIPTS_DIR)/*.sh $(SCRIPTS_DIR)/*.sh
	python3 -m py_compile $(SHARED_SCRIPTS_DIR)/run_remote_bootstrap_session.py
	$(TOFU_BIN) -chdir=$(OPENTOFU_DIR) init -backend=false
	$(TOFU_BIN) -chdir=$(OPENTOFU_DIR) validate
	$(MAKE) -n up TOFU_BIN=$(TOFU_BIN) >/dev/null
	@test -f "$(REMOTE_TESTS_DIR)/test-remote-telemetry-consent.sh" || { echo "missing infra shared test: $(REMOTE_TESTS_DIR)/test-remote-telemetry-consent.sh" >&2; exit 1; }
	@test -f "$(REMOTE_TESTS_DIR)/test-remote-cluster-up-preserves-telemetry.sh" || { echo "missing infra shared test: $(REMOTE_TESTS_DIR)/test-remote-cluster-up-preserves-telemetry.sh" >&2; exit 1; }
	bash $(REMOTE_TESTS_DIR)/test-remote-telemetry-consent.sh
	bash $(REMOTE_TESTS_DIR)/test-remote-cluster-up-preserves-telemetry.sh

scenario-test-contract:
	$(TESTS_DIR)/cloud-contract-check.sh hetzner-single-node

scenario-test-live:
	@echo "[SKIP] hetzner-single-node live test requires Hetzner Cloud credentials and quota"
	@exit 3

clean:
	rm -f $(GENERATED_DIR)/cluster.json
	rm -f $(GENERATED_DIR)/hosts.yml
	rm -f $(GENERATED_DIR)/nodes.env
	rm -f $(GENERATED_DIR)/server-token.txt
	rm -f $(GENERATED_DIR)/server-url.txt
	rm -f $(GENERATED_DIR)/tofu-outputs.json
	rm -rf $(GENERATED_DIR)/logs
