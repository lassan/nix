{
  config,
  homeDirectory,
  lib,
  hostname,
  pkgs,
  ...
}: let
  tokenFile = config.sops.secrets.github-runner-suphq.path;
in {
  # The runner daemon reads the token as _github-runner, not root, so the sops
  # defaults (owner root, group staff) would fail registration.
  sops.secrets.github-runner-suphq = {
    owner = "_github-runner";
    group = "_github-runner";
  };

  users.users._github-runner = {
    home = lib.mkForce "/private/var/lib/github-runners";
  };

  # colima is a user VM with no lifecycle management of its own: nothing
  # restarts it after sleep, a crash, or a manual stop, and when it is down
  # ~/.colima/default/docker.sock disappears entirely. The runner's docker
  # jobs then fail at "Set up Docker Buildx" with a "Cannot read properties
  # of undefined (reading 'buildkitd-flags')" crash — the buildx action
  # chokes on a node-less default builder because `docker version` could not
  # reach the socket (CI run 27820182704). This watchdog starts colima at
  # login and re-checks every 2 minutes, restarting it (and so recreating the
  # socket) whenever the VM is gone. launchd skips overlapping ticks, and a
  # missed tick fires on wake — covering the sleep case.
  launchd.user.agents.colima-autostart = {
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

  # The runner user reaches the socket through two ACLs, not group membership:
  # it is not in staff, so it can neither traverse the 750 home directory nor
  # open the socket colima recreates as srw------- owned by the login user on
  # every restart. ACLs can be set by the file owner, so this agent can renew
  # them; a supplementary group would need the runner daemons restarted to take
  # effect, and nix-darwin cannot grant one at activation time — it splices only
  # a fixed list of script names into /run/current-system/activate, so a custom
  # system.activationScripts.<name> is silently never run. WatchPaths fires
  # while colima is still mid-restart and the socket is gone, hence the poll.
  launchd.user.agents.colima-sock-perms = {
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

  # CI builds accumulate image layers in colima's 100GB disk; prune anything
  # older than a week every Sunday at 03:00. Runs as the login user because
  # colima (and its docker socket) belong to them.
  launchd.user.agents.docker-prune = {
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

  services.github-runners."${hostname}-01" = {
    enable = true;
    url = "https://github.com/suphq";
    inherit tokenFile;
    replace = true;
    ephemeral = false;
    noDefaultLabels = false;
    nodeRuntimes = ["node24"];
    # The runner PATH is nix-minimal: any CLI a workflow script calls must be
    # listed here. jq/kubectl are used by main.yml's release job, gh and yq
    # (yq-go = mikefarah yq; its GitHub action is a container action and
    # cannot run on darwin) by promote.yml. A missing tool can fail silently
    # inside $(...) loops.
    extraPackages = with pkgs; [docker gnused unzip jq kubectl gh yq-go];
    extraEnvironment = {
      DOCKER_HOST = "unix://${homeDirectory}/.colima/default/docker.sock";
    };
    runnerGroup = "macbook-nix";
    extraLabels = [
      hostname
      "aarch64-darwin"
    ];
  };

  services.github-runners."${hostname}-02" = {
    enable = true;
    url = "https://github.com/suphq";
    inherit tokenFile;
    replace = true;
    ephemeral = false;
    noDefaultLabels = false;
    nodeRuntimes = ["node24"];
    # The runner PATH is nix-minimal: any CLI a workflow script calls must be
    # listed here. jq/kubectl are used by main.yml's release job, gh and yq
    # (yq-go = mikefarah yq; its GitHub action is a container action and
    # cannot run on darwin) by promote.yml. A missing tool can fail silently
    # inside $(...) loops.
    extraPackages = with pkgs; [docker gnused unzip jq kubectl gh yq-go gnutar];
    extraEnvironment = {
      DOCKER_HOST = "unix://${homeDirectory}/.colima/default/docker.sock";
    };
    runnerGroup = "macbook-nix";
    extraLabels = [
      hostname
      "aarch64-darwin"
    ];
  };
}
