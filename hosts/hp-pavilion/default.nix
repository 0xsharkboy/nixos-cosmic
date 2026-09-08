{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./hardware-profile.nix
    ../../modules/profiles/laptop.nix
  ];

  networking.hostName = "hp-pavilion";
}
