#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - <<'PY' "${ROOT_DIR}"
import importlib.util
import sys
from pathlib import Path

root = Path(sys.argv[1])
scenario = root / "scenarios/local/multipass"
bootstrap_path = scenario / "scripts/bootstrap-stack.sh"
push_core_path = scenario / "scripts/push-productive-k3s-core.sh"
runner_path = scenario / "scripts/run_bootstrap_session.py"

bootstrap_source = bootstrap_path.read_text(encoding="utf-8")
push_core_source = push_core_path.read_text(encoding="utf-8")
runner_source = runner_path.read_text(encoding="utf-8")

assert 'case "${PRODUCTIVE_K3S_SOURCE_RESOLVED}" in' in bootstrap_source
assert 'mktemp "${HOME}/pk3s-stack-artifact-XXXXXX.tgz"' in bootstrap_source
assert '--stack base --output "${stack_artifact_local_tgz}"' in bootstrap_source
assert 'chmod 0644 "${stack_artifact_local_tgz}"' in bootstrap_source
assert 'mp_transfer_to "${stack_artifact_local_tgz}"' in bootstrap_source
assert 'curl -fsSL' in bootstrap_source
assert '--stack-tgz "${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}"' in bootstrap_source
assert "productive-k3s-addons.tgz" not in push_core_source

for legacy_arg in [
    "--rancher-host",
    "--registry-host",
    "--rancher-password",
    "--registry-size",
    "--longhorn-data-path",
    "--longhorn-replica-count",
]:
    assert legacy_arg not in bootstrap_source, f"Multipass bootstrap still passes {legacy_arg}"

spec = importlib.util.spec_from_file_location("multipass_runner", runner_path)
runner = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(runner)


class Args:
    mode = "stack"
    remote_dir = "/home/ubuntu/productive-k3s-core"
    stack_tgz = "/tmp/productive-k3s-base-stack.tgz"


args = Args()
assert runner.select_prompt_map(args) == []
assert runner.build_stack_artifact_answers() == "y\ny\ny\ny\ny\n"
remote_script = runner.build_remote_script(args)
assert 'bootstrap_answers_file="$(mktemp)"' in remote_script
assert "unset PRODUCTIVE_K3S_ADDONS_REPO_DIR" in remote_script
assert "PRODUCTIVE_K3S_AUTO_APPROVE_PREFLIGHT_WARNINGS=true" in remote_script
assert "./productive-k3s-core.sh stack install --tgz /tmp/productive-k3s-base-stack.tgz" in remote_script

for component in ["Longhorn", "Rancher hostname", "Registry hostname", "cert-manager"]:
    assert component not in runner_source, f"Multipass runner still knows component prompt: {component}"

print("[PASS] Multipass stack handoff is artifact-only")
PY
