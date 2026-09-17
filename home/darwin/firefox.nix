_: {
  # wrapFirefox makes the bundle's CFBundleExecutable a shell script that execs the
  # real binary, and LaunchServices drops the app's pid across that exec, leaving
  # accessibility clients like Rectangle no process to target. modules/darwin/apps.nix
  # installs Mozilla's signed build instead, which needs no wrapper.
  programs.firefox.package = null;
}
