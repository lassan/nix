{
  config,
  self,
  pkgs,
  vars,
  ...
}: {
  system = {
    stateVersion = "25.11";

    configurationRevision = self.rev or self.dirtyRev or null;
  };

  users = {
    # /etc/shadow is otherwise imperative state that no rebuild reproduces, so a
    # reinstall silently loses the login password.
    mutableUsers = false;

    users.${vars.userName} = {
      isNormalUser = true;
      description = vars.userName;
      extraGroups = ["wheel" "networkmanager" "input" "video" "audio"];
      shell = pkgs.zsh;
      hashedPasswordFile = config.sops.secrets.user-password.path;
      openssh.authorizedKeys.keys = [vars.sshKeys.macbook];
    };
  };

  # Users are created before the normal activation ordering, so this secret has
  # to be decrypted into /run/secrets-for-users ahead of it.
  sops.secrets.user-password.neededForUsers = true;

  # home-manager writes .zshrc, but only the NixOS module registers zsh as a
  # valid login shell.
  programs.zsh.enable = true;

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

  time.timeZone = vars.timeZone;

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    tailscale.enable = true;
  };
}
