# Upstream review: 12errh/caelestia-ubuntu

Reviewed 2026-11-18 through the repository's published GitHub README and raw source pages. The host shell cannot resolve `github.com`, so a full clone and inspection of every `scripts/`, `configs/`, and `packaging/` tree entry is pending. The review below records only evidence visible in the published files.

## Files and findings

- `README.md`: targets Ubuntu 24.04 and x86_64; describes Qt 6.11.2, Wayland 1.26, a Hyprland PPA, Quickshell, Caelestia QML/plugin, m3shapes, libcava, and CLI. Says CI runs the setup on Ubuntu 24.04 and checks files/binaries, but does not launch Hyprland due to no DRM render node. License note says repository scripts are MIT and upstream components retain their own licenses.
- `setup.sh`: uses `~/.cache/caelestia-ubuntu-build`, installs apt dependencies, downloads Qt, and builds/deploys directly into `/opt`, `/usr/local`, Qt QML system locations, and the invoking user's home. It enforces x86_64 and Qt >= 6.11. It is a system setup script, not an image-root or Debian package build driver.
- `update.sh`: checks pinned component revisions and rebuilds changed upstream components into the existing live system/user paths. It is not suitable for repeatable ISO assembly.
- `uninstall.sh`: removes installed files from system paths and copies some user configs to a timestamped backup. It is operational recovery for an installed host, not package removal logic.
- `revisions.conf`: publishes exact known-good commits for Quickshell, Caelestia, m3shapes, cava, and caelestia CLI. These are copied to `sources.lock`; they have not been fetched in this environment.
- `scripts/`, `configs/`, and `packaging/`: tree pages were not available through the read-only web fetch during this turn. Their contents are not represented as reviewed. Complete this inspection when network access is available.

## Published source pins

| Component | Repository | Published pin |
|---|---|---|
| Quickshell | `https://git.outfoxxed.me/quickshell/quickshell` | `c6a516096dd84d5255b409482eb4bf740b952f88` |
| Caelestia shell | `https://github.com/caelestia-dots/shell` | `d999d4878ee4cec134168e60d913714566a8cfa6` |
| m3shapes | `https://github.com/soramanew/m3shapes` | `8a6fe8961749887d677700b6508e0c9249968b7e` |
| cava fork | `https://github.com/LukashonakV/cava` | `f03278ef9e5e7948fb206453d2f02758f8db216c` |
| Caelestia CLI | `https://github.com/caelestia-dots/cli` | `82265df3665b40184e8bdc2165541e072c5a4971` |

## Reuse boundary

Reuse as references: required apt package names, component ordering, pinned revisions, QML deployment paths, runtime service/config behavior, and user-facing troubleshooting. Rewrite: source fetch/build orchestration, packaging, config installation, live account defaults, installed-user provisioning, and ISO/installer integration. Do not call `setup.sh`, `update.sh`, or `uninstall.sh` against the target root filesystem.
