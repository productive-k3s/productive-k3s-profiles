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
        mode = "stack"
        base_domain = "k3s.lab.internal"
        rancher_host = "rancher.k3s.lab.internal"
        registry_host = "registry.k3s.lab.internal"
        rancher_password = "admin"
        registry_size = "20Gi"
        longhorn_data_path = "/data"
        longhorn_replica_count = 1

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

for bootstrap_stack_path in bootstrap_stack_paths:
    bootstrap_stack = bootstrap_stack_path.read_text(encoding="utf-8")
    assert "Downloading published stack artifact on controller" in bootstrap_stack, f"{bootstrap_stack_path} must download the published stack artifact in remote mode"
    assert "PRODUCTIVE_K3S_STACK_TGZ_URL_RESOLVED" in bootstrap_stack, f"{bootstrap_stack_path} must use the resolved stack artifact URL"
    assert "PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED" in bootstrap_stack, f"{bootstrap_stack_path} must use the resolved remote stack artifact path"
    assert "stack_tgz_arg=(--stack-tgz" in bootstrap_stack, f"{bootstrap_stack_path} must pass the uploaded stack artifact to the remote runner"

print("[PASS] onprem remote bootstrap runners cover Longhorn ordered prompts")
PY
