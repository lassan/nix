{
  config,
  lib,
  ...
}: let
  lsregister = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister";
  current = "${config.programs.firefox.finalPackage}/Applications/Firefox.app";
in {
  # macOS 27 denies unsigned wrapped apps access to ~/Library/Application
  # Support/Firefox, which surfaces as "A copy of Firefox is already open".
  # A non-default path also passes appDataDir to the wrapper, moving the
  # application data directory off the protected one.
  programs.firefox.configPath = ".mozilla/firefox";

  # The ~/Applications copy execs the store bundle, so LaunchServices keeps a
  # registration per generation and resolves org.nixos.firefox to one of them.
  # Launching last generation's bundle loses the MOZ_APP_DATA above and the
  # denial comes back, so re-register this one to be preferred.
  home.activation.registerFirefoxBundle = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run ${lsregister} -f '${current}'
  '';
}
