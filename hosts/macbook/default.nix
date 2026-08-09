_: {
  imports = [
    ../../modules/darwin
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/apps.nix
    ../../modules/darwin/rectangle.nix

    ./github-runner.nix
  ];

  networking.hostName = "macbook";

  nixpkgs.hostPlatform = "aarch64-darwin";
}
