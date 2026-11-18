#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VM_DIR="${VM_DIR:-$ROOT_DIR/artifacts/vm}"
DISK_PATH="${VM_DISK_PATH:-$VM_DIR/build-amd64.qcow2}"
SNAPSHOT_NAME="${1:-}"
[[ -n "$SNAPSHOT_NAME" ]] || { printf 'usage: %s SNAPSHOT_NAME\n' "$0" >&2; exit 2; }
[[ "$SNAPSHOT_NAME" =~ ^[A-Za-z0-9_.-]+$ ]] || { printf 'error: invalid snapshot name.\n' >&2; exit 2; }
[[ -f "$DISK_PATH" ]] || { printf 'error: VM disk not found: %s\n' "$DISK_PATH" >&2; exit 1; }
[[ ! -S "$VM_DIR/qmp.sock" ]] || { printf 'error: shut down the guest before snapshotting.\n' >&2; exit 1; }
qemu-img snapshot -c "$SNAPSHOT_NAME" "$DISK_PATH"
