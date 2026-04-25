{
  username,
  hostname,
  ...
}: {
  networking.hostName = hostname;

  nix.settings.trusted-users = [username];
}
