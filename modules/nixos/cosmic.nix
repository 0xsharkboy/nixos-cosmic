{ inputs, lib, pkgs, ... }:
let
  cosmicOverlay = final: prev:
    let
      unstable = import inputs.nixpkgs-unstable {
        system = prev.stdenv.hostPlatform.system;
        config.allowUnfree = false;
      };
    in
    (lib.filterAttrs
      (name: _:
        (lib.hasPrefix "cosmic-" name && name != "cosmic-applibrary")
        || builtins.elem name [
          "pop-launcher"
          "xdg-desktop-portal-cosmic"
        ])
      unstable)
    // {
      # NixOS 26.05 still uses the former attribute name in its COSMIC module.
      cosmic-applibrary = unstable.cosmic-app-library;
    };
in
{
  nixpkgs.overlays = [ cosmicOverlay ];

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  environment.systemPackages = with pkgs; [
    cosmic-ext-applet-caffeine
    cosmic-ext-applet-external-monitor-brightness
    cosmic-ext-applet-minimon
    cosmic-ext-applet-privacy-indicator
    cosmic-ext-applet-sysinfo
    cosmic-ext-applet-weather
    cosmic-ext-ctl
    cosmic-ext-tweaks
  ];

  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit
    cosmic-player
    cosmic-reader
    cosmic-term
  ];
}
