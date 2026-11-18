# Caelestia Ubuntu Live ISO project

## Goal
Build and validate an Ubuntu LTS amd64 live ISO with Hyprland, Quickshell, Caelestia, and a graphical installer. Never claim an unverified capability is working.

## Host and target
- Intended development host: Intel iMac running macOS. Prefer QEMU HVF hardware acceleration for the amd64 guest when the host and QEMU build expose it; use multi-threaded TCG otherwise. The currently available validation host is Apple Silicon macOS, so Intel iMac performance remains to be verified.
- All target builds must run in an amd64 Linux guest under QEMU; do not install or modify a host OS.
- Target: amd64/x86_64 only. Never write an image to physical media without explicit authorization.
- Keep produced Debian packages, logs, manifests, and ISO artifacts under `artifacts/`.

## Engineering rules
- Inspect external scripts before execution; pin upstream revisions and record licenses.
- Package source-built target components as Debian packages. Keep live and installed system configuration reproducible.
- Use robust shell (`set -Eeuo pipefail`), validate inputs and checksums, and do not mask required failures.
- Update `docs/progress.md` with actual state, commands, test results, artifacts, blockers, and commit IDs. Distinguish pending tests from successful tests.
- Preserve user data and existing configuration. Do not add credentials or build-host keys to artifacts.
- Follow the milestone sequence in the project request. Do not advance past unmet acceptance criteria without recording a blocker.

## Project layout
- `scripts/`: host, VM, package, ISO, and validation automation.
- `docs/`: architecture, upstream review, operations, and progress.
- `packaging/`: Debian source package recipes and local repository metadata.
- `configs/`: live and installed system configuration.
- `artifacts/`: generated output (ignored by git except `.gitkeep`).
