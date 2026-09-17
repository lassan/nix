{
  config,
  vars,
  ...
}: {
  # Without the nixpkgs wrapper there is no bundle to bake distribution/policies.json
  # into, so the policies reach Firefox through its macOS plist backend instead. The
  # home-manager option stays the single definition; Linux still consumes it directly.
  system.defaults.CustomSystemPreferences."/Library/Preferences/org.mozilla.firefox" =
    config.home-manager.users.${vars.userName}.programs.firefox.policies;
}
