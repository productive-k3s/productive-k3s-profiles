#!/usr/bin/env python3
import argparse
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path


TELEMETRY_ENV_KEYS = [
    "TELEMETRY_ENABLED",
    "TELEMETRY_ENDPOINT",
    "TELEMETRY_MARKER",
    "TELEMETRY_BEARER_TOKEN",
    "TELEMETRY_MAX_RETRIES",
    "TELEMETRY_CONNECT_TIMEOUT_SECONDS",
    "TELEMETRY_REQUEST_TIMEOUT_SECONDS",
    "TELEMETRY_OUTBOX_DIR",
    "TELEMETRY_USER_AGENT",
    "TELEMETRY_SESSION_ID",
    "TELEMETRY_PARENT_RUN_ID",
    "TELEMETRY_COMPONENT",
]

ENGINE_ENV_KEYS = [
    "PRODUCTIVE_K3S_ENGINE",
    "PRODUCTIVE_K3S_AUTO_APPROVE_PREFLIGHT_WARNINGS",
    "PRODUCTIVE_K3S_AUTO_APPROVE_APPLY_PLAN",
    "PRODUCTIVE_K3S_SSH_HOST",
    "PRODUCTIVE_K3S_SSH_USER",
    "PRODUCTIVE_K3S_SSH_PORT",
    "PRODUCTIVE_K3S_SSH_KEY_PATH",
    "PRODUCTIVE_K3S_SSH_EXTRA_OPTS",
]

ANSI_ESCAPE_RE = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")
COMPLETION_MARKERS = ["[INFO] DONE. Quick checks:"]


def sanitize_prompt_buffer(value: str) -> str:
    value = ANSI_ESCAPE_RE.sub("", value)
    value = value.replace("\r", "")
    while "\b" in value:
        value = re.sub(r".\b", "", value, count=1)
    return value


def telemetry_env_prefix():
    assignments = []
    for key in TELEMETRY_ENV_KEYS + ENGINE_ENV_KEYS:
        value = os.environ.get(key)
        if value is None:
            continue
        assignments.append(f"{key}={shlex.quote(value)}")
    return " ".join(assignments)


def build_prompt_map(args):
    common = [
        ("Existing k3s installation detected. Continue using it without changes? [required]", "y"),
        ("k3s was not detected. Install it now? [required]", "y"),
        ("Helm is already installed. Continue using it without changes? [required]", "y"),
        ("Helm was not detected. Install it now? [required]", "y"),
        ("Proceed with this plan?", "y"),
    ]
    if args.mode == "server":
        return common
    if args.mode == "agent":
        return [
            ("Existing k3s agent installation detected. Continue using it without changes? [required]", "y"),
            ("k3s agent was not detected. Install it now? [required]", "y"),
            ("Agent server URL", args.server_url),
            ("Agent cluster token", args.cluster_token),
            ("Proceed with this plan?", "y"),
        ]
    if args.mode == "stack":
        raise ValueError("stack mode requires --stack-tgz")
    raise ValueError(f"unsupported mode: {args.mode}")


def uses_stack_artifact_stdin(args) -> bool:
    return args.mode == "stack" and bool(getattr(args, "stack_tgz", None))


def select_prompt_map(args):
    if uses_stack_artifact_stdin(args):
        return []
    return build_prompt_map(args)


def build_stack_artifact_answers() -> str:
    # Keep this sequence aligned with the generic Core stack artifact flow.
    return "\n".join(["y", "y", "y", "y", "y"]) + "\n"


def build_remote_script(args) -> str:
    remote_script = f"cd {shlex.quote(args.remote_dir)} && "
    telemetry_prefix = telemetry_env_prefix()
    if telemetry_prefix:
        remote_script += f"{telemetry_prefix} "
    if uses_stack_artifact_stdin(args):
        answers = shlex.quote(build_stack_artifact_answers())
        remote_script += (
            'bootstrap_answers_file="$(mktemp)" && '
            f"printf '%s' {answers} > \"${{bootstrap_answers_file}}\" && "
            "unset PRODUCTIVE_K3S_ADDONS_REPO_DIR && "
            "export PRODUCTIVE_K3S_AUTO_APPROVE_PREFLIGHT_WARNINGS=true && "
            f"./productive-k3s-core.sh stack install --tgz {shlex.quote(args.stack_tgz)} "
            '< "${bootstrap_answers_file}"; '
            'stack_rc=$?; rm -f "${bootstrap_answers_file}"; exit "${stack_rc}"'
        )
    else:
        remote_script += f"./scripts/apply.sh --mode {shlex.quote(args.mode)}"
    return remote_script


def prompt_group(prompt_text: str):
    groups = {
        "Existing k3s installation detected. Continue using it without changes? [required]": "k3s_server_install_state",
        "k3s was not detected. Install it now? [required]": "k3s_server_install_state",
        "Helm is already installed. Continue using it without changes? [required]": "helm_install_state",
        "Helm was not detected. Install it now? [required]": "helm_install_state",
        "Existing k3s agent installation detected. Continue using it without changes? [required]": "k3s_agent_install_state",
        "k3s agent was not detected. Install it now? [required]": "k3s_agent_install_state",
    }
    return groups.get(prompt_text)


