{
  description = "System Configuration of Cole Glotfelty (V3)";
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
      
      # Extended lib with our custom functions
      lib = nixpkgs.lib.extend (final: prev: 
        import ./libs/extensions.nix final
      );
      
      # Auto-discovery system using host metadata
      discoverHosts = 
        let
          hostsDir = ./hosts;
          hostNames = builtins.attrNames (builtins.readDir hostsDir);
        in builtins.filter (name: 
          (builtins.readDir hostsDir).${name} == "directory"
        ) hostNames;

      # Get host metadata by importing and evaluating the host config
      getHostMeta = hostName:
        let
          hostConfig = import ./hosts/${hostName}/default.nix { inherit lib; };
        in hostConfig._meta or (throw "ERROR: Host '${hostName}' must define _meta with system, architecture, and users");

      # Generate system user imports based on host metadata
      mkSystemUserImports = hostMeta:
        let
          # Import system-specific user templates for each declared user
          userImports = map (userName: 
            ./users/templates/${userName}/${hostMeta.system}.nix
          ) hostMeta.users;
        in
          userImports;

      # Create a host config with _meta filtered out and system user imports added
      mkHostConfig = hostName:
        let
          hostConfig = import ./hosts/${hostName}/default.nix { inherit lib; };
          hostMeta = getHostMeta hostName;
          systemUserImports = mkSystemUserImports hostMeta;
          baseConfig = lib.filterAttrs (n: v: n != "_meta") hostConfig;
        in
          baseConfig // {
            imports = (baseConfig.imports or []) ++ systemUserImports;
          };

      mkHomeConfig = hostName: userName: architecture:
        let
          templateModule = ./users/templates/${userName}/default.nix;
          hostOverridePath = ./hosts/${hostName}/users/${userName}.nix;
          hostOverrideExists = builtins.pathExists hostOverridePath;
          modules = [ templateModule ] ++ lib.optionals hostOverrideExists [ hostOverridePath ];
          
          # Apply overlays to pkgs for standalone home-manager (same as common modules)
          pkgsWithOverlays = import nixpkgs {
            system = architecture;
            overlays = [
              outputs.overlays.additions
              outputs.overlays.modifications  
              outputs.overlays.stable-packages
            ];
            config = {
              allowUnfree = true;
              allowUnfreePredicate = _: true;
            };
          };
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsWithOverlays;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = modules;
        };

      # Categorize hosts by system type
      allHosts = discoverHosts;
      nixosHosts = builtins.filter (h: (getHostMeta h).system == "nixos") allHosts;
      darwinHosts = builtins.filter (h: (getHostMeta h).system == "darwin") allHosts;


      # Generate home configurations for all hosts
      allHomeConfigs = lib.flatten (map (hostName:
        let hostMeta = getHostMeta hostName;
        in map (userName: {
          name = "${userName}@${hostName}";
          value = mkHomeConfig hostName userName hostMeta.architecture;
        }) hostMeta.users
      ) allHosts);

    in {
      packages =
        forAllSystems
        (system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; inherit inputs; });
      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = lib.listToAttrs (map (hostName: {
        name = hostName;
        value = lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ (mkHostConfig hostName) ];
        };
      }) nixosHosts);

      darwinConfigurations = lib.listToAttrs (map (hostName: {
        name = hostName;
        value = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs outputs self; };
          modules = [ (mkHostConfig hostName) ];
        };
      }) darwinHosts);

      homeConfigurations = lib.listToAttrs allHomeConfigs;
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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # apple-emoji = {
    #   url = "github:zhdsmy/apple-emoji";
    #   flake = false;
    # };
  };
}
