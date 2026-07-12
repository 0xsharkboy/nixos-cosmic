{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/laptop.nix
    ../../modules/nixos/cosmic.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/flatpak.nix
  ];

  networking.hostName = "nix-laptop";
}
