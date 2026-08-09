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
    # nix-homebrew pins brew 6.0.12, but homebrew-cask now uses the
    # `command_wrapper` stanza that brew only understands from 6.0.13. Drop this
    # and the nix-homebrew.package override once upstream bumps its own brew-src.
    brew-src = {
      url = "github:Homebrew/brew/6.0.15";
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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    worktrunk = {
      url = "github:max-sixty/worktrunk";
      inputs.nixpkgs.follows = "nixpkgs";
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
    homebrew-rtk-ai = {
      url = "github:rtk-ai/homebrew-tap";
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

    overlays.default = import ./overlays;

    packages = forEachSystem (pkgs: {
      tokensave = pkgs.callPackage ./packages/tokensave.nix {};
    });

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
