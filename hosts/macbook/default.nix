_: {
  imports = [
    ../../modules/darwin
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/apps.nix

    ./github-runner.nix
  ];

  networking.hostName = "macbook";

  nixpkgs.hostPlatform = "aarch64-darwin";
}
