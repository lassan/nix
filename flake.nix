{
  description = " ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.brew-src.follows = "brew-src";
    };
    # nix-homebrew still pins brew 6.0.12, but homebrew-cask has started using
    # the `command_wrapper` cask stanza, which brew only understands from
    # 6.0.13. Drop this input (and the nix-homebrew.package override in
    # modules/darwin/homebrew.nix) once upstream bumps its own brew-src.
    brew-src = {
      url = "github:Homebrew/brew/6.0.13";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    worktrunk = {
      url = "github:max-sixty/worktrunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hunk = {
      url = "github:modem-dev/hunk";
    };
    zj-radar = {
      url = "github:marktoda/zj-radar";
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
    treefmt-nix,
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

    forEachSystem = f: lib.genAttrs hostSystems (system: f nixpkgs.legacyPackages.${system});

    treefmtEval = forEachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

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
              nixpkgs.hostPlatform = host.system;
              environment.variables.EDITOR = "vim";
            })
            ./modules/nix-core.nix
            ./modules/common/apps.nix
            ./modules/common/host.nix

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = [worktrunk.homeModules.default];
              home-manager.users.${host.username} = import ./home;
            }

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

    # `nix fmt` — the treefmt wrapper, which fans out to alejandra/prettier/
    # shfmt/just per `treefmt.nix` instead of only covering *.nix.
    formatter = forEachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

    # Makes `nix flake check` (and so `just check`) fail on unformatted files,
    # which is the backstop for commits that bypassed the pre-commit hook.
    checks = forEachSystem (pkgs: {
      formatting = treefmtEval.${pkgs.system}.config.build.check self;
    });

    devShells = forEachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = [treefmtEval.${pkgs.system}.config.build.wrapper];
        # Hook installation has to be a runtime side effect: git deliberately
        # refuses to read `core.hooksPath` from tracked files, so nothing in
        # this repo can enable `.githooks/` declaratively. Entering the shell
        # (or `just hooks`) is the opt-in.
        shellHook = ''
          if [ -d .git ]; then
            git config core.hooksPath .githooks
          fi
        '';
      };
    });
  };
}
