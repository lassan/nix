{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/system.nix
    ../../modules/nixos/apps.nix
    ../../modules/nixos/host-user.nix
  ];
}
