# Upstream review: 12errh/caelestia-ubuntu

Reviewed 2026-11-18 from a shallow clone of `https://github.com/12errh/caelestia-ubuntu` at `46ef9a4bb6d0218deca2e081289ded6488677dbf` (branch `main`). The clone is in `/private/tmp/caelestia-ubuntu-upstream`; external-network access required the approved elevated path. The audit below includes README, setup/update/uninstall scripts, revisions, configs, CI checks, and Debian packaging files.

## Files and findings

- `README.md`: targets Ubuntu 24.04 and x86_64; describes Qt 6.11.2, Wayland 1.26, a Hyprland PPA, Quickshell, Caelestia QML/plugin, m3shapes, libcava, and CLI. Says CI runs the setup on Ubuntu 24.04 and checks files/binaries, but does not launch Hyprland due to no DRM render node. License note says repository scripts are MIT and upstream components retain their own licenses.
- `setup.sh`: uses `~/.cache/caelestia-ubuntu-build`, installs apt dependencies, downloads Qt, and builds/deploys directly into `/opt`, `/usr/local`, Qt QML system locations, and the invoking user's home. It enforces x86_64 and Qt >= 6.11. It is a system setup script, not an image-root or Debian package build driver.
- `update.sh`: checks pinned component revisions and rebuilds changed upstream components into the existing live system/user paths. It is not suitable for repeatable ISO assembly.
- `uninstall.sh`: removes installed files from system paths and copies some user configs to a timestamped backup. It is operational recovery for an installed host, not package removal logic.
- `revisions.conf`: publishes exact known-good commits for Quickshell, Caelestia, m3shapes, cava, and caelestia CLI. Those exact pins are copied to `sources.lock`.
- `scripts/ci-verify-install.sh`: verifies build outputs, deployed QML, templated user configs and binaries on Ubuntu 24.04; explicitly does not launch Hyprland because CI has no DRM render node.
- `configs/`: provides Hyprland, Caelestia, Quickshell systemd user service, sleep hooks, wallpaper, lock/performance overrides. Templates contain per-user home/UID/Qt path substitutions, so they cannot be copied blindly to a shared live account or installed target.
- `packaging/build-deb.sh` and `packaging/deb/*`: build a binary `caelestia-installer` GUI `.deb` using `dpkg-deb`; it packages the Python/GTK app and includes setup/update/uninstall scripts and configs as payload. It does not package the compiled desktop stack. Its `postinst` attempts cleanup of old unowned `/usr/local` and user-prefix copies; do not adopt this cleanup behavior for distro packages.
- `LICENSE`: MIT for the wrapper repo; it leaves third-party component licenses in force, including Qt and font licenses. Preserve each upstream copyright/license in generated component packages.

## Published source pins

| Component | Repository | Published pin |
|---|---|---|
| Quickshell | `https://git.outfoxxed.me/quickshell/quickshell` | `41651d7dcd62a9400eb6f4f8a8580efe00901efb` |
| Caelestia shell | `https://github.com/caelestia-dots/shell` | `454f46da16ae75cc57f34adf48dea74db0fa5175` |
| m3shapes | `https://github.com/soramanew/m3shapes` | `8a6fe8961749887d677700b6508e0c9249968b7e` |
| cava fork | `https://github.com/LukashonakV/cava` | `f03278ef9e5e7948fb206453d2f02758f8db216c` |
| Caelestia CLI | `https://github.com/caelestia-dots/cli` | `faadab3f59ff295c1058f6916b764ada6352ce99` |

The exact commits were individually fetched from their origin URLs and checked as Git commits. Their root license files identify Quickshell as LGPL-3.0-or-later (it also ships `LICENSE-GPL` for GPL-covered portions), Caelestia shell as GPL-3.0, m3shapes as Apache-2.0, the cava fork as MIT, and Caelestia CLI as GPL-3.0. Preserve the exact license texts and notices in the corresponding package copyright metadata; review subdirectory/third-party licenses before building packages.

## Reuse boundary

Reuse as references: required apt package names, component ordering, pinned revisions, QML deployment paths, runtime service/config behavior, and user-facing troubleshooting. Rewrite: source fetch/build orchestration, packaging, config installation, live account defaults, installed-user provisioning, and ISO/installer integration. Do not call `setup.sh`, `update.sh`, or `uninstall.sh` against the target root filesystem.
