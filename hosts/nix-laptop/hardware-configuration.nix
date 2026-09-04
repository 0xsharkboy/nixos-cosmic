# Placeholder only. Replace this file with the output of
# `nixos-generate-config --root /mnt` on the target laptop before installation.
{ ... }:
{
  # This declaration only makes the repository evaluable before the target
  # machine exists. Do not install with it: the generated hardware file must
  # replace this entire file.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-placeholder";
    fsType = "btrfs";
    options = [
      "subvol=@root"
      "compress=zstd:3"
      "noatime"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nixos-placeholder";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd:3"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nixos-placeholder";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd:3"
      "noatime"
    ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-label/nixos-placeholder";
    fsType = "btrfs";
    options = [
      "subvol=@snapshots"
      "compress=zstd:3"
      "noatime"
    ];
  };

  fileSystems."/home/.snapshots" = {
    device = "/dev/disk/by-label/nixos-placeholder";
    fsType = "btrfs";
    options = [
      "subvol=@home-snapshots"
      "compress=zstd:3"
      "noatime"
    ];
  };

  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-label/nixos-placeholder";
    fsType = "btrfs";
    options = [
      "subvol=@docker"
      "compress=zstd:3"
      "noatime"
    ];
  };
}
