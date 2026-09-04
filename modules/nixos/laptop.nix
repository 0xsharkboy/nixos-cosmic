{ ... }:
{
  imports = [ ./workstation.nix ];

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    enableRedistributableFirmware = true;
  };

  services = {
    power-profiles-daemon.enable = true;
    fwupd.enable = true;
  };
}
