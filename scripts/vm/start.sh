#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VM_DIR="${VM_DIR:-$ROOT_DIR/artifacts/vm}"
DISK_PATH="${VM_DISK_PATH:-$VM_DIR/build-amd64.qcow2}"
ISO_PATH="${UBUNTU_ISO_PATH:-$ROOT_DIR/artifacts/iso/ubuntu-24.04.5.1-desktop-amd64.iso}"
QEMU_SHARE="$(brew --prefix qemu)/share/qemu"
OVMF_CODE="${OVMF_CODE:-$QEMU_SHARE/edk2-x86_64-code.fd}"
OVMF_VARS_TEMPLATE="${OVMF_VARS_TEMPLATE:-$QEMU_SHARE/edk2-i386-vars.fd}"
OVMF_VARS="$VM_DIR/OVMF_VARS.fd"
QMP_SOCKET="$VM_DIR/qmp.sock"
LOG_PATH="$VM_DIR/qemu.log"
SSH_PORT="${VM_SSH_PORT:-2222}"

for tool in qemu-system-x86_64; do
    command -v "$tool" >/dev/null 2>&1 || { printf 'error: %s is required.\n' "$tool" >&2; exit 1; }
done
[[ -f "$DISK_PATH" ]] || { printf 'error: VM disk not found; run scripts/vm/create.sh first.\n' >&2; exit 1; }
[[ -f "$ISO_PATH" ]] || { printf 'error: Ubuntu ISO not found: %s\n' "$ISO_PATH" >&2; exit 1; }
[[ -f "$OVMF_CODE" ]] || { printf 'error: x86_64 UEFI firmware not found: %s\n' "$OVMF_CODE" >&2; exit 1; }
[[ -f "$OVMF_VARS_TEMPLATE" ]] || { printf 'error: UEFI variables template not found: %s\n' "$OVMF_VARS_TEMPLATE" >&2; exit 1; }
[[ ! -e "$QMP_SOCKET" ]] || { printf 'error: QMP socket already exists: %s\n' "$QMP_SOCKET" >&2; exit 1; }
mkdir -p "$VM_DIR"
[[ -e "$OVMF_VARS" ]] || cp "$OVMF_VARS_TEMPLATE" "$OVMF_VARS"

printf 'Starting x86_64 guest with TCG emulation. Log: %s\n' "$LOG_PATH"
printf 'QMP socket: %s; SSH forwarding: localhost:%s -> guest:22\n' "$QMP_SOCKET" "$SSH_PORT"
exec qemu-system-x86_64 \
    -name caelestia-build-amd64 \
    -machine q35,usb=on \
    -accel tcg,thread=multi \
    -cpu max -smp "${VM_CPUS:-8}" -m "${VM_MEMORY:-16G}" \
    -drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE" \
    -drive "if=pflash,format=raw,file=$OVMF_VARS" \
    -drive "file=$DISK_PATH,if=virtio,format=qcow2" \
    -cdrom "$ISO_PATH" -boot order=d,menu=on \
    -no-reboot \
    -device virtio-net-pci,netdev=net0 \
    -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:$SSH_PORT-:22" \
    -display cocoa -device virtio-vga \
    -qmp "unix:$QMP_SOCKET,server=on,wait=off" \
    -D "$LOG_PATH"
