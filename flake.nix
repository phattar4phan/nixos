{
  description = "Phattaraphan's NixOS Flake";

  inputs = {
    # Using the same version as your stateVersion
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    #zen browser
    zen-browser.url = "github:youwen5/zen-browser-flake";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = { inherit inputs };
      modules = [
        # imports hardware detection
        ./hardware-configuration.nix
        
        # imports configuration file
        ./configuration.nix
      ];
    };
  };
}
