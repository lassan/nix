_: {
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/apps.nix
  ];

  networking.hostName = "nixbox";

  nixpkgs.hostPlatform = "x86_64-linux";
}
