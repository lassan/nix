_: {
  imports = [
    ./hardware-configuration.nix
    ./hindsight.nix

    ../../modules/nixos
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/apps.nix

    ./github-runner.nix
  ];

  networking.hostName = "nixbox";

  nixpkgs.hostPlatform = "x86_64-linux";
}
