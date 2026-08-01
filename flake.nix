{
  description = "Phattaraphan's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    opencode-flake.url = "github:aodhanhayter/opencode-flake";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs system;
      };

      modules = [
        ./hardware-configuration.nix
        ./configuration.nix

        ({ ... }: {
          environment.systemPackages = [
            inputs.opencode-flake.packages.${system}.default
          ];
        })
      ];
    };
  };
}