#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - <<'PY' "${ROOT_DIR}"
import importlib.util
import os
import sys
from pathlib import Path

root = Path(sys.argv[1])
script_paths = [
    root / "scenarios/edge/onprem-basic/scripts/run_remote_bootstrap_session.py",
    root / "scenarios/edge/onprem-basic-arm/scripts/run_remote_bootstrap_session.py",
]
bootstrap_stack_paths = [
    root / "scenarios/edge/onprem-basic/scripts/bootstrap-stack.sh",
    root / "scenarios/edge/onprem-basic-arm/scripts/bootstrap-stack.sh",
]
push_core_paths = [
    root / "scenarios/edge/onprem-basic/scripts/push-productive-k3s-core.sh",
    root / "scenarios/edge/onprem-basic-arm/scripts/push-productive-k3s-core.sh",
]

runner_sources = [path.read_text(encoding="utf-8") for path in script_paths]
assert runner_sources[0] == runner_sources[1], "on-prem scenarios must use identical remote bootstrap runners"

for script_path, runner_source in zip(script_paths, runner_sources):
    spec = importlib.util.spec_from_file_location("runner", script_path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)

    agent_prompt = "k3s agent was not detected. Install it now? [required]"
    assert not module.mode_allows_proactive_prompt_answer("agent", agent_prompt), (
        f"{script_path} must wait for state detection before proactive answers"
    )
    assert module.mode_allows_proactive_prompt_answer("agent", agent_prompt, {"k3s": "missing"}), (
        f"{script_path} must allow the matching prompt after state detection"
    )

    redactor = module.SensitiveOutputRedactor(["secret-token"])
    redacted_output = redactor.feed("before secret-token after")
    assert redacted_output == "before [REDACTED] after", (
        f"{script_path} must redact secrets from retained output"
    )

    class AgentArgs:
        host = "127.0.0.1"
        user = "ubuntu"
        port = "22"
        key_path = ""
        extra_opts = ""
        mode = "agent"
        remote_dir = "/home/ubuntu/productive-k3s"
        server_url = "https://10.0.0.10:6443"
        cluster_token = "secret-token"
        base_domain = "k3s.lab.internal"
        stack_tgz = None

    assert "stty -echo" in module.build_remote_script(AgentArgs()), (
        f"{script_path} must disable TTY echo before sending interactive secrets"
    )

    previous_idle_timeout = os.environ.get("PRODUCTIVE_K3S_REMOTE_BOOTSTRAP_IDLE_TIMEOUT_SECONDS")
    previous_total_timeout = os.environ.get("PRODUCTIVE_K3S_REMOTE_BOOTSTRAP_TOTAL_TIMEOUT_SECONDS")
    try:
        os.environ["PRODUCTIVE_K3S_REMOTE_BOOTSTRAP_IDLE_TIMEOUT_SECONDS"] = "30"
        os.environ["PRODUCTIVE_K3S_REMOTE_BOOTSTRAP_TOTAL_TIMEOUT_SECONDS"] = "120"
        assert module.session_timeout_reason("agent", 0, 80, 100) is None
        assert module.session_timeout_reason("agent", 0, 60, 100) == "no remote output for 30s"
        assert module.session_timeout_reason("agent", 0, 100, 120) == "total runtime exceeded 120s"
    finally:
        if previous_idle_timeout is None:
            os.environ.pop("PRODUCTIVE_K3S_REMOTE_BOOTSTRAP_IDLE_TIMEOUT_SECONDS", None)
        else:
            os.environ["PRODUCTIVE_K3S_REMOTE_BOOTSTRAP_IDLE_TIMEOUT_SECONDS"] = previous_idle_timeout
        if previous_total_timeout is None:
            os.environ.pop("PRODUCTIVE_K3S_REMOTE_BOOTSTRAP_TOTAL_TIMEOUT_SECONDS", None)
        else:
            os.environ["PRODUCTIVE_K3S_REMOTE_BOOTSTRAP_TOTAL_TIMEOUT_SECONDS"] = previous_total_timeout

    class Args:
        host = "127.0.0.1"
        user = "ubuntu"
        port = "22"
        key_path = ""
        extra_opts = ""
        mode = "stack"
        remote_dir = "/home/ubuntu/productive-k3s"
        base_domain = "k3s.lab.internal"
        stack_tgz = "/tmp/productive-k3s-base-stack.tgz"

    assert module.select_prompt_map(Args()) == [], f"{script_path} must keep stack execution artifact-only"
    ssh_command = module.build_ssh_command(Args())
    remote_script = module.build_remote_script(Args())
    assert "-tt" not in ssh_command, f"{script_path} must not allocate a pseudo-TTY in stack mode"
    assert "bootstrap_answers_file=\"$(mktemp)\"" in remote_script, f"{script_path} must use deterministic artifact input"
    assert "./productive-k3s-core.sh stack install --tgz /tmp/productive-k3s-base-stack.tgz" in remote_script

    forbidden_components = ["Longhorn", "Rancher hostname", "Registry hostname", "cert-manager"]
    for component in forbidden_components:
        assert component not in runner_source, f"{script_path} must not automate component-specific prompts: {component}"

for bootstrap_stack_path in bootstrap_stack_paths:
    bootstrap_stack = bootstrap_stack_path.read_text(encoding="utf-8")
    assert '--stack base --output "${stack_artifact_local_tgz}"' in bootstrap_stack
    assert '--stack-tgz "${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}"' in bootstrap_stack
    assert 'case "${PRODUCTIVE_K3S_SOURCE_RESOLVED}" in' in bootstrap_stack
    assert 'package_stack_script="${PRODUCTIVE_K3S_ADDONS_REPO_DIR}/scripts/package-stack.sh"' in bootstrap_stack
    for legacy_arg in [
        "--rancher-host",
        "--registry-host",
        "--rancher-password",
        "--registry-size",
        "--longhorn-data-path",
        "--longhorn-replica-count",
    ]:
        assert legacy_arg not in bootstrap_stack, f"{bootstrap_stack_path} still passes component argument {legacy_arg}"

for push_core_path in push_core_paths:
    push_core = push_core_path.read_text(encoding="utf-8")
    assert "productive-k3s-addons.tgz" not in push_core, (
        f"{push_core_path} must transfer the Core runtime only; stack add-ons travel in the packaged stack artifact"
    )

print("[PASS] onprem remote bootstrap runners are generic and state-safe")
PY
