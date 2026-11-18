# Project progress

## Milestone status

| Step | Status | Commit | Artifacts | Tests | Blocker |
|---|---|---|---|---|---|
| 0. Bootstrap repository | COMPLETED | `9d9c67fc5c46cf976d42caca0efc4851c23d6ce4` | Project skeleton | Host/repository inspection | — |
| 1. Architecture and base selection | IN PROGRESS | checkpoint pending | Architecture decision, upstream review, source pins | `make doctor` passed; upstream page review partial | Shell DNS blocks ISO download and full upstream clone/tree audit |
| 2. QEMU environment | NOT STARTED | — | — | — | — |
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

## STEP 1 — Architecture and upstream audit (checkpoint, incomplete)

- Decision recorded in `docs/architecture-decision.md`: Ubuntu Desktop 24.04.5.1 amd64 for the first prototype, selected because the referenced integration targets 24.04 and its README reports CI on Ubuntu 24.04. Ubuntu 26.04.1 is deferred pending compatibility evidence.
- Upstream findings and the reuse boundary are in `docs/upstream-review.md`. Published revision pins are in `sources.lock`.
- Implemented `make doctor`; command `make doctor` passed on Darwin arm64 and confirmed QEMU 11.1.3 supports `tcg`, along with Homebrew, Git, curl, and GPG.
- Official checksum listed for the Ubuntu 24.04.5.1 Desktop amd64 image: `4da4a0c9035da8e68a59a838674f403f0a54472c78a83b4fb7f78d03588f85a7` (from Ubuntu `SHA256SUMS`). Not verified locally because image and signature have not been retrieved.
- Network check: `git ls-remote https://github.com/12errh/caelestia-ubuntu.git HEAD` and `curl -I https://releases.ubuntu.com/24.04/ubuntu-24.04.5.1-desktop-amd64.iso` both failed with `Could not resolve host`. No ISO was downloaded.
- Incomplete criteria: full inspection of upstream `scripts/`, `configs/`, and `packaging/`; source pin fetch/license inspection; live download and GPG/checksum verification; installer remastering design proof.
- Reproduction: `make doctor`; `git ls-remote https://github.com/12errh/caelestia-ubuntu.git HEAD`; official checksum reference is `https://releases.ubuntu.com/24.04/SHA256SUMS`.
- Next: resume when shell network/DNS is available. Then verify source tree and ISO authenticity, bootstrap amd64 guest, and continue the milestone sequence.
