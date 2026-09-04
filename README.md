# nixos-cosmic

Minimal, reproducible NixOS laptop configuration built around COSMIC.

## Design

- NixOS and Home Manager track the stable `26.05` release.
- COSMIC packages alone track the pinned `nixos-unstable` input.
- System configuration, laptop services, desktop, containers, host hardware,
  and user configuration are kept in separate modules.
- The only exported host is `nix-laptop` (`x86_64-linux`, UEFI).
- New installations use LUKS2, Btrfs snapshots, monthly scrubbing, and zram.

## Validate the configuration

The committed hardware file uses the deliberately invalid
`nixos-placeholder` root label so the configuration can be evaluated before
choosing the target laptop. It must never be used for installation:

```console
nix flake check
nix build .#nixosConfigurations.nix-laptop.config.system.build.toplevel
```

## Install on the laptop

Follow the complete [LUKS2 and Btrfs installation guide](docs/install-luks-btrfs.md).

1. Boot a NixOS installer in UEFI mode.
2. Encrypt, partition, and mount the filesystems below `/mnt` as described in
   the guide. The EFI system partition remains unencrypted at `/mnt/boot`.
3. Clone this repository in the live environment.
4. Generate the machine-specific configuration:

   ```console
   sudo nixos-generate-config --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix \
     ./hosts/nix-laptop/hardware-configuration.nix
   ```

5. Review the generated filesystem, initrd, CPU, and graphics settings, then
   install from the repository root:

   ```console
   sudo nixos-install --flake .#nix-laptop
   sudo nixos-enter --root /mnt -c 'passwd achille'
   ```

6. Reboot, log in through the COSMIC greeter, and verify Wi-Fi, Bluetooth,
   audio, suspend/resume, Flatpak, firmware updates, and Docker.

At the first login, open **COSMIC Settings > Desktop > Appearance > Icons and
toolkit theming** and select **Papirus-Dark**. Home Manager configures Papirus
for GTK applications, but COSMIC keeps its own icon-theme preference.

The configuration also creates the standard user directories and sets sensible
defaults: Helium for the web, COSMIC Files for directories, Zed for text,
Papers for PDF files, Loupe for images, and File Roller for archives.

The account intentionally has no password or SSH key in Git. Set its password
before rebooting. Membership in the `docker` group grants root-equivalent
access to the Docker daemon.

## Operate and update

Apply local changes with:

```console
sudo nixos-rebuild test --flake .#nix-laptop
sudo nixos-rebuild switch --flake .#nix-laptop
```

`test` activates the new configuration without making it the next boot default.
If a switched configuration causes a problem, select an older generation from
the systemd-boot menu, or roll back from a working terminal:

```console
sudo nixos-rebuild switch --rollback
```

Updates are explicit so stable and unstable changes can be reviewed together:

```console
nix flake update
nix flake check
sudo nixos-rebuild switch --flake .#nix-laptop
```
