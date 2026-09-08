{
  config,
  lib,
  pkgs,
  ...
}:
let
  isBtrfs = config.fileSystems."/".fsType == "btrfs";

  btrfsMountOptions = lib.mkAfter [
    "compress=zstd:3"
    "noatime"
  ];

  snapshotPolicy = {
    ALLOW_USERS = [ "achille" ];
    SYNC_ACL = true;
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 6;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 4;
    TIMELINE_LIMIT_MONTHLY = 3;
    TIMELINE_LIMIT_QUARTERLY = 0;
    TIMELINE_LIMIT_YEARLY = 0;
  };
in
{
  environment.systemPackages = lib.mkIf isBtrfs [ pkgs.btrfs-assistant ];

  # nixos-generate-config keeps the subvolume but may omit runtime mount
  # options, so keep the Btrfs policy in this hardware-independent module.
  fileSystems = {
    "/".options = btrfsMountOptions;
    "/home".options = btrfsMountOptions;
    "/nix".options = btrfsMountOptions;
    "/.snapshots".options = btrfsMountOptions;
    "/home/.snapshots".options = btrfsMountOptions;
    "/var/lib/docker".options = btrfsMountOptions;
  };

  # Avoid the restrictions of a Btrfs swapfile and keep the disk layout simple.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  services.btrfs.autoScrub = lib.mkIf isBtrfs {
    enable = true;
    interval = "monthly";
  };

  services.snapper = lib.mkIf isBtrfs {
    snapshotRootOnBoot = true;
    persistentTimer = true;
    snapshotInterval = "hourly";
    cleanupInterval = "1d";

    configs = {
      root = snapshotPolicy // {
        SUBVOLUME = "/";
        NUMBER_CLEANUP = true;
        NUMBER_LIMIT = 10;
        NUMBER_LIMIT_IMPORTANT = 5;
      };

      home = snapshotPolicy // {
        SUBVOLUME = "/home";
      };
    };
  };
}
