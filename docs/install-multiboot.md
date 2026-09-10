# Install alongside existing systems with LUKS2 and Btrfs

This guide replaces an existing Linux installation while preserving the other
operating systems and their bootloaders. It is deliberately based on partition
roles and labels rather than fixed partition numbers, so it can be reused on
another UEFI laptop.

The commands that format a partition are destructive. Read the complete guide,
fill in the worksheet, and verify every device from the live installer before
running them. If the entire target disk may be erased, use the simpler
[empty-disk guide](install-luks-btrfs.md) instead.

## Before booting the installer

1. Copy every irreplaceable file to storage outside the target disk.
2. Open the archive from that other device and verify a few files. A backup
   stored only in the Linux partition being replaced is not a backup.
3. Save the recovery keys for every encrypted operating system.
4. Disable Windows Fast Startup and perform a full shutdown from Windows.
5. Create a NixOS installer and boot it explicitly in UEFI mode.

The installer is in UEFI mode only if this command succeeds:

```console
test -d /sys/firmware/efi && echo UEFI || echo 'STOP: legacy BIOS mode'
```

Connect the live environment to the network, then clone the configuration:

```console
git clone https://github.com/0xsharkboy/nixos-cosmic.git
cd nixos-cosmic
```

## Inventory the disk

List the filesystems, partition-table types, labels, UUIDs, and mount points:

```console
lsblk -e7 -o NAME,PATH,SIZE,FSTYPE,FSVER,LABEL,PARTLABEL,UUID,PARTUUID,MOUNTPOINTS
sudo fdisk -l
```

Write down the result before changing anything:

| Role | Device before installation | Action |
| --- | --- | --- |
| Firmware EFI partition(s) | | Keep, do not format |
| Windows reserved/system/data/recovery | | Keep, do not format |
| macOS/APFS container and bootloader | | Keep, do not format |
| Existing Linux root | | Replace |
| Existing Linux swap | | Keep temporarily or delete |
| Other data partitions | | Keep, do not format |

Do not identify a partition from its number alone. Confirm its filesystem,
size, label, and role. If any role is uncertain, stop and inspect it from the
currently installed systems before continuing.

## Plan the replacement

Create the following two partitions entirely inside the space occupied by the
old Linux root:

- a dedicated 1–2 GiB FAT32 EFI System Partition for NixOS (`NIXOS-ESP`);
- a Linux filesystem partition using the remaining space (`NIXOS-LUKS`), which
  will contain LUKS2 and Btrfs.

A dedicated NixOS EFI partition prevents systemd-boot from sharing writable
boot files with Windows, OpenCore, or rEFInd. Existing firmware EFI partitions
remain untouched. The NixOS configuration mounts the new partition at `/boot`.

The configuration uses zram, so an on-disk swap partition is not required.
Deleting a non-adjacent old swap partition does not enlarge the new encrypted
partition: leave that free extent unallocated or repurpose it only after NixOS
and every existing system boot correctly.

### Current HP Pavilion worksheet

This is a record of the layout observed before installation, not a substitute
for the live `lsblk` output:

| Partition | Observed role | Action |
| --- | --- | --- |
| `/dev/nvme0n1p1` | Windows EFI, 100 MiB, FAT32 | Keep, never format |
| `/dev/nvme0n1p2` | Microsoft Reserved, 16 MiB | Keep |
| `/dev/nvme0n1p3` | Windows, about 343.5 GiB, NTFS | Keep |
| `/dev/nvme0n1p4` | Windows recovery, about 790 MiB, NTFS | Keep |
| `/dev/nvme0n1p5` | OpenCore/rEFInd EFI, 1 GiB, FAT32 | Keep, never format |
| `/dev/nvme0n1p6` | Existing Linux root, about 397.2 GiB, ext4 | Replace |
| `/dev/nvme0n1p7` | macOS, about 195.3 GiB, APFS | Keep |
| `/dev/nvme0n1p8` | Existing Linux swap, 16 GiB | Delete or leave unused |

