#!/usr/bin/env bash
set -Eeuo pipefail

PORT="${VM_SSH_PORT:-2222}"
GUEST_USER="${VM_GUEST_USER:-builder}"
exec ssh -p "$PORT" \
    -o StrictHostKeyChecking=accept-new \
    -o UserKnownHostsFile="${VM_KNOWN_HOSTS:-$HOME/.ssh/known_hosts_celbuntu}" \
    -o IdentitiesOnly=yes \
    "${GUEST_USER}@127.0.0.1" "$@"
