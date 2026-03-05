{
  description = "Phattaraphan's NixOS Flake";

  inputs = {
    # Using the same version as your stateVersion
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    #crossmacro
    crossmacro.url = "github:alper-han/CrossMacro";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = { inherit inputs; };
      modules = [
        # imports hardware detection
        ./hardware-configuration.nix
        
        # imports configuration file
        ./configuration.nix
      ];
    };
  };
}
