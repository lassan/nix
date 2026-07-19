{
  description = " ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    worktrunk = {
      url = "github:max-sixty/worktrunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-can1357 = {
      url = "github:can1357/homebrew-tap";
      flake = false;
    };
    homebrew-rtk-ai = {
      url = "github:rtk-ai/homebrew-tap";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    home-manager,
    worktrunk,
    ...
  }: let
    lib = nixpkgs.lib;

    hosts = {
      macbook = {
        platform = "darwin";
        system = "aarch64-darwin";
        hostname = "macbook";
        username = "hassan";
        fullname = "Hassan Munir";
        useremail = "hassanmunir@live.com";
        homeDirectory = "/Users/hassan";
        modules = [./hosts/macbook];
      };
      nixbox = {
        platform = "nixos";
        system = "x86_64-linux";
        hostname = "nixbox";
        username = "hassan";
        fullname = "Hassan Munir";
        useremail = "hassanmunir@live.com";
        homeDirectory = "/home/hassan";
        modules = [./hosts/nixbox];
      };
    };

    hostSystems = lib.unique (map (host: host.system) (builtins.attrValues hosts));

    darwinHosts = lib.filterAttrs (_: host: host.platform == "darwin") hosts;
    nixosHosts = lib.filterAttrs (_: host: host.platform == "nixos") hosts;

    mkSpecialArgs = host:
      inputs
      // host
      // {inherit self;};

    mkDarwinSystem = host: let
      specialArgs = mkSpecialArgs host;
    in
      nix-darwin.lib.darwinSystem {
        inherit specialArgs;

        modules =
          [
            ({...}: {
              # The platform the configuration will be used on.
              nixpkgs.hostPlatform = host.system;
              environment.variables.EDITOR = "vim";
            })
            ./modules/nix-core.nix
            ./modules/common/apps.nix
            ./modules/common/host.nix

            # home manager
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = [worktrunk.homeModules.default];
              home-manager.users.${host.username} = import ./home;
            }

            # homebrew (darwin-only)
            nix-homebrew.darwinModules.nix-homebrew
          ]
          ++ host.modules;
      };

    mkNixosSystem = host: let
      specialArgs = mkSpecialArgs host;
    in
      lib.nixosSystem {
        inherit specialArgs;

        modules =
          [
            ({...}: {
              nixpkgs.hostPlatform = host.system;
              environment.variables.EDITOR = "vim";
            })
            ./modules/nix-core.nix
            ./modules/common/apps.nix
            ./modules/common/host.nix

            # home manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = [worktrunk.homeModules.default];
              home-manager.users.${host.username} = import ./home;
            }
          ]
          ++ host.modules;
      };
  in {
    darwinConfigurations = lib.mapAttrs (_: mkDarwinSystem) darwinHosts;
    nixosConfigurations = lib.mapAttrs (_: mkNixosSystem) nixosHosts;

    formatter = lib.genAttrs hostSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
