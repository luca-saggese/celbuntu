#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PORT="${VM_SSH_PORT:-2222}"
GUEST_USER="${VM_GUEST_USER:-builder}"
GUEST_ARTIFACTS="${VM_GUEST_ARTIFACTS:-/build/celbuntu/artifacts}"
DEST="${HOST_ARTIFACTS_DIR:-$ROOT_DIR/artifacts/from-guest}"
mkdir -p "$DEST"
exec scp -r -P "$PORT" \
    -o StrictHostKeyChecking=accept-new \
    -o UserKnownHostsFile="${VM_KNOWN_HOSTS:-$HOME/.ssh/known_hosts_celbuntu}" \
    "${GUEST_USER}@127.0.0.1:${GUEST_ARTIFACTS}/." "$DEST/"
