# Test the configuration in VirtualBox

The VM has its own `nix-vm` configuration and hardware file. It shares the
desktop and user configuration with the laptop, while enabling VirtualBox Guest
Additions only inside the VM.

## Create the VM

Download the current NixOS 26.05 graphical x86_64 ISO from
<https://nixos.org/download/> and create a VM with:

- type: Linux, Other Linux (64-bit) if NixOS is not listed;
- 8 GiB RAM (6 GiB minimum for a comfortable COSMIC session);
- 4 virtual CPUs;
- EFI enabled;
- one dynamically allocated 64 GiB VDI attached to the SATA controller;
- VMSVGA graphics, 128 MiB video memory, and 3D acceleration enabled;
- NAT networking;
- shared clipboard set to bidirectional.

Attach the ISO to the optical drive and start the VM. If COSMIC displays a black
screen, power off the VM and retry once with 3D acceleration disabled.

## Prepare the installation

Open a terminal in the live session, then clone the configuration:

```console
git clone https://github.com/0xsharkboy/nixos-cosmic.git
cd nixos-cosmic
export HOST=nix-vm
```

If `git` is unavailable in the installer, start a temporary shell first:

```console
nix-shell -p git
```

Check the virtual disk name. With the recommended SATA controller it should be
`/dev/sda`:

```console
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
```

Continue with the [LUKS2 and Btrfs procedure](install-luks-btrfs.md). Keep
`HOST=nix-vm`, `DISK=/dev/sda`, `EFI=/dev/sda1`, and `CRYPT=/dev/sda2` if those
names match `lsblk`.

The partitioning commands erase the VM disk. They do not touch the host disk.

## First boot

After `nixos-install` completes:

```console
sudo reboot
```

Remove the ISO when VirtualBox asks, or detach it from the optical drive. The VM
must then:

1. ask for the LUKS passphrase;
2. boot through systemd-boot;
3. show the COSMIC greeter;
4. accept the password created for `achille`.

Verify the setup after logging in:

```console
findmnt -t btrfs
sudo cryptsetup status cryptroot
sudo btrfs subvolume list /
snapper --config root list
snapper --config home list
systemctl list-timers 'snapper-*' 'btrfs-scrub-*'
swapon --show
systemctl status virtualbox --no-pager
```

## Update the VM later

The generated hardware file stays local to the VM. Preserve it around pulls:

```console
cd ~/nixos-cosmic
git stash push hosts/nix-vm/hardware-configuration.nix
git pull --ff-only
git stash pop

sudo nixos-rebuild test --flake .#nix-vm
sudo nixos-rebuild switch --flake .#nix-vm
```
