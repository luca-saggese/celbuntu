# Caelestia Ubuntu Live ISO Builder

Build infrastructure for an Ubuntu LTS amd64 live system with Hyprland, Quickshell, Caelestia, and a graphical installer. Target builds are performed inside an emulated amd64 Linux guest on Apple Silicon.

The project is being implemented in milestones. See [progress](docs/progress.md) for verified status and blockers. No ISO or target desktop is claimed until its build and boot/install paths have been validated.

## Initial host checks

```sh
make doctor
```

More build and release commands will be added as their workflows become available.
