{
  description = "Minimal NixOS laptop configuration with COSMIC";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = rec {
        codex = pkgs.callPackage ./packages/codex.nix { };
        default = codex;
      };

      nixosConfigurations.nix-laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager
          ./hosts/nix-laptop
        ];
      };

      checks.${system}.nix-laptop =
        self.nixosConfigurations.nix-laptop.config.system.build.toplevel;
    };
}
