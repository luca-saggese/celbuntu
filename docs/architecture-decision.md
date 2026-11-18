# Architecture decision: Ubuntu Desktop 24.04.5.1 amd64

**Status:** selected for the first reproducible prototype; installer and runtime behavior remain unverified.

## Decision

Use the official Ubuntu Desktop 24.04.5.1 amd64 image as the source for a remastered live ISO. Preserve Casper, its UEFI boot structure, and the Ubuntu Desktop graphical installer. Add the project's packages and live-session configuration to the root filesystem, then regenerate the squashfs and ISO metadata with Ubuntu's supported live-media tooling. The installer integration must be proven to transfer the custom packages to the installed target before this design is considered accepted.

## Why this base

The upstream `12errh/caelestia-ubuntu` project explicitly targets Ubuntu 24.04 and reports CI installation checks on a fresh Ubuntu 24.04 runner. The reviewed upstream commit is `46ef9a4bb6d0218deca2e081289ded6488677dbf`. It builds Quickshell and Caelestia against Qt 6.11.2, and documents that the distro's Qt 6.4 is too old for the current shell. That makes 24.04 the only candidate with direct upstream compatibility evidence. Using Desktop retains the graphical live session and installer, which removes substantial integration risk for this project's core use case.

Ubuntu 26.04.1 LTS is the current Desktop LTS as of this decision, and offers a newer kernel and longer standard support horizon. It is not selected for the first prototype because the referenced upstream project does not report 26.04 support or CI validation. Re-evaluate after the upstream build is validated on 26.04 and the remastered installer path is proven. Ubuntu 24.04 remains in standard support through May 2029.

## Alternatives considered

| Base | Decision | Reason |
|---|---|---|
| Ubuntu Desktop 24.04.5.1 | Selected | Upstream target/CI is 24.04; preserves the desktop live and GUI installer. Current ISO SHA256 is published by Ubuntu. |
| Ubuntu Desktop 26.04.1 | Defer | Newer LTS and kernel, but no compatibility evidence from the referenced Caelestia integration. |
| Ubuntu Server 24.04/26.04 | Reject for prototype | Smaller base, but requires building and maintaining a graphical live session and separately integrating an installer. This adds risk without helping the primary desktop/installer requirement. |

## Stack and packaging boundary

- Use Ubuntu packages for available runtime libraries, Mesa, audio/network services, session infrastructure, and installer. Pin/record the package versions in the build manifest.
- Build Quickshell and Caelestia components in an amd64 Linux guest. Package every source-built runtime component as `.deb`; do not copy build outputs into the image outside dpkg-managed package installation.
- The upstream wrapper's Hyprland PPA is not adopted as an implicit dependency. First evaluate Ubuntu 24.04 packages; if incompatible, build the necessary Hyprland stack as Debian packages or configure an explicitly pinned trusted repository with signed metadata.
- Keep original and custom debs available to the installer via a local APT repository carried on the ISO. Installer package propagation is a release gate.
- Maintain separate live defaults and installed-system defaults. Autologin is limited to the ephemeral live account; the installed system must create a normal user without autologin.

## Upstream integration findings

The upstream README describes a host setup tool, not an image builder. `setup.sh` requires x86_64 and 8 GB free, downloads Qt 6.11.2, builds components, invokes apt/PPA paths, and deploys user configs. `update.sh` changes/rebuilds per-user source checkouts. `uninstall.sh` removes files under `/usr/local`, `/opt`, Qt QML paths, and the current user's home. These scripts are useful as a dependency/build/configuration reference, but must not be run against the live image root or treated as Debian package recipes.

The upstream README identifies the repository scripts as MIT licensed; individual source components retain their own licenses. Capture each source's exact license text and copyright in corresponding Debian packages before redistribution. Revisions listed in `sources.lock` are the upstream's published known-good pins, not yet independently checked out or built in this environment.

## ISO integrity and provenance

Ubuntu's published `SHA256SUMS` lists `ubuntu-24.04.5.1-desktop-amd64.iso` with SHA256 `4da4a0c9035da8e68a59a838674f403f0a54472c78a83b4fb7f78d03588f85a7`. The official signature file is `SHA256SUMS.gpg`; before using the ISO, verify the signature with Ubuntu's published signing key and then verify this checksum. The image has not been downloaded or verified in this workspace.

## Open acceptance items

1. Download the official image and verify both signature and checksum in the build host/guest workflow.
2. Confirm installer remastering behavior for the selected image and custom local repository.
3. Verify every package license/source pin and build dependency against a clean 24.04 amd64 guest.
4. Boot the assembled ISO and complete an installation to a separate virtual disk, then boot that disk with the ISO detached.
5. Validate Intel Mac graphics, networking, audio, suspend/resume, and Wi-Fi on hardware; currently pending.
