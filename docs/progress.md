# Project progress

## Milestone status

| Step | Status | Commit | Artifacts | Tests | Blocker |
|---|---|---|---|---|---|
| 0. Bootstrap repository | COMPLETED | `9d9c67fc5c46cf976d42caca0efc4851c23d6ce4` | Project skeleton | Host/repository inspection | — |
| 1. Architecture and base selection | COMPLETED | `c18876bdc0960d6c2b8218681cc5b2caba347364` | Architecture decision, full upstream audit, source pins | `make doctor`; upstream clone/review; exact source pins fetched; official `SHA256SUMS.gpg` verified | Subdirectory license audit/build remains in packaging step |
| 2. QEMU environment | IN PROGRESS | checkpoint pending | Persistent 100 GiB qcow2 disk; verified Ubuntu ISO; Live desktop screenshot | ISO GPG+SHA256; TCG multi smoke; QMP confirms 8 vCPU/16 GiB | New Live boot still loading; provision guest, SSH, snapshot/transfer |
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
- Ubuntu `SHA256SUMS` and `.gpg` were downloaded. Signature verified good against Ubuntu CD Image Automatic Signing Key (2012), fingerprint `843938DF228D22F7B3742BC0D94AA3F0EFE21092`. Downloaded ISO SHA256 matches `4da4a0c9035da8e68a59a838674f403f0a54472c78a83b4fb7f78d03588f85a7`.
- Network was available through the approved external-network path; ordinary sandbox requests failed DNS. An official ISO download is underway.
- Reproduction: `make doctor`; `GNUPGHOME=artifacts/checksums/gnupg gpg --verify artifacts/checksums/ubuntu-24.04.SHA256SUMS.gpg artifacts/checksums/ubuntu-24.04.SHA256SUMS`; `shasum -a 256 artifacts/iso/ubuntu-24.04.5.1-desktop-amd64.iso`. Official checksum reference: `https://releases.ubuntu.com/24.04/SHA256SUMS`.
- Result: base decision and upstream review complete. Proceed with STEP 2.

## STEP 2 — QEMU guest (in progress)

- Host QEMU 11.1.3 exposes `tcg` (no x86_64 hardware acceleration expected on Apple Silicon). `system_profiler` reports Apple M5 and 32 GB RAM; this disagrees with the pasted brief's M4 description, but both are arm64 hosts. Project volume has 1.4 TiB free.
- Added `scripts/vm/{create,start,stop,ssh,snapshot,copy-artifacts}.sh`, Make targets, and `docs/vm.md`. Start uses TCG, UEFI pflash variables, virtio disk/network, a local forwarded SSH port, and host QEMU logging.
- Created `artifacts/vm/build-amd64.qcow2`, a valid sparse 100 GiB qcow2 disk (currently 196 KiB allocated).
- Tests: `bash -n scripts/vm/*.sh`; `make vm-create`; `qemu-img info artifacts/vm/build-amd64.qcow2` (format qcow2, 100 GiB virtual, no corruption); `make doctor` passed. Original QEMU settings booted TianoCore UEFI and the Ubuntu Live GNOME desktop; screenshot saved in `artifacts/test-results/ubuntu-live-desktop.png`.
- Network works through the approved external-network path. Downloaded the official 5.9 GiB Desktop ISO; its GPG signature and SHA256 both verify.
- Homebrew QEMU provides `edk2-x86_64-code.fd` and `edk2-i386-vars.fd`; the launcher uses these by default.
- Blockers: guest provisioning, SSH, snapshot restore, and host artifact transfer pending.
- Next: restart with updated 8 vCPU/16 GiB settings, then provision the guest and validate SSH/artifact transfer.

## STEP 2 — Performance adjustment (checkpoint, in progress)

- User reported QEMU was extremely slow and requested more resources plus accelerated graphics if possible.
- Inspected the screen before stopping the VM: it was at Ubuntu Live desktop with the installer icon; no installation was running.
- ACPI shutdown caused the live ISO to boot again. Closed QEMU through QMP host quit; no installation writes were underway.
- Updated launcher defaults from 4 vCPU/8 GiB to 8 vCPU/16 GiB and enabled `-accel tcg,thread=multi`; the existing 100 GiB disk is unchanged. Added `-no-reboot` to avoid live-CD reboots looping to firmware.
- GPU result: Homebrew QEMU lists `virtio-vga`, but `virtio-vga-gl` is unavailable and there is no virglrenderer. 3D acceleration is not supported by this build; desktop remains software-rendered.
- Tests: QEMU `-display none` smoke with `tcg,thread=multi`, 8 vCPUs, 16 GiB exited cleanly; live QMP confirms status running, 8 CPUs, and `base-memory=17179869184`.
- The VM was restarted with the new settings. It remains on the Ubuntu boot splash after one minute; the live desktop has not yet been confirmed at the higher allocation. The VM remains running so the user can continue once it becomes ready.
- Next: confirm the Live desktop, then let the user finish installing Ubuntu to the virtual disk and enable SSH for build automation.
