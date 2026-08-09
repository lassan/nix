{config, ...}: let
  # pnpm picks its global bin directory per platform and only reads PNPM_HOME
  # once set, so the value has to track the platform too.
  pnpmHome = "${config.home.homeDirectory}/.local/share/pnpm";
in {
  home = {
    sessionVariables.PNPM_HOME = pnpmHome;
    sessionPath = [pnpmHome];
  };
}
