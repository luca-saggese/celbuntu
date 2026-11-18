#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VM_DIR="${VM_DIR:-$ROOT_DIR/artifacts/vm}"
DISK_PATH="${VM_DISK_PATH:-$VM_DIR/build-amd64.qcow2}"
DISK_SIZE="${VM_DISK_SIZE:-100G}"

command -v qemu-img >/dev/null 2>&1 || { printf 'error: qemu-img is required (install QEMU with Homebrew).\n' >&2; exit 1; }
mkdir -p "$VM_DIR"
if [[ -e "$DISK_PATH" ]]; then
    printf 'error: refusing to overwrite existing VM disk: %s\n' "$DISK_PATH" >&2
    exit 1
fi
qemu-img create -f qcow2 "$DISK_PATH" "$DISK_SIZE"
printf 'Created persistent amd64 build disk: %s (%s virtual size)\n' "$DISK_PATH" "$DISK_SIZE"
