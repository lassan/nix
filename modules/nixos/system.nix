{self, ...}:
###################################################################################
#
#  NixOS System configuration
#
#  All the configuration options are documented here:
#    https://search.nixos.org/options
#
###################################################################################
{
  system = {
    stateVersion = "25.11";

    configurationRevision = self.rev or self.dirtyRev or null;
  };

  # Use systemd-boot (UEFI)
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Enable Hyprland
  programs.hyprland.enable = true;

  # Internationalisation
  i18n.defaultLocale = "en_US.UTF-8";

  # Time zone
  time.timeZone = "Europe/Stockholm";

  # Enable sound with pipewire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # XDG portal (required for Hyprland screen sharing etc.)
  xdg.portal = {
    enable = true;
    extraPortals = [];
    config.common.default = "*";
  };
}
