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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    workmux = {
      # Newer workmux fails test_dashboard_quit_keys on Darwin.
      url = "github:raine/workmux/1da41e3b7fecb889aa85696e7f1bea0258e13768";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # zj-radar = {
    #   url = "github:marktoda/zj-radar";
    # };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-darwin,
    treefmt-nix,
    ...
  }: let
    inherit (nixpkgs) lib;

    specialArgs = {
      inherit inputs self;
      vars = import ./vars.nix;
    };

    forEachSystem = f:
      lib.genAttrs ["aarch64-darwin" "x86_64-linux"]
      (system: f nixpkgs.legacyPackages.${system});

    treefmtEval = forEachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
  in {
    darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = [./hosts/macbook];
    };

    nixosConfigurations.nixbox = lib.nixosSystem {
      inherit specialArgs;
      modules = [./hosts/nixbox];
    };

    homeConfigurations.sprite = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      extraSpecialArgs = specialArgs;
      modules = [inputs.stylix.homeModules.stylix ./home/sprite.nix];
    };

    packages = forEachSystem (_: {});

    # The treefmt wrapper rather than alejandra alone, so `nix fmt` covers the
    # shell and just files too.
    formatter = forEachSystem (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);

    # Backstop for commits that bypassed the pre-commit hook.
    checks = forEachSystem (pkgs: {
      formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
    });

    devShells = forEachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = [treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper];
        # Git refuses to read `core.hooksPath` from tracked files, so enabling
        # `.githooks/` cannot be declarative and has to be a runtime side effect.
        shellHook = ''
          if [ -d .git ]; then
            git config core.hooksPath .githooks
          fi
        '';
      };
    });
  };
}
