{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ghostty-bin
    colima
    docker
  ];
}
