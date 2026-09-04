{
  description = "Minimal NixOS laptop configuration with COSMIC";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/v0.7.0";

    helium-browser = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      mkNixos = hostModule:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            inputs.nix-flatpak.nixosModules.nix-flatpak
            hostModule
          ];
        };
    in
    {
      nixosConfigurations = {
        nix-laptop = mkNixos ./hosts/nix-laptop;
        nix-vm = mkNixos ./hosts/nix-vm;
      };

      checks.${system} = {
        nix-laptop = self.nixosConfigurations.nix-laptop.config.system.build.toplevel;
        nix-vm = self.nixosConfigurations.nix-vm.config.system.build.toplevel;
      };
    };
}
