{
  username,
  hostname,
  ...
}: {
  networking.hostName = hostname;

  users.users."${username}" = {
    isNormalUser = true;
    description = username;
    extraGroups = ["wheel" "networkmanager" "input" "video" "audio"];
  };
}
