#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

check() {
    local label="$1" command_name="$2"
    if command -v "$command_name" >/dev/null 2>&1; then
        printf 'OK      %-28s %s\n' "$label" "$(command -v "$command_name")"
    else
        printf 'MISSING %-28s %s\n' "$label" "$command_name"
        failures=$((failures + 1))
    fi
}

printf 'Project: %s\n' "$ROOT_DIR"
printf 'Host: %s %s\n' "$(uname -s)" "$(uname -m)"
check 'QEMU x86_64 system emulator' qemu-system-x86_64
check 'Homebrew (macOS)' brew
check 'Git' git
check 'curl (ISO retrieval)' curl
check 'GPG (signature verification)' gpg

if command -v qemu-system-x86_64 >/dev/null 2>&1; then
    qemu-system-x86_64 -accel help | sed 's/^/  accelerator: /'
fi

if [[ "$(uname -s)" == Darwin && "$(uname -m)" == arm64 ]]; then
    printf 'INFO    target builds must run in an emulated amd64 Linux guest (TCG); host arm64 is not the build target.\n'
fi

if (( failures > 0 )); then
    printf 'Doctor found %d missing required host tools.\n' "$failures" >&2
    exit 1
fi
printf 'Doctor checks passed for the currently implemented host prerequisites.\n'
