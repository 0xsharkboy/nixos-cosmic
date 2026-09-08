{ pkgs, ... }:
{
  networking.networkmanager.enable = true;

  security.rtkit.enable = true;

  # LocalSend's module installs the application and opens its LAN discovery
  # and transfer port through the firewall.
  programs.localsend.enable = true;

  environment.systemPackages = [ pkgs.gnome-disk-utility ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