Create both NixOS partitions in the former `p6` extent. Because later
partitions remain present, the new GPT partition numbers are not guaranteed to
be `p6` and `p7`; discover their actual device paths again after creation.
The migration archive currently stored below `/home/achille` is part of `p6`
and will be destroyed; upload it and test the downloaded copy first.

## Edit only the replacement area

A graphical partition editor such as GParted makes the occupied extents easier
to review than a command using copied sector boundaries. From a graphical
installer, open the available partition editor and:

1. Select the verified target disk.
2. Delete only the old Linux root partition.
3. In that same unallocated extent, create a 2 GiB FAT32 partition named
   `NIXOS-ESP` and enable its `esp` flag.
4. Create a second partition named `NIXOS-LUKS` using the rest of that extent.
   Do not create a filesystem in it yet.
5. Optionally delete the old Linux swap. Do not move macOS merely to join the
   resulting free extents.
6. Review the pending operations, especially every partition marked for
   deletion or formatting, before applying them.

Never create a new partition table and never format an existing EFI, Windows,
macOS, recovery, or data partition.

## Identify and format the new partitions

Refresh the inventory, then set the variables to the device paths that now have
the `NIXOS-ESP` and `NIXOS-LUKS` partition names:

```console
sudo swapoff --all
sudo partprobe
lsblk -e7 -o NAME,PATH,SIZE,FSTYPE,LABEL,PARTLABEL,PARTUUID,MOUNTPOINTS

export HOST=hp-pavilion # Use nix-laptop on another physical laptop
export EFI=/dev/nvme0n1pX
export CRYPT=/dev/nvme0n1pY

lsblk -o PATH,SIZE,FSTYPE,LABEL,PARTLABEL,PARTUUID "$EFI" "$CRYPT"
```

The final command must show only the two newly created partitions. Replace `X`
and `Y`; never paste those placeholders into a formatting command.

Format only those verified partitions:

```console
sudo mkfs.fat -F 32 -n NIXBOOT "$EFI"
sudo cryptsetup luksFormat --type luks2 "$CRYPT"
sudo cryptsetup open "$CRYPT" cryptroot
sudo mkfs.btrfs -L nixos /dev/mapper/cryptroot
```

## Create, mount, and install the system

Continue at [Create and mount the Btrfs subvolumes](install-luks-btrfs.md#create-and-mount-the-btrfs-subvolumes).
Use the `EFI`, `CRYPT`, and `HOST` values set above, but do not return to the
partitioning section of the empty-disk guide.

After generating `hosts/$HOST/hardware-configuration.nix`, verify that it
contains:

- the LUKS UUID belonging to `NIXOS-LUKS`;
- the six expected Btrfs subvolumes and mount points;
- `/boot` using the UUID of the new `NIXBOOT` filesystem;
- no filesystem declaration for a preserved Windows, macOS, or old EFI
  partition.

Then install and set the local password as described in the shared guide. Do
not remove the installer until `nixos-install` completes successfully.

## Verify every boot path

On the first reboot, use the firmware boot menu and start NixOS directly. It
should display systemd-boot and then request the LUKS passphrase. In NixOS run:

```console
findmnt / /boot /home /nix /.snapshots /home/.snapshots /var/lib/docker
sudo cryptsetup status cryptroot
sudo btrfs subvolume list /
systemctl list-timers 'snapper-*' 'btrfs-scrub-*'
swapon --show
```

`swapon --show` should list zram; the old disk swap is unnecessary. Finally,
boot Windows, OpenCore/rEFInd, and macOS once each before reclaiming any space
left by the old swap partition.

If the firmware does not show NixOS, boot the installer again, unlock and mount
the filesystems as above, and inspect `efibootmgr -v`. Do not repair the problem
by formatting or reusing one of the preserved EFI partitions.
