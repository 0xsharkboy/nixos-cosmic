{ inputs, lib, pkgs, ... }:
let
  zenBrowser = pkgs.wrapFirefox
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
    {
      extraPolicies = {
        ExtensionSettings = builtins.listToAttrs [
          {
            name = "uBlock0@raymondhill.net";
            value = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "normal_installed";
              default_area = "menupanel";
            };
          }
          {
            name = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
            value = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
              installation_mode = "normal_installed";
              default_area = "navbar";
            };
          }
        ];
      };
    };
in
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
      inherit zenBrowser;
    };
    users.achille = import ../../home/achille.nix;
  };

  system.stateVersion = "26.05";
}
