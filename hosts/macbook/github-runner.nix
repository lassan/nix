{
  homeDirectory,
  lib,
  hostname,
  pkgs,
  ...
}: let
  tokenFile = /. + "${homeDirectory}/.config/github-runner/suphq.token";
  hasToken = builtins.pathExists tokenFile;
in {
  warnings = lib.optional (!hasToken) ''
    GitHub runner for suphq is disabled because ${tokenFile} does not exist.
    Create a fine-grained PAT for the suphq org with "Self-hosted runners: Read and write",
    save it to that path, and rebuild to register the runner.
  '';
  users.users._github-runner.home = lib.mkIf hasToken (lib.mkForce "/private/var/lib/github-runners");
  services.github-runners."${hostname}-01" = lib.mkIf hasToken {
    enable = true;
    url = "https://github.com/suphq";
    inherit tokenFile;
    replace = true;
    ephemeral = false;
    noDefaultLabels = false;
    nodeRuntimes = ["node20" "node24"];
    extraPackages = with pkgs; [gnused];
    runnerGroup = "macbook-nix";
    extraLabels = [
      hostname
      "aarch64-darwin"
    ];
  };
}
