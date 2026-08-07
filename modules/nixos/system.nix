{
  self,
  vars,
  ...
}: {
  system = {
    stateVersion = "25.11";

    configurationRevision = self.rev or self.dirtyRev or null;
  };

  users.users.${vars.userName} = {
    isNormalUser = true;
    description = vars.userName;
    extraGroups = ["wheel" "networkmanager" "input" "video" "audio"];
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  programs.hyprland.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Stockholm";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Hyprland screen sharing needs a portal.
  xdg.portal = {
    enable = true;
    extraPortals = [];
    config.common.default = "*";
  };
}
