{lib, ...}: {
  # Placeholder so the flake evaluates before nixbox is installed;
  # nixos-generate-config overwrites this file during installation.
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
