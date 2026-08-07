_: {
  imports = [
    ../../modules/darwin

    ./github-runner.nix
  ];

  networking.hostName = "macbook";

  nixpkgs.hostPlatform = "aarch64-darwin";
}
