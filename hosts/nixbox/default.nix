_: {
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos
  ];

  networking.hostName = "nixbox";

  nixpkgs.hostPlatform = "x86_64-linux";
}
