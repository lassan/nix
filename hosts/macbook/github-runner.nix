{
  config,
  lib,
  pkgs,
  vars,
  ...
}: let
  tokenFile = config.sops.secrets.github-runner-suphq.path;
  homeDirectory = config.users.users.${vars.userName}.home;
  inherit (config.networking) hostName;
in {
  # The daemon reads the token as _github-runner; the sops defaults of owner
  # root and group staff would fail registration.
  sops.secrets.github-runner-suphq = {
    owner = "_github-runner";
    group = "_github-runner";
  };

  users.users._github-runner = {
    home = lib.mkForce "/private/var/lib/github-runners";
  };

  launchd.user.agents = {
    # colima has no lifecycle management: nothing restarts it after sleep or a
    # crash, and its docker.sock vanishes with it, failing runner jobs at "Set up
    # Docker Buildx" with "Cannot read properties of undefined (reading
    # 'buildkitd-flags')" (CI run 27820182704). Poll rather than WatchPaths so a
    # missed tick still fires on wake.
    colima-autostart = {
      command = "${pkgs.writeShellScript "colima-autostart" ''
        ${pkgs.colima}/bin/colima status >/dev/null 2>&1 || ${pkgs.colima}/bin/colima start
      ''}";
      serviceConfig = {
        RunAtLoad = true;
        StartInterval = 120;
        StandardOutPath = "/tmp/colima-autostart.log";
        StandardErrorPath = "/tmp/colima-autostart.log";
      };
    };

    # ACLs rather than group membership: _github-runner is not in staff, so it
    # can neither traverse the 750 home directory nor open the srw------- socket
    # colima recreates on every restart. A supplementary group would need the
    # daemons restarted, and nix-darwin silently drops custom
    # system.activationScripts.<name>. WatchPaths fires mid-restart while the
    # socket is still gone, hence the poll.
    colima-sock-perms = {
      command = "${pkgs.writeShellScript "colima-sock-perms" ''
        sock=${homeDirectory}/.colima/default/docker.sock
        /bin/chmod +a "user:_github-runner allow search" ${homeDirectory}
        for _ in $(/usr/bin/seq 30); do
          [ -S "$sock" ] && exec /bin/chmod +a "user:_github-runner allow read,write" "$sock"
          /bin/sleep 2
        done
      ''}";
      serviceConfig = {
        WatchPaths = ["${homeDirectory}/.colima/default"];
        RunAtLoad = true;
        StartInterval = 300;
        StandardOutPath = "/tmp/colima-sock-perms.log";
        StandardErrorPath = "/tmp/colima-sock-perms.log";
      };
    };

    # Runs as the login user because colima and its socket belong to them.
    docker-prune = {
      command = "${pkgs.docker}/bin/docker system prune --all --force --filter until=168h";
      serviceConfig = {
        EnvironmentVariables.DOCKER_HOST = "unix://${homeDirectory}/.colima/default/docker.sock";
        StartCalendarInterval = [
          {
            Weekday = 0;
            Hour = 3;
            Minute = 0;
          }
        ];
        StandardOutPath = "/tmp/docker-prune.log";
        StandardErrorPath = "/tmp/docker-prune.log";
      };
    };
  };

  # The runner PATH is nix-minimal, so every CLI a workflow calls must be listed
  # in extraPackages; a missing one can fail silently inside $(...) loops.
  # yq-go is mikefarah yq, whose GitHub action is a container action and cannot
  # run on darwin.
  services.github-runners = {
    "${hostName}-01" = {
      enable = true;
      url = "https://github.com/suphq";
      inherit tokenFile;
      replace = true;
      ephemeral = false;
      noDefaultLabels = false;
      nodeRuntimes = ["node24"];
      extraPackages = with pkgs; [docker gnused unzip jq kubectl gh yq-go];
      extraEnvironment = {
        DOCKER_HOST = "unix://${homeDirectory}/.colima/default/docker.sock";
      };
      runnerGroup = "macbook-nix";
      extraLabels = [
        hostName
        "aarch64-darwin"
      ];
    };

    "${hostName}-02" = {
      enable = true;
      url = "https://github.com/suphq";
      inherit tokenFile;
      replace = true;
      ephemeral = false;
      noDefaultLabels = false;
      nodeRuntimes = ["node24"];
      extraPackages = with pkgs; [docker gnused unzip jq kubectl gh yq-go gnutar];
      extraEnvironment = {
        DOCKER_HOST = "unix://${homeDirectory}/.colima/default/docker.sock";
      };
      runnerGroup = "macbook-nix";
      extraLabels = [
        hostName
        "aarch64-darwin"
      ];
    };
  };
}
