{
  description = "System Configuration of Cole Glotfelty (V2)";
  # Portions adapted from Sascha Koenig && Jbwar22

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages =
        # forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
        forAllSystems
        (system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; });
      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = {
        casper = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/casper ];
        };
        melchior = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/melchior inputs.disko.nixosModules.disko ];
        };
      };
      darwinConfigurations = {
        "alpha-1-5" = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs outputs self; };
          modules = [ ./hosts/alpha-1-5 ];
        };
      };
      homeConfigurations = {
        "pharo@casper" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/pharo/casper.nix ];
        };
        "pharo@melchior" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/pharo/melchior.nix ];
        };
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprland = {
    #   url = "github:hyprwm/Hyprland";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    #
    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.hyprland.follows = "hyprland";
    # };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blocklist-hosts = {
      url = "github:StevenBlack/hosts";
      flake = false;
    };

    zen-browser = {
      url = "github:MarceColl/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # apple-emoji = {
    #   url = "github:zhdsmy/apple-emoji";
    #   flake = false;
    # };
  };
}
