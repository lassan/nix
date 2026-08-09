{
  config,
  lib,
  ...
}: {
  # home-manager flips this default to the XDG path at stateVersion 26.05;
  # pinning it early only works on a host with no profile to relocate, since the
  # module moves nothing itself. Darwin keeps its own default.
  programs.firefox.configPath =
    lib.removePrefix "${config.home.homeDirectory}/"
    "${config.xdg.configHome}/mozilla/firefox";
}
