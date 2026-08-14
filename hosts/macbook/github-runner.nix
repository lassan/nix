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
    # The spec is restated on every start because colima only persists it in
    # ~/.colima/default/colima.yaml: a `colima delete` silently drops the VM back
    # to the 2 CPU / 2 GiB defaults, which is under half what a browser e2e
    # container needs. Disk can only grow, so 100 is a floor, not a resize.
    colima-autostart = {
      command = "${pkgs.writeShellScript "colima-autostart" ''
        ${pkgs.colima}/bin/colima status >/dev/null 2>&1 || \
          ${pkgs.colima}/bin/colima start \
            --cpu 8 --memory 16 --disk 100 \
            --vm-type vz --vz-rosetta --mount-type virtiofs
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
    #
    # Not `system prune --all`: its until filter reads image *creation* time, so
    # every upstream base the e2e harness pins (playwright is built 8 weeks
    # before the tag ships, supabase 4-15 months) is older than any useful
    # threshold and got deleted weekly, then re-pulled ~10GiB on the next job.
    # Tagged images are kept and the sha-tagged deploy images, which are the only
    # ones that actually accumulate, are swept by name instead.
    #
    # Build cache is the real hog and grows with CI volume, not with time: it
    # reached 24GiB in four days against 16GiB of free disk, which is the
    # full-disk failure SUP-2217 mis-read as a testcontainers fault. Capping the
    # size bounds it whatever the merge rate does; an age filter does not.
    # Daily, because a week of cache overruns the cap between runs.
    docker-prune = {
      command = "${pkgs.writeShellScript "docker-prune" ''
        set -u
        docker=${pkgs.docker}/bin/docker
        "$docker" container prune --force --filter until=168h
        "$docker" image prune --force
        "$docker" volume prune --force
        "$docker" buildx prune --force --reserved-space=20GB --min-free-space=30GB
        "$docker" images --filter reference='registry.digitalocean.com/suphq/*:sha-*' \
          --format '{{.ID}} {{.CreatedAt}}' \
        | ${pkgs.gawk}/bin/awk -v cutoff="$(/bin/date -u -v-7d '+%Y-%m-%d')" '$2 < cutoff {print $1}' \
        | ${pkgs.findutils}/bin/xargs -r "$docker" rmi --force
      ''}";
      serviceConfig = {
        EnvironmentVariables.DOCKER_HOST = "unix://${homeDirectory}/.colima/default/docker.sock";
        StartCalendarInterval = [
          {
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
