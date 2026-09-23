SHELL := /bin/bash

DEV_WRAPPER := ../scripts/productive-k3s-profiles-dev.sh

.PHONY: test-static test-contract test-live test-matrix test-live-matrix test-matrix-raw test-live-matrix-raw test-checkstatus test-checkstatus-matrix test-checkstatus-live test-logs-clean test-clean-artifacts test-clean cloud-contract-check onprem-remote-bootstrap-runner-check

test-static:
	PROFILE="$(PROFILE)" SCENARIO="$(SCENARIO)" INFRA_VERSION="$(INFRA_VERSION)" PRODUCTIVE_K3S_INFRA_REPO_DIR="$(PRODUCTIVE_K3S_INFRA_REPO_DIR)" PRODUCTIVE_K3S_INFRA_REPO_URL="$(PRODUCTIVE_K3S_INFRA_REPO_URL)" PRODUCTIVE_K3S_INFRA_REPO_REF="$(PRODUCTIVE_K3S_INFRA_REPO_REF)" bash $(DEV_WRAPPER) test-static

test-contract:
	PROFILE="$(PROFILE)" SCENARIO="$(SCENARIO)" INFRA_VERSION="$(INFRA_VERSION)" PRODUCTIVE_K3S_INFRA_REPO_DIR="$(PRODUCTIVE_K3S_INFRA_REPO_DIR)" PRODUCTIVE_K3S_INFRA_REPO_URL="$(PRODUCTIVE_K3S_INFRA_REPO_URL)" PRODUCTIVE_K3S_INFRA_REPO_REF="$(PRODUCTIVE_K3S_INFRA_REPO_REF)" bash $(DEV_WRAPPER) test-contract

test-live:
	PROFILE="$(PROFILE)" SCENARIO="$(SCENARIO)" INFRA_VERSION="$(INFRA_VERSION)" PRODUCTIVE_K3S_INFRA_REPO_DIR="$(PRODUCTIVE_K3S_INFRA_REPO_DIR)" PRODUCTIVE_K3S_INFRA_REPO_URL="$(PRODUCTIVE_K3S_INFRA_REPO_URL)" PRODUCTIVE_K3S_INFRA_REPO_REF="$(PRODUCTIVE_K3S_INFRA_REPO_REF)" bash $(DEV_WRAPPER) test-live

test-matrix:
	INFRA_VERSION="$(INFRA_VERSION)" PRODUCTIVE_K3S_INFRA_REPO_DIR="$(PRODUCTIVE_K3S_INFRA_REPO_DIR)" PRODUCTIVE_K3S_INFRA_REPO_URL="$(PRODUCTIVE_K3S_INFRA_REPO_URL)" PRODUCTIVE_K3S_INFRA_REPO_REF="$(PRODUCTIVE_K3S_INFRA_REPO_REF)" bash $(DEV_WRAPPER) test-matrix

onprem-remote-bootstrap-runner-check:
	bash ./test-onprem-remote-bootstrap-runner.sh

test-live-matrix:
	INFRA_VERSION="$(INFRA_VERSION)" PRODUCTIVE_K3S_INFRA_REPO_DIR="$(PRODUCTIVE_K3S_INFRA_REPO_DIR)" PRODUCTIVE_K3S_INFRA_REPO_URL="$(PRODUCTIVE_K3S_INFRA_REPO_URL)" PRODUCTIVE_K3S_INFRA_REPO_REF="$(PRODUCTIVE_K3S_INFRA_REPO_REF)" bash $(DEV_WRAPPER) test-live-matrix

test-matrix-raw:
	$(MAKE) onprem-remote-bootstrap-runner-check
	bash ./common.sh test-matrix

test-live-matrix-raw:
	bash ./common.sh test-live-matrix

cloud-contract-check:
	bash ./cloud-contract-check.sh "$(SCENARIO)"

test-checkstatus:
	bash $(DEV_WRAPPER) test-checkstatus

test-checkstatus-matrix:
	bash $(DEV_WRAPPER) test-checkstatus-matrix

test-checkstatus-live:
	bash $(DEV_WRAPPER) test-checkstatus-live

test-clean-artifacts:
	bash $(DEV_WRAPPER) test-clean-artifacts

test-logs-clean: test-clean-artifacts
	rm -rf ../runs ../coverage ../htmlcov ../.pytest_cache ../.coverage coverage htmlcov .pytest_cache .coverage
	rm -f ../coverage.out ../coverage.txt ../coverage.xml coverage.out coverage.txt coverage.xml

test-clean:
	bash $(DEV_WRAPPER) test-clean
