{
  lib,
  pkgs,
  ...
}: {
  programs.hyprland = {
    enable = true;

    # Launching Hyprland bare leaves graphical-session.target inactive, and both
    # xdg-desktop-portal units are PartOf it, so portals never start.
    withUWSM = true;
  };

  services = {
    xserver.xkb.layout = "gb";

    greetd = {
      enable = true;
      settings.default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --remember --cmd 'uwsm start hyprland-uwsm.desktop'";
        user = "greeter";
      };
    };

    printing.enable = true;

    onedrive.enable = true;

    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # systemPackages does not install a package's udev rules, and without
    # 60-dygma.rules bazecor cannot reach the keyboard.
    udev.packages = [pkgs.bazecor];
  };

  security = {
    rtkit.enable = true;

    # Nothing else in the session provides one, so GUI privilege prompts would
    # silently never appear. The agent itself is a home-manager service.
    polkit.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # programs.hyprland already supplies the hyprland and gtk portals.
  xdg.portal = {
    enable = true;
    config.common.default = "*";
  };

  fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];

  environment.systemPackages = with pkgs; [
    grim
    slurp
    wl-clipboard
    playerctl
  ];
}
