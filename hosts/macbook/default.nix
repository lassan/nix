_: {
  imports = [
    ../../modules/darwin
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/apps.nix
    ../../modules/darwin/firefox.nix
    ../../modules/darwin/rectangle.nix

    ./github-runner.nix
  ];

  networking.hostName = "macbook";

  # The macbook serves Hindsight's reflect model over the tailnet; idle sleep
  # on AC froze ollama mid-request. power.sleep.* uses systemsetup, which also
  # changes battery behaviour.
  system.activationScripts.postActivation.text = "pmset -c sleep 0";

  nixpkgs.hostPlatform = "aarch64-darwin";
}
