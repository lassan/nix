{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ghostty-bin
    firefox-bin-unwrapped
    colima
    docker
    (callPackage ../../packages/agent-canvas.nix {})

    # `just deploy nixbox <ip>` drives the NixOS host from here; NixOS ships
    # this with the system, darwin does not.
    nixos-rebuild
  ];
}
