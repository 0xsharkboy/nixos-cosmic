{ ... }:
let
  btrfsFileSystem = subvolume: {
    device = "/dev/disk/by-label/nixos-placeholder";
    fsType = "btrfs";
    options = [
      "subvol=${subvolume}"
      "compress=zstd:3"
      "noatime"
    ];
  };
in
{
  # Evaluation-only layout. The invalid label prevents accidental installation.
  fileSystems = {
    "/" = btrfsFileSystem "@root";
    "/home" = btrfsFileSystem "@home";
    "/nix" = btrfsFileSystem "@nix";
    "/.snapshots" = btrfsFileSystem "@snapshots";
    "/home/.snapshots" = btrfsFileSystem "@home-snapshots";
    "/var/lib/docker" = btrfsFileSystem "@docker";
  };
}
