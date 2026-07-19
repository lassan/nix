{
  homeDirectory,
  lib,
  hostname,
  pkgs,
  ...
}: let
  tokenFile = /. + "${homeDirectory}/.config/github-runner/suphq.token";
  hasToken = builtins.pathExists tokenFile;
in {
  warnings = lib.optional (!hasToken) ''
    GitHub runner for suphq is disabled because ${tokenFile} does not exist.
    Create a fine-grained PAT for the suphq org with "Self-hosted runners: Read and write",
    save it to that path, and rebuild to register the runner.
  '';
  users.users._github-runner = lib.mkIf hasToken {
    home = lib.mkForce "/private/var/lib/github-runners";
  };

  # Grant the GitHub runner user access to the host's colima docker socket.
  system.activationScripts.githubRunnerDocker.text = lib.mkIf hasToken ''
    dseditgroup -o edit -a _github-runner -t user staff 2>/dev/null || true
    chmod g+x ${homeDirectory}
    if [ -S ${homeDirectory}/.colima/default/docker.sock ]; then
      chmod g+rw ${homeDirectory}/.colima/default/docker.sock
    fi
  '';

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
  launchd.user.agents.colima-autostart = lib.mkIf hasToken {
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

  # colima recreates docker.sock as srw------- on every restart, dropping the
  # group rw bit the activation script above grants. Since activation only runs
  # on darwin-rebuild, the runner loses socket access whenever colima restarts
  # between rebuilds, failing builds with "permission denied ... docker.sock".
  # This agent re-applies g+rw on load and whenever colima touches its dir.
  launchd.user.agents.colima-sock-perms = lib.mkIf hasToken {
    command = "/bin/chmod g+rw ${homeDirectory}/.colima/default/docker.sock";
    serviceConfig = {
      WatchPaths = ["${homeDirectory}/.colima/default"];
      RunAtLoad = true;
      StandardOutPath = "/tmp/colima-sock-perms.log";
      StandardErrorPath = "/tmp/colima-sock-perms.log";
    };
  };

  # CI builds accumulate image layers in colima's 100GB disk; prune anything
  # older than a week every Sunday at 03:00. Runs as the login user because
  # colima (and its docker socket) belong to them.
  launchd.user.agents.docker-prune = lib.mkIf hasToken {
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

  services.github-runners."${hostname}-01" = lib.mkIf hasToken {
    enable = true;
    url = "https://github.com/suphq";
    inherit tokenFile;
    replace = true;
    ephemeral = false;
    noDefaultLabels = false;
    nodeRuntimes = ["node20" "node24"];
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

  services.github-runners."${hostname}-02" = lib.mkIf hasToken {
    enable = true;
    url = "https://github.com/suphq";
    inherit tokenFile;
    replace = true;
    ephemeral = false;
    noDefaultLabels = false;
    nodeRuntimes = ["node20" "node24"];
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
