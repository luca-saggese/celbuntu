#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
QMP_SOCKET="${VM_QMP_SOCKET:-${VM_DIR:-$ROOT_DIR/artifacts/vm}/qmp.sock}"
[[ -S "$QMP_SOCKET" ]] || { printf 'error: no running VM QMP socket at %s\n' "$QMP_SOCKET" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { printf 'error: python3 is required for QMP shutdown.\n' >&2; exit 1; }
python3 - "$QMP_SOCKET" <<'PY'
import json, socket, sys, time
sock = socket.socket(socket.AF_UNIX)
sock.connect(sys.argv[1])
sock.settimeout(2)
sock.recv(4096)  # QMP greeting
sock.sendall((json.dumps({"execute": "qmp_capabilities"}) + "\r\n").encode())
sock.recv(4096)
sock.sendall((json.dumps({"execute": "system_powerdown"}) + "\r\n").encode())
sock.close()
time.sleep(0.2)
PY
printf 'Sent ACPI power-down request. The guest must have ACPI shutdown handling enabled.\n'
