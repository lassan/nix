{
  self,
  lib,
  pkgs,
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
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe6fM69gqfP9DO3a0WWapHsY4DBZw8yt9Ii7NWLUCbu hassan@macbook"
    ];
  };

  programs = {
    hyprland = {
      enable = true;

      # Launching Hyprland bare leaves graphical-session.target inactive, and
      # both xdg-desktop-portal units are PartOf it, so portals never start.
      withUWSM = true;
    };

    # home-manager writes .zshrc, but only the NixOS module registers zsh as a
    # valid login shell.
    zsh.enable = true;
  };

  networking.networkmanager.enable = true;

  boot.loader = {
    # The ESP is shared with Windows, so cap the generations kept there.
    systemd-boot = {
      enable = true;
      configurationLimit = 20;
    };
    efi.canTouchEfiVariables = true;
  };

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  console.keyMap = "uk";

  # 31 GiB and no swap device: parallel rustc/CUDA links have no headroom to
  # spill into, leaving the OOM killer as the only backstop.
  zramSwap.enable = true;

  time.timeZone = "Europe/London";

  security.rtkit.enable = true;

  # Nothing else in the session provides one, so GUI privilege prompts would
  # silently never appear.
  security.polkit.enable = true;
  systemd.user.services.hyprpolkitagent = {
    description = "Hyprland polkit authentication agent";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      ExecStart = lib.getExe' pkgs.hyprpolkitagent "hyprpolkitagent";
      Restart = "on-failure";
    };
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    xserver.xkb.layout = "gb";

    greetd = {
      enable = true;
      settings.default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --remember --cmd 'uwsm start hyprland-uwsm.desktop'";
        user = "greeter";
      };
    };

    printing.enable = true;

    tailscale.enable = true;

    onedrive.enable = true;

    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
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
}
