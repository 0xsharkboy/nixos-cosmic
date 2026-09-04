# Install with LUKS2 and Btrfs

This procedure erases the selected disk. Run it from the NixOS installer after
checking every device name with `lsblk`.

The target layout is:

- a 1 GiB EFI system partition mounted at `/boot`;
- one LUKS2 partition using the rest of the disk;
- Btrfs inside LUKS, with separate subvolumes for the system, home directory,
  Nix store, snapshots, and Docker data;
- zram instead of an on-disk swap partition.

## Partition and encrypt the disk

The VirtualBox disk is commonly `/dev/sda`; an NVMe laptop disk is commonly
`/dev/nvme0n1`. Set all three variables explicitly and verify them before
continuing:

```console
export DISK=/dev/sda
export EFI=/dev/sda1
export CRYPT=/dev/sda2
lsblk "$DISK"
```

Create the GPT partitions, then format the EFI partition and the LUKS2
container:

```console
sudo parted --script "$DISK" -- \
  mklabel gpt \
  mkpart ESP fat32 1MiB 1025MiB \
  set 1 esp on \
  mkpart cryptroot 1025MiB 100%

sudo mkfs.fat -F 32 -n BOOT "$EFI"
sudo cryptsetup luksFormat --type luks2 "$CRYPT"
sudo cryptsetup open "$CRYPT" cryptroot
sudo mkfs.btrfs -L nixos /dev/mapper/cryptroot
```

## Create and mount the Btrfs subvolumes

```console
sudo mount /dev/mapper/cryptroot /mnt

for subvolume in \
  @root \
  @home \
  @nix \
  @snapshots \
  @home-snapshots \
  @docker
do
  sudo btrfs subvolume create "/mnt/$subvolume"
done

sudo umount /mnt
sudo mount -o subvol=@root,compress=zstd:3,noatime \
  /dev/mapper/cryptroot /mnt

sudo mkdir -p \
  /mnt/boot \
  /mnt/home \
  /mnt/nix \
  /mnt/.snapshots \
  /mnt/var/lib/docker

sudo mount -o subvol=@home,compress=zstd:3,noatime \
  /dev/mapper/cryptroot /mnt/home
sudo mkdir -p /mnt/home/.snapshots
sudo mount -o subvol=@nix,compress=zstd:3,noatime \
  /dev/mapper/cryptroot /mnt/nix
sudo mount -o subvol=@snapshots,compress=zstd:3,noatime \
  /dev/mapper/cryptroot /mnt/.snapshots
sudo mount -o subvol=@home-snapshots,compress=zstd:3,noatime \
  /dev/mapper/cryptroot /mnt/home/.snapshots
sudo mount -o subvol=@docker,compress=zstd:3,noatime \
  /dev/mapper/cryptroot /mnt/var/lib/docker
sudo mount "$EFI" /mnt/boot
```

## Generate the machine-specific configuration

From the repository root, generate the hardware configuration and keep it local
to that machine:

```console
sudo nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  ./hosts/nix-laptop/hardware-configuration.nix
```

Before installing, verify that the generated file contains:

- `boot.initrd.luks.devices` pointing to the UUID of the LUKS partition;
- `/` mounted from the `@root` subvolume;
- all five other Btrfs subvolume mount points;
- `/boot` mounted from the EFI partition.

Never copy UUIDs between the VM and the laptop. Each machine must retain its own
generated `hardware-configuration.nix`.

## Install and verify

```console
sudo nixos-install --flake .#nix-laptop
sudo nixos-enter --root /mnt -c 'passwd achille'
```

After rebooting, the initrd asks for the LUKS passphrase. Verify the storage and
snapshot timers with:

```console
findmnt -t btrfs
sudo btrfs subvolume list /
systemctl list-timers 'snapper-*' 'btrfs-scrub-*'
swapon --show
```

## Use the snapshots

List the snapshots for the system or home directory:

```console
snapper --config root list
snapper --config home list
```

Each snapshot can be browsed without restoring the whole filesystem. For
example, snapshot `42` of the home directory is available below:

```console
/home/.snapshots/42/snapshot
```

Copy the required file or directory back to the current home directory. For
system files, root snapshots are similarly available below
`/.snapshots/<number>/snapshot`; use `sudo` when reading or restoring them.

Snapshots protect against accidental local changes. They remain on the same SSD
and therefore do not protect against loss, theft, or disk failure.
