{
  username,
  hostname,
  homeDirectory,
  ...
}: {
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  users.users."${username}" = {
    home = homeDirectory;
    description = username;
  };

  system.primaryUser = username;
}
