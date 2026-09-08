# nixos-cosmic

Minimal, reproducible NixOS laptop configuration built around COSMIC.

## Design

- NixOS and Home Manager track the stable `26.05` release.
- COSMIC, Helium, and selected fast-moving development tools track the pinned
  `nixos-unstable` input. The base system and Home Manager remain on stable.
- System configuration, laptop services, desktop, containers, host hardware,
  and user configuration are kept in separate modules.
- The reusable `nix-laptop`, the machine-specific `hp-pavilion`, and the
  isolated VirtualBox test host `nix-vm` are exported for `x86_64-linux` with
  UEFI.
- New installations use LUKS2, Btrfs snapshots, monthly scrubbing, and zram.

The `hp-pavilion` profile targets an HP Pavilion 15-eh2xxx (`6K9M2EA#ABF`)
with an AMD Ryzen 7 5825U, integrated AMD Barcelo graphics, Intel AX200 Wi-Fi
and an Intel 670p NVMe SSD. Machine-specific filesystem UUIDs and detected
initrd modules remain isolated in
`hosts/hp-pavilion/hardware-configuration.nix`.
The detected ELAN `04f3:0c00` fingerprint reader is intentionally not enabled:
it is not supported by upstream libfprint. The firmware also exposes neither a
Linux charge-threshold control nor ACPI platform profiles. Charge limits are
therefore left to the BIOS, while CPU power management uses `amd-pstate`
together with COSMIC's power-profiles-daemon.

## Validate the configuration

The committed hardware files use the deliberately invalid `nixos-placeholder`
root label so the configurations can be evaluated before installation. They
must never be used as-is for installation:

```console
nix fmt -- --ci .
nix flake check
nix build .#nixosConfigurations.nix-laptop.config.system.build.toplevel
nix build .#nixosConfigurations.hp-pavilion.config.system.build.toplevel
```

The repository CI performs the formatting check and evaluates every exported
NixOS configuration on pushes and pull requests.

## Install on this HP laptop

Follow the complete [LUKS2 and Btrfs installation guide](docs/install-luks-btrfs.md).

1. Boot a NixOS installer in UEFI mode.
2. Encrypt, partition, and mount the filesystems below `/mnt` as described in
   the guide. The EFI system partition remains unencrypted at `/mnt/boot`.
3. Clone this repository in the live environment.
4. Generate the machine-specific configuration:

   ```console
   sudo nixos-generate-config --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix \
     ./hosts/hp-pavilion/hardware-configuration.nix
   ```

5. Review the generated filesystem, initrd, CPU, and graphics settings, then
   install from the repository root:

   ```console
   sudo nixos-install --flake .#hp-pavilion
   sudo nixos-enter --root /mnt -c 'passwd achille'
   ```

6. Reboot, log in through the COSMIC greeter, and verify Wi-Fi, Bluetooth,
   audio, suspend/resume, Flatpak, firmware updates, and Docker.

## Test in VirtualBox

Use the dedicated [`nix-vm` VirtualBox guide](docs/test-virtualbox.md). The VM
has a separate hardware file and enables Guest Additions without changing the
laptop configuration.

At the first login, open **COSMIC Settings > Desktop > Appearance > Icons and
toolkit theming** and select **Papirus-Dark**. Home Manager configures Papirus
for GTK applications, but COSMIC keeps its own icon-theme preference.

The configuration also creates the standard user directories and sets sensible
defaults: Helium for the web, COSMIC Files for directories, Zed for text,
Papers for PDF files, Loupe for images, and File Roller for archives.
It also includes LibreOffice with French and English dictionaries, LocalSend,
Mission Center, GNOME Disks, Disk Usage Analyzer, Calculator, and Btrfs
Assistant. LocalSend's TCP and UDP port is opened by its NixOS module.

The account intentionally has no password or SSH key in Git. Set its password
before rebooting. Membership in the `docker` group grants root-equivalent
access to the Docker daemon.

## Operate and update

Apply local changes with:

```console
sudo nixos-rebuild test --flake .#hp-pavilion
sudo nixos-rebuild switch --flake .#hp-pavilion
```

The `nh` helper is also available and shows a clearer package diff:

```console
nh os test .
nh os switch .
```

Projects can opt into automatic development environments by placing
`use flake` in an `.envrc`, then approving it once with `direnv allow`.

`test` activates the new configuration without making it the next boot default.
If a switched configuration causes a problem, select an older generation from
the systemd-boot menu, or roll back from a working terminal:

```console
sudo nixos-rebuild switch --rollback
```

The generated hardware configuration contains identifiers that belong to this
machine and remains a local modification. Preserve it while updating the
repository:

```console
git stash push -- hosts/hp-pavilion/hardware-configuration.nix
git pull --ff-only
git stash pop
```

Updates are explicit so stable and unstable changes can be reviewed together:

```console
nix flake update
nix fmt -- --ci .
nix flake check
sudo nixos-rebuild switch --flake .#hp-pavilion
```

## Android development

Android Studio is installed from the pinned unstable input. It manages its SDK
under `~/Android/Sdk`; the system provides `adb`, `fastboot`, `scrcpy`, and KVM
access for the emulator. Log out once after applying the configuration so the
new `kvm` group membership takes effect, then check acceleration with:

```console
~/Android/Sdk/emulator/emulator -accel-check
```

VirtualBox needs nested VT-x/AMD-V for KVM inside `nix-vm`. A physical Android
device through `adb` is usually faster when testing from the VM.

The development toolbox also includes `zoxide`, `eza`, `tealdeer`, `just`,
`watchexec`, `difftastic`, `lazydocker`, `hyperfine`, and `shfmt`. Language
toolchains remain project-local through `nix develop` and `direnv`.

## Kubernetes development

The Kubernetes toolbox is kept in a dedicated Home Manager module. It provides
`kubectl`, Helm, Helmfile, K9s, `kubectx`/`kubens`, Stern, Kustomize,
Kubeconform, and Kind. Shell completions are discovered by the existing Zsh
configuration. Kind creates disposable local clusters with the configured
Docker daemon, without enabling a permanent Kubernetes service:

```console
kind create cluster --name dev
kubectl cluster-info --context kind-dev
kind delete cluster --name dev
```
