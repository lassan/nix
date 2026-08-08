{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ghostty-bin
    colima
    docker

    # `just deploy nixbox <ip>` drives the NixOS host from here; NixOS ships
    # this with the system, darwin does not.
    nixos-rebuild
  ];
}
