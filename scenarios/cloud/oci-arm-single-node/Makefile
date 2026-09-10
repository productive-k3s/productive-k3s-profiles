.PHONY: tofu-init infra-up infra-down preflight cluster-up stack-up validate up down status clean test-clean test-checkstatus test-static test-contract test-live scenario-test-static scenario-test-contract scenario-test-live

.EXPORT_ALL_VARIABLES:

SCENARIO_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
export SCENARIO_DIR
export CASE_PREFIX := OCI
PRODUCTIVE_K3S_INFRA_REPO_DIR ?= $(shell candidate="$(abspath $(SCENARIO_DIR)/../../../productive-k3s-infra)"; if [ -d "$$candidate/tests" ] && [ -d "$$candidate/scripts" ]; then printf '%s' "$$candidate"; fi)
GENERATED_DIR := $(SCENARIO_DIR)/generated
SCRIPTS_DIR := $(SCENARIO_DIR)/scripts
SHARED_SCRIPTS_DIR := $(if $(wildcard $(SCENARIO_DIR)/../../../ansible/roles/remote_cluster/files/common.sh),$(SCENARIO_DIR)/../../../ansible/roles/remote_cluster/files,$(PRODUCTIVE_K3S_INFRA_REPO_DIR)/ansible/roles/remote_cluster/files)
TESTS_DIR := $(SCENARIO_DIR)/../../../tests
DEV_SCRIPTS_DIR := $(SCENARIO_DIR)/../../../scripts
REMOTE_TESTS_DIR := $(if $(wildcard $(TESTS_DIR)/test-remote-telemetry-consent.sh),$(TESTS_DIR),$(PRODUCTIVE_K3S_INFRA_REPO_DIR)/tests)
export REMOTE_CLUSTER_REFRESH_SCRIPT := $(SCRIPTS_DIR)/refresh-generated-artifacts.sh
OPENTOFU_DIR := $(SCENARIO_DIR)/opentofu
OCI_ENV_FILE ?= $(SCENARIO_DIR)/oci.env
TOFU_BIN ?= $(shell if command -v tofu >/dev/null 2>&1; then echo tofu; elif command -v terraform >/dev/null 2>&1; then echo terraform; fi)

-include $(OCI_ENV_FILE)

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
TELEMETRY_USER_AGENT ?= productive-k3s-profiles/oci-arm-single-node

OCI_COMPARTMENT_OCID ?=
OCI_REGION ?= us-ashburn-1
OCI_AVAILABILITY_DOMAIN ?=
OCI_CLUSTER_NAME ?= productive-k3s-oci-arm
OCI_SHAPE ?= VM.Standard.A1.Flex
OCI_OCPUS ?= 4
OCI_MEMORY_IN_GBS ?= 24
OCI_BOOT_VOLUME_SIZE_GB ?= 100
OCI_IMAGE_OCID ?=
OCI_SSH_PUBLIC_KEY_PATH ?=
OCI_SSH_PRIVATE_KEY_PATH ?=
OCI_SSH_USER ?= ubuntu
OCI_SSH_PORT ?= 22
OCI_SSH_ALLOWED_CIDR ?= 0.0.0.0/0
OCI_HTTP_ALLOWED_CIDR ?= 0.0.0.0/0
OCI_API_ALLOWED_CIDR ?= 0.0.0.0/0
OCI_BASE_DOMAIN ?= k3s.lab.internal
OCI_RANCHER_HOST ?= rancher.$(OCI_BASE_DOMAIN)
OCI_REGISTRY_HOST ?= registry.$(OCI_BASE_DOMAIN)
OCI_REMOTE_DIR ?= /home/ubuntu/productive-k3s-core

export TF_VAR_compartment_ocid := $(OCI_COMPARTMENT_OCID)
export TF_VAR_region := $(OCI_REGION)
export TF_VAR_availability_domain := $(OCI_AVAILABILITY_DOMAIN)
export TF_VAR_cluster_name := $(OCI_CLUSTER_NAME)
export TF_VAR_shape := $(OCI_SHAPE)
export TF_VAR_ocpus := $(OCI_OCPUS)
export TF_VAR_memory_in_gbs := $(OCI_MEMORY_IN_GBS)
export TF_VAR_boot_volume_size_gb := $(OCI_BOOT_VOLUME_SIZE_GB)
export TF_VAR_image_ocid := $(OCI_IMAGE_OCID)
export TF_VAR_ssh_public_key_path := $(OCI_SSH_PUBLIC_KEY_PATH)
export TF_VAR_ssh_user := $(OCI_SSH_USER)
export TF_VAR_ssh_allowed_cidr := $(OCI_SSH_ALLOWED_CIDR)
export TF_VAR_http_allowed_cidr := $(OCI_HTTP_ALLOWED_CIDR)
export TF_VAR_api_allowed_cidr := $(OCI_API_ALLOWED_CIDR)
export TF_VAR_base_domain := $(OCI_BASE_DOMAIN)
export TF_VAR_remote_dir := $(OCI_REMOTE_DIR)

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
	TEST_SCENARIO=oci-arm-single-node $(DEV_SCRIPTS_DIR)/productive-k3s-infra-dev.sh test-clean

test-checkstatus:
	TEST_SCENARIO=oci-arm-single-node $(DEV_SCRIPTS_DIR)/productive-k3s-infra-dev.sh test-checkstatus

test-static:
	bash $(TESTS_DIR)/run-scenario-test.sh static oci-arm-single-node $(SCENARIO_DIR) scenario-test-static

test-contract:
	bash $(TESTS_DIR)/run-scenario-test.sh contract oci-arm-single-node $(SCENARIO_DIR) scenario-test-contract

test-live:
	bash $(TESTS_DIR)/run-scenario-test.sh live oci-arm-single-node $(SCENARIO_DIR) scenario-test-live

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
	$(TESTS_DIR)/cloud-contract-check.sh oci-arm-single-node

scenario-test-live:
	@echo "[SKIP] oci-arm-single-node live test requires OCI credentials, image OCID, and quota"
	@exit 3

clean:
	rm -f $(GENERATED_DIR)/cluster.json
	rm -f $(GENERATED_DIR)/hosts.yml
	rm -f $(GENERATED_DIR)/nodes.env
	rm -f $(GENERATED_DIR)/server-token.txt
	rm -f $(GENERATED_DIR)/server-url.txt
	rm -f $(GENERATED_DIR)/tofu-outputs.json
	rm -rf $(GENERATED_DIR)/logs
