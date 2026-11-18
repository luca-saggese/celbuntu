# amd64 QEMU build guest

The host is Apple Silicon; QEMU reports only the `tcg` accelerator, so the x86_64 guest uses software CPU emulation. The host reports 32 GB RAM and 1.4 TiB free on the project volume. The default VM settings are 8 vCPUs, 16 GiB RAM, and a 100 GiB sparse qcow2 disk. TCG uses `thread=multi`, allowing virtual CPUs to run in separate host threads. Override with `VM_CPUS`, `VM_MEMORY`, and `VM_DISK_SIZE`.

QEMU 11.1.3 from Homebrew exposes `virtio-vga` (2D) but not `virtio-vga-gl`; `virtio-vga-gl` is rejected as an unknown device and no `virglrenderer` package is installed. This build cannot offer 3D acceleration to the guest. The desktop remains software-rendered; TCG multi-threading can improve CPU-side parallel workloads, but it does not accelerate the guest display.

## Requirements and current state

- QEMU 11.1.3 is installed by Homebrew.
- Homebrew's QEMU installation provides `edk2-x86_64-code.fd` and `edk2-i386-vars.fd` for x86_64 UEFI; `start.sh` uses these by default. Override `OVMF_CODE` and `OVMF_VARS_TEMPLATE` to use another trusted matching pair.
- The official Ubuntu 24.04.5.1 Desktop amd64 ISO is downloaded and verified; see `docs/progress.md` for signature and hash evidence.
- Guest provisioning, SSH server/user setup, and artifact share mount are pending. Current scripts cover VM disk creation and launch plumbing only.

## Host commands

```sh
scripts/vm/create.sh
UBUNTU_ISO_PATH="$PWD/artifacts/iso/ubuntu-24.04.5.1-desktop-amd64.iso" \
scripts/vm/start.sh
```

QEMU runs in the foreground. Stop it from the guest with `sudo poweroff` or invoke `scripts/vm/stop.sh` from another terminal. The VM uses `-no-reboot` so shutting down from the live CD does not loop back into firmware. SSH forwarding is `localhost:2222` to guest port 22; set `VM_GUEST_USER` after provisioning. Create snapshots only with the guest shut down: `scripts/vm/snapshot.sh clean-install`. The helper `scripts/vm/copy-artifacts.sh` retrieves the guest's `/build/celbuntu/artifacts/` tree. Do not copy secrets or host SSH keys into the guest or the ISO.

## Security and restore notes

Disk snapshots must be made while QEMU is stopped. The UEFI variable-store file is separate and persists at `artifacts/vm/OVMF_VARS.fd`; snapshot/backup it alongside the disk if restoring firmware state matters. VM disk, variable store, and logs are ignored by Git.
