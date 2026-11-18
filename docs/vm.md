# amd64 QEMU build guest

The target host is an Intel iMac. The current development host is Apple Silicon, where x86_64 runs through software CPU emulation and performance does not predict the Intel iMac result. `start.sh` selects HVF on an x86_64 macOS host if QEMU lists it, otherwise it selects TCG with `thread=multi`. `VM_ACCEL` can override this selection. QEMU's documentation lists HVF for macOS on both x86 and Arm hosts, but the x86_64 guest still requires a compatible host/guest pair and must be checked on the target machine. The initial defaults are 8 vCPUs, 16 GiB RAM, and a 100 GiB sparse qcow2 disk; tune to the iMac's actual RAM and CPU count. Override with `VM_CPUS`, `VM_MEMORY`, and `VM_DISK_SIZE`.

On the current host, Homebrew QEMU 11.1.3 exposes `virtio-vga` (2D) but not `virtio-vga-gl`, and no `virglrenderer` package is installed. This build cannot offer 3D acceleration to the guest; the desktop remains software-rendered. Check the target iMac's QEMU build and graphics backend before claiming guest 3D acceleration. CPU acceleration (HVF) and guest graphics acceleration are separate capabilities.

## Requirements and current state

- QEMU 11.1.3 is installed by Homebrew on the current development host.
- Homebrew's QEMU installation provides `edk2-x86_64-code.fd` and `edk2-i386-vars.fd` for x86_64 UEFI; `start.sh` uses these by default. Override `OVMF_CODE` and `OVMF_VARS_TEMPLATE` to use another trusted matching pair.
- The official Ubuntu 24.04.5.1 Desktop amd64 ISO is downloaded and verified; see `docs/progress.md` for signature and hash evidence.
- Guest provisioning, SSH server/user setup, and artifact share mount are pending. Current scripts cover VM disk creation and launch plumbing only.

## Host commands

```sh
scripts/vm/create.sh
UBUNTU_ISO_PATH="$PWD/artifacts/iso/ubuntu-24.04.5.1-desktop-amd64.iso" \
scripts/vm/start.sh
```

For Intel macOS, inspect `qemu-system-x86_64 -accel help`; `scripts/vm/start.sh` chooses HVF automatically when available. Set `VM_ACCEL=tcg,thread=multi` to force software emulation, or `VM_ACCEL=hvf` to force HVF.

QEMU runs in the foreground. Stop it from the guest with `sudo poweroff` or invoke `scripts/vm/stop.sh` from another terminal. The VM uses `-no-reboot` so shutting down from the live CD does not loop back into firmware. SSH forwarding is `localhost:2222` to guest port 22; set `VM_GUEST_USER` after provisioning. Create snapshots only with the guest shut down: `scripts/vm/snapshot.sh clean-install`. The helper `scripts/vm/copy-artifacts.sh` retrieves the guest's `/build/celbuntu/artifacts/` tree. Do not copy secrets or host SSH keys into the guest or the ISO.

## Security and restore notes

Disk snapshots must be made while QEMU is stopped. The UEFI variable-store file is separate and persists at `artifacts/vm/OVMF_VARS.fd`; snapshot/backup it alongside the disk if restoring firmware state matters. VM disk, variable store, and logs are ignored by Git.
