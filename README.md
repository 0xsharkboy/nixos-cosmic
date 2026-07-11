# nixos-cosmic

Minimal, reproducible NixOS laptop configuration built around COSMIC.

## Design

- NixOS and Home Manager track the stable `26.05` release.
- COSMIC packages alone track the pinned `nixos-unstable` input.
- System configuration, laptop services, desktop, containers, host hardware,
  and user configuration are kept in separate modules.
- The only exported host is `nix-laptop` (`x86_64-linux`, UEFI).

## Validate the configuration

The committed hardware file uses the deliberately invalid
`nixos-placeholder` root label so the configuration can be evaluated before
choosing the target laptop. It must never be used for installation:

```console
nix flake check
nix build .#nixosConfigurations.nix-laptop.config.system.build.toplevel
```

## Install on the laptop

1. Boot a NixOS installer in UEFI mode.
2. Partition, format, and mount the target filesystems below `/mnt`. The EFI
   system partition must be mounted at `/mnt/boot`.
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

The account intentionally has no password or SSH key in Git. Set its password
before rebooting. Membership in the `docker` group grants root-equivalent
access to the Docker daemon.

## Operate and update

Apply local changes with:

```console
sudo nixos-rebuild switch --flake .#nix-laptop
```

Updates are explicit so stable and unstable changes can be reviewed together:

```console
nix flake update
nix flake check
sudo nixos-rebuild switch --flake .#nix-laptop
```
