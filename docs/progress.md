# Project progress

## Milestone status

| Step | Status | Commit | Artifacts | Tests | Blocker |
|---|---|---|---|---|---|
| 0. Bootstrap repository | COMPLETED | `9d9c67fc5c46cf976d42caca0efc4851c23d6ce4` | Project skeleton | Host/repository inspection | — |
| 1. Architecture and base selection | COMPLETED | `d01691bf673118feb40a1c6d7f3ba4b112c2fce7` checkpoint; completion commit pending | Architecture decision, full upstream audit, source pins | `make doctor`; upstream clone/review; exact source pins fetched; official `SHA256SUMS.gpg` verified | Subdirectory license audit/build remains in packaging step |
| 2. QEMU environment | IN PROGRESS | — | Persistent 100 GiB qcow2 disk; Ubuntu ISO download in progress | `bash -n`; `make vm-create`; `qemu-img info`; `make doctor` passed | Finish ISO+checksum; boot/provision guest, SSH, snapshot/transfer pending |
| 3. Debian build infrastructure | NOT STARTED | — | — | — | — |
| 4. Hyprland stack | NOT STARTED | — | — | — | — |
| 5. Quickshell and Caelestia | NOT STARTED | — | — | — | — |
| 6. Live desktop integration | NOT STARTED | — | — | — | — |
| 7. ISO generation | NOT STARTED | — | — | — | — |
| 8. Installer integration | NOT STARTED | — | — | — | — |
| 9. Automated validation | NOT STARTED | — | — | — | — |
| 10. Release | NOT STARTED | — | — | — | — |

## STEP 0 — Bootstrap

- Objective: establish project conventions, folders, and progress tracking.
- Host: macOS 26.3 arm64; QEMU x86_64 emulator and Homebrew are present; 1.4 TiB free on the project volume.
- Repository: initialized Git repository on `main`, no commits or tracked files; existing untracked `.vscode/` preserved.
- Files: `AGENTS.md`, `README.md`, `.gitignore`, and this progress file.
- Tests: inspected host architecture, QEMU/Brew availability, disk space, and Git status. No build tests apply yet.
- Artifacts: none.
- Risks: none established.
- Reproduction: `uname -a; command -v qemu-system-x86_64; df -h .; git status --short --branch`.
- Result: completed and committed; the architecture/source work is tracked separately as STEP 1.

## STEP 0 — Completion record

- Acceptance: root instructions, README, ignore rules, progress tracking, and standard project directories are present.
- Commit: `9d9c67fc5c46cf976d42caca0efc4851c23d6ce4` (`chore: initialize caelestia live iso project`).
- Existing `.vscode/` remains untracked and untouched.

## STEP 1 — Architecture and upstream audit (completed)

- Decision recorded in `docs/architecture-decision.md`: Ubuntu Desktop 24.04.5.1 amd64 for the first prototype, selected because the referenced integration targets 24.04 and its README reports CI on Ubuntu 24.04. Ubuntu 26.04.1 is deferred pending compatibility evidence.
- Upstream findings and the reuse boundary are in `docs/upstream-review.md`. Source pins from cloned `revisions.conf` are in `sources.lock`.
- Implemented `make doctor`; command `make doctor` passed on Darwin arm64 and confirmed QEMU 11.1.3 supports `tcg`, along with Homebrew, Git, curl, and GPG.
- Upstream shallow clone SHA: `46ef9a4bb6d0218deca2e081289ded6488677dbf`. README, setup/update/uninstall, revisions, scripts/CI check, configs, packaging, and license reviewed. All five published component commit refs fetched and checked; top-level license identifiers recorded in `sources.lock`.
- Ubuntu `SHA256SUMS` and `.gpg` were downloaded. Signature verified good against Ubuntu CD Image Automatic Signing Key (2012), fingerprint `843938DF228D22F7B3742BC0D94AA3F0EFE21092`. The ISO checksum awaits completed download.
- Network was available through the approved external-network path; ordinary sandbox requests failed DNS. An official ISO download is underway.
- Reproduction: `make doctor`; `GNUPGHOME=artifacts/checksums/gnupg gpg --verify artifacts/checksums/SHA256SUMS.gpg artifacts/checksums/SHA256SUMS`; official checksum reference: `https://releases.ubuntu.com/24.04/SHA256SUMS`.
- Result: base decision and upstream review complete. Proceed with STEP 2.

## STEP 2 — QEMU guest (in progress)

- Host QEMU 11.1.3 exposes `tcg` (no x86_64 hardware acceleration expected on Apple Silicon). `system_profiler` reports Apple M5 and 32 GB RAM; this disagrees with the pasted brief's M4 description, but both are arm64 hosts. Project volume has 1.4 TiB free.
- Added `scripts/vm/{create,start,stop,ssh,snapshot,copy-artifacts}.sh`, Make targets, and `docs/vm.md`. Start uses TCG, UEFI pflash variables, virtio disk/network, a local forwarded SSH port, and host QEMU logging.
- Created `artifacts/vm/build-amd64.qcow2`, a valid sparse 100 GiB qcow2 disk (currently 196 KiB allocated).
- Tests: `bash -n scripts/vm/*.sh`; `make vm-create`; `qemu-img info artifacts/vm/build-amd64.qcow2` (format qcow2, 100 GiB virtual, no corruption); `make doctor` passed.
- Network works through the approved external-network path. The official 5.9 GiB Desktop ISO download is running at ~15 MiB/s. Signature file has been verified.
- Homebrew QEMU provides `edk2-x86_64-code.fd` and `edk2-i386-vars.fd`; the launcher uses these by default.
- Blockers: finish and checksum ISO; boot/provision guest, SSH, snapshot restore, and host artifact transfer pending.
- Next: verify ISO checksum, test UEFI boot, provision guest, then validate SSH and artifact transfer.
