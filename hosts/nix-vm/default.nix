{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/workstation.nix
    ../../modules/nixos/storage.nix
    ../../modules/nixos/cosmic.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/flatpak.nix
    ../../modules/nixos/virtualbox-guest.nix
  ];

  networking.hostName = "nix-vm";
}
