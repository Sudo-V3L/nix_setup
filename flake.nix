{
  description = "Flake for my setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs: {
    nixosConfigurations."tech_support" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # Passes 'inputs' (e.g. hyprland) to configuration.nix & home.nix
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix

        # Integrate Home Manager inside NixOS
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          
          # Replace with your actual system username (e.g., sudo-v3l)
          home-manager.users.sudo-v3l = import ./home.nix;
        }
      ];
    };
  };
}
