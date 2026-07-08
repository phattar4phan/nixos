{
  description = "Phattaraphan's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
    };

    gemini-cli = {
      url = "github:alezkv/gemini-cli-flake";
    };
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
            inputs.antigravity-nix.packages.${system}.google-antigravity-cli
            inputs.gemini-cli.packages.${system}.default
          ];
        })
      ];
    };
  };
}