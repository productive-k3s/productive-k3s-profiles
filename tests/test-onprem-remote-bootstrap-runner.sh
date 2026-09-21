#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - <<'PY' "${ROOT_DIR}"
import importlib.util
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

for script_path in script_paths:
    spec = importlib.util.spec_from_file_location("runner", script_path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)

    class Args:
        host = "127.0.0.1"
        user = "ubuntu"
        port = "22"
        key_path = ""
        extra_opts = ""
        mode = "stack"
        remote_dir = "/home/ubuntu/productive-k3s"
        base_domain = "k3s.lab.internal"
        rancher_host = "rancher.k3s.lab.internal"
        registry_host = "registry.k3s.lab.internal"
        rancher_password = "admin"
        registry_size = "20Gi"
        longhorn_data_path = "/data"
        longhorn_replica_count = 1
        stack_tgz = ""

    prompts = module.build_prompt_map(Args())
    prompt_map = dict(prompts)

    minimal_prompt = "Longhorn storage minimal available percentage (10 is recommended for single-node dev/lab)"
    assert prompt_map[minimal_prompt] == "10", f"{script_path} must explicitly answer the Longhorn minimal percentage prompt"
    assert module.prompt_uses_ordered_detail_fallback("stack", minimal_prompt), f"{script_path} must treat Longhorn minimal percentage as ordered detail"

    prompt_names = [prompt for prompt, _ in prompts]
    replica_index = prompt_names.index("Longhorn default replica count (1 for single-node)")
    minimal_index = prompt_names.index(minimal_prompt)
    default_sc_index = prompt_names.index("Make Longhorn the default StorageClass?")
    assert replica_index < minimal_index < default_sc_index, f"{script_path} must keep the Longhorn ordered prompt chain contiguous"

    for prompt in [
        "Longhorn preflight found warnings. Continue anyway?",
        "Install the missing packages for Longhorn?",
        "Enable and start 'iscsid' now?",
    ]:
        assert not module.mode_allows_proactive_prompt_answer(
            "stack",
            prompt,
        ), f"{script_path} must wait for explicit runtime prompt output before answering: {prompt}"

    assert "Longhorn preflight found warnings. Continue anyway?" in prompt_names, f"{script_path} should keep the Longhorn preflight prompt in regular stack mode"
    Args.stack_tgz = "/tmp/productive-k3s-base-stack.tgz"
    stack_tgz_prompt_names = [prompt for prompt, _ in module.build_prompt_map(Args())]
    assert "Longhorn preflight found warnings. Continue anyway?" not in stack_tgz_prompt_names, f"{script_path} must omit the auto-approved Longhorn preflight prompt in stack artifact mode"
    assert "Install the missing packages for Longhorn?" in stack_tgz_prompt_names, f"{script_path} must still answer Longhorn package prompts in stack artifact mode"
    assert "Enable and start 'iscsid' now?" in stack_tgz_prompt_names, f"{script_path} must still answer iscsid prompts in stack artifact mode"
    assert module.select_prompt_map(Args()) == [], f"{script_path} must not use prompt-detection pending prompts in stack artifact mode"
    ssh_command = module.build_ssh_command(Args())
    remote_script = module.build_remote_script(Args())
    assert "-tt" not in ssh_command, f"{script_path} must not allocate a pseudo-TTY in stack artifact mode"
    assert "bootstrap_answers_file=\"$(mktemp)\"" in remote_script, f"{script_path} must create a deterministic answers file in stack artifact mode"
    assert "PRODUCTIVE_K3S_AUTO_APPROVE_PREFLIGHT_WARNINGS=true" in remote_script, f"{script_path} must preserve Core preflight auto-approval"
    assert "./productive-k3s-core.sh stack install --tgz /tmp/productive-k3s-base-stack.tgz < \"${bootstrap_answers_file}\"" in remote_script, f"{script_path} must feed Core from the answers file in stack artifact mode"
    Args.stack_tgz = ""
    assert "-tt" in module.build_ssh_command(Args()), f"{script_path} must keep pseudo-TTY allocation for regular interactive stack mode"

for bootstrap_stack_path in bootstrap_stack_paths:
    bootstrap_stack = bootstrap_stack_path.read_text(encoding="utf-8")
    assert "Downloading published stack artifact on controller" in bootstrap_stack, f"{bootstrap_stack_path} must download the published stack artifact in remote mode"
    assert "PRODUCTIVE_K3S_STACK_TGZ_URL_RESOLVED" in bootstrap_stack, f"{bootstrap_stack_path} must use the resolved stack artifact URL"
    assert "PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED" in bootstrap_stack, f"{bootstrap_stack_path} must use the resolved remote stack artifact path"
    assert "stack_tgz_arg=(--stack-tgz" in bootstrap_stack, f"{bootstrap_stack_path} must pass the uploaded stack artifact to the remote runner"

print("[PASS] onprem remote bootstrap runners cover Longhorn ordered prompts")
PY
