{ inputs, lib, pkgs, ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfreePredicate = package:
    lib.getName package == "exegol";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";
  services.xserver.xkb.layout = "fr";

  programs.zsh.enable = true;
  programs.command-not-found.enable = true;

  users.users.achille = {
    isNormalUser = true;
    description = "Achille";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  services.openssh.enable = false;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      pkgsUnstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfreePredicate = package:
          lib.getName package == "claude-code";
      };
      zenBrowser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
    users.achille = import ../../home/achille.nix;
  };

  system.stateVersion = "26.05";
}