def ssh_command(remote_script: str):
    ssh_host = os.environ.get("PRODUCTIVE_K3S_SSH_HOST", "").strip()
    ssh_user = os.environ.get("PRODUCTIVE_K3S_SSH_USER", "").strip()
    ssh_port = os.environ.get("PRODUCTIVE_K3S_SSH_PORT", "").strip() or "22"
    ssh_key_path = os.environ.get("PRODUCTIVE_K3S_SSH_KEY_PATH", "").strip()
    ssh_extra_opts = os.environ.get("PRODUCTIVE_K3S_SSH_EXTRA_OPTS", "").strip()

    if not ssh_host or not ssh_user:
        return None

    command = [
        "ssh",
        "-o",
        "BatchMode=yes",
        "-o",
        "StrictHostKeyChecking=no",
        "-o",
        "UserKnownHostsFile=/dev/null",
        "-o",
        "ConnectTimeout=10",
        "-p",
        ssh_port,
    ]
    if ssh_key_path:
        command.extend(["-i", ssh_key_path])
    if ssh_extra_opts:
        command.extend(shlex.split(ssh_extra_opts))
    command.extend([f"{ssh_user}@{ssh_host}", f"bash -lc {shlex.quote(remote_script)}"])
    return command


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--instance", required=True)
    parser.add_argument("--mode", required=True, choices=["server", "agent", "stack"])
    parser.add_argument("--remote-dir", required=True)
    parser.add_argument("--server-url")
    parser.add_argument("--cluster-token")
    parser.add_argument("--base-domain", default="k3s.lab.internal")
    parser.add_argument("--stack-tgz")
    parser.add_argument("--log-file")
    args = parser.parse_args()

    if args.mode == "agent" and (not args.server_url or not args.cluster_token):
        parser.error("--server-url and --cluster-token are required for agent mode")
    if args.mode == "stack" and not args.stack_tgz:
        parser.error("--stack-tgz is required for stack mode")

    prompt_map = select_prompt_map(args)
    pending = list(prompt_map)
    remote_script = build_remote_script(args)

    command = ssh_command(remote_script)
    if command is None:
        command = [
            "multipass",
            "exec",
            args.instance,
            "--",
            "bash",
            "-lc",
            remote_script,
        ]

    proc = subprocess.Popen(
        command,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=0,
    )

    log_path = Path(args.log_file) if args.log_file else None
    log_handle = log_path.open("w", encoding="utf-8") if log_path else None
    buffer = ""

    def debug_log(message: str):
        if log_handle:
            log_handle.write(f"\n[bootstrap-debug] {message}\n")
            log_handle.flush()

    rc = 1
    process_completed = False
    try:
        while True:
            ch = proc.stdout.read(1)
            if ch == "" and proc.poll() is not None:
                break
            if ch == "":
                continue
            sys.stdout.write(ch)
            sys.stdout.flush()
            if log_handle:
                log_handle.write(ch)
                log_handle.flush()
            buffer = (buffer + ch)[-6000:]
            normalized_buffer = sanitize_prompt_buffer(buffer)
            if pending:
                matched_index = None
                matched_prompt = None
                matched_answer = None
                for idx, (prompt_text, answer) in enumerate(pending):
                    if prompt_text in normalized_buffer:
                        matched_index = idx
                        matched_prompt = prompt_text
                        matched_answer = answer
                        break

                if matched_prompt is not None:
                    debug_log(f"matched prompt: {matched_prompt}")
                    if proc.stdin is None:
                        raise RuntimeError("stdin unexpectedly unavailable")
                    proc.stdin.write(f"{matched_answer}\n")
                    proc.stdin.flush()
                    if log_handle:
                        if "token" in matched_prompt.lower():
                            log_handle.write("[auto-response hidden]\n")
                        else:
                            log_handle.write(f"[auto-response] {matched_answer}\n")
                        log_handle.flush()
                    matched_group = prompt_group(matched_prompt)
                    pending.pop(matched_index)
                    if matched_group is not None:
                        pending = [
                            entry for entry in pending
                            if prompt_group(entry[0]) != matched_group
                        ]
                    debug_log(
                        "pending after match: "
                        + (", ".join(prompt_text for prompt_text, _ in pending) if pending else "<empty>")
                    )
                    if not pending:
                        debug_log("closing stdin after consuming last pending prompt")
                        proc.stdin.close()
                    buffer = ""
                    normalized_buffer = ""
            completion_marker_seen = any(marker in normalized_buffer for marker in COMPLETION_MARKERS)
            if completion_marker_seen:
                debug_log(
                    "completion marker seen; pending="
                    + (", ".join(prompt_text for prompt_text, _ in pending) if pending else "<empty>")
                )
                if pending and proc.stdin is not None and not proc.stdin.closed:
                    debug_log("closing stdin after completion marker despite remaining pending prompts")
                    proc.stdin.close()
            if completion_marker_seen:
                try:
                    rc = proc.wait(timeout=5)
                    debug_log(f"process exited cleanly after completion marker with rc={rc}")
                except subprocess.TimeoutExpired:
                    debug_log("process still running after completion marker; terminating it")
                    proc.terminate()
                    try:
                        proc.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        debug_log("process did not terminate after completion marker; killing it")
                        proc.kill()
                        proc.wait()
                    rc = 0
                process_completed = True
                break
        if not process_completed:
            rc = proc.wait()
            debug_log(f"process exited without completion marker path with rc={rc}")
    finally:
        if log_handle:
            log_handle.close()

    if rc != 0:
        raise SystemExit(rc)


if __name__ == "__main__":
    main()
