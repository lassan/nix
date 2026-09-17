{
  config,
  pkgs,
  ...
}: let
  tokenFile = config.sops.secrets.github-runner-suphq.path;
  inherit (config.networking) hostName;
  workRoot = "/var/lib/github-runner-work";

  checkDisk = pkgs.writeShellScript "runner-check-disk.sh" ''
    available=$(${pkgs.coreutils}/bin/df --output=avail -B1 ${workRoot} | ${pkgs.coreutils}/bin/tail -n 1)
    if (( available < 30000000000 )); then
      echo "::error::nixbox has less than 30 GB free; restore disk space before retrying."
      exit 1
    fi
  '';

  osRelease = pkgs.writeText "os-release" ''
    PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
    NAME="Debian GNU/Linux"
    VERSION_ID="12"
    VERSION="12 (bookworm)"
    VERSION_CODENAME=bookworm
    ID=debian
    HOME_URL="https://www.debian.org/"
    SUPPORT_URL="https://www.debian.org/support"
    BUG_REPORT_URL="https://bugs.debian.org/"
  '';

  mkRunner = name: {
    enable = true;
    url = "https://github.com/suphq";
    inherit tokenFile;
    replace = true;
    ephemeral = false;
    noDefaultLabels = false;
    nodeRuntimes = ["node24"];
    extraPackages = with pkgs; [docker gnused unzip jq kubectl gh yq-go curl openssl python3 glibc.bin];
    user = "github-runner";
    group = "github-runner";
    runnerGroup = "nixbox-nix";
    extraLabels = [
      hostName
      "x86_64-linux"
    ];

    # Default work dir is the RuntimeDirectory under /run, which is tmpfs: a
    # checkout plus build output is charged to the 31 GiB of RAM this box has no
    # swap to spill into.
    workDir = "${workRoot}/${name}";

    extraEnvironment = {
      TMPDIR = "${workRoot}/${name}/_temp";
      PULUMI_HOME = "${workRoot}/${name}/.pulumi";
      ACTIONS_RUNNER_HOOK_JOB_STARTED = checkDisk;
    };

    serviceOverrides = {
      # The upstream default runs the unit in a user namespace where the docker
      # supplementary GID is unmapped, so the socket is unreachable.
      PrivateUsers = false;
      # dockerd resolves bind-mount paths on the host, so a private /tmp points
      # testcontainers and playwright mounts at the wrong directory.
      PrivateTmp = false;
      # Upstream 0066 leaves checkout files unreadable by non-root container
      # users such as playwright's pwuser.
      UMask = "0022";
      BindReadOnlyPaths = ["${osRelease}:/etc/os-release"];
      SystemCallFilter = ["capset"];
    };
  };
in {
  # Left at the root-owned default: the module's ExecStartPre copies the token
  # into the state dir as root before dropping to the service user.
  sops.secrets.github-runner-suphq = {};

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      alsa-lib
      at-spi2-core
      cairo
      cups
      dbus
      expat
      glib
      libGL
      libgbm
      libgcc
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxkbcommon
      libxrandr
      nspr
      nss
      pango
      pciutils
      vulkan-loader
    ];
  };

  virtualisation.docker.enable = true;
  # BuildKit GC reclaims unused cache between scheduled prunes as CI refills it.
  virtualisation.docker.daemon.settings.builder.gc = {
    enabled = true;
    policy = [
      {
        reservedSpace = "10GB";
        maxUsedSpace = "40GB";
        minFreeSpace = "75GB";
        all = true;
      }
    ];
  };

  users.users.github-runner = {
    isSystemUser = true;
    group = "github-runner";
    extraGroups = ["docker"];
  };
  users.groups.github-runner = {};

  systemd.tmpfiles.rules = [
    "d ${workRoot} 0700 github-runner github-runner -"
    "d ${workRoot}/${hostName}-01 0700 github-runner github-runner -"
    "d ${workRoot}/${hostName}-01/_temp 0700 github-runner github-runner -"
    "d ${workRoot}/${hostName}-02 0700 github-runner github-runner -"
    "d ${workRoot}/${hostName}-02/_temp 0700 github-runner github-runner -"
    "d ${workRoot}/${hostName}-03 0700 github-runner github-runner -"
    "d ${workRoot}/${hostName}-03/_temp 0700 github-runner github-runner -"
  ];

  # The runner PATH is nix-minimal, so every CLI a workflow calls must be listed
  # in extraPackages; a missing one can fail silently inside $(...) loops.
  # yq-go is mikefarah yq, whose GitHub action is a container action and would
  # otherwise pull an image per step. python3 runs the select-runner heredocs
  # that scripts/select-runner.checks.mjs executes under verify, glibc.bin the
  # ldd that actions such as astral-sh/setup-uv probe for libc.
  services.github-runners = {
    "${hostName}-01" = mkRunner "${hostName}-01";
    "${hostName}-02" = mkRunner "${hostName}-02";
    "${hostName}-03" = mkRunner "${hostName}-03";
  };

  # Not `system prune --all`: its until filter reads image *creation* time, so
  # every upstream base the e2e harness pins (playwright is built 8 weeks before
  # the tag ships, supabase 4-15 months) is older than any useful threshold and
  # gets deleted, then re-pulled ~10GiB on the next job. Tagged images are kept
  # and the sha-tagged deploy images, which are the only ones that actually
  # accumulate, are swept by name instead -- under both the registry tag and the
  # apps-* tag compose gives the same build.
  #
  # Build cache is the real hog and grows with CI volume, not with time: it
  # reached 24GiB in four days on the macbook against 16GiB of free disk, which
  # is the full-disk failure SUP-2217 mis-read as a testcontainers fault. Capping
  # the size bounds it whatever the merge rate does; an age filter does not.
  systemd.services.docker-runner-prune = {
    path = with pkgs; [docker coreutils];
    script = ''
      set -u
      docker container prune --force --filter until=168h
      docker image prune --force
      docker volume prune --force
      cutoff=$(date -u -d '1 day ago' +%s)
      while IFS= read -r volume; do
        created=$(docker volume inspect --format '{{.CreatedAt}}' "$volume")
        if (( $(date -d "$created" +%s) < cutoff )); then
          if ! docker volume rm "$volume"; then
            echo "Could not remove $volume; retrying at the next prune." >&2
          fi
        fi
      done < <(docker volume ls --quiet --filter dangling=true --filter name='^sup-e2e-work-')

      cutoff=$(date -u -d '12 hours ago' +%s)
      for ref in 'registry.digitalocean.com/suphq/*:sha-*' 'apps-*:sha-*'; do
        while IFS= read -r image; do
          created=$(docker image inspect --format '{{.Created}}' "$image")
          if (( $(date -d "$created" +%s) < cutoff )); then
            if ! docker rmi "$image"; then
              echo "Could not remove $image; retrying at the next prune." >&2
            fi
          fi
        done < <(docker images --filter reference="$ref" --format '{{.Repository}}:{{.Tag}}')
      done
      docker buildx prune --builder default --force --all --reserved-space=10GB --max-used-space=40GB --min-free-space=75GB
      df -h ${workRoot}
    '';
    serviceConfig.Type = "oneshot";
    after = ["docker.service"];
    requires = ["docker.service"];
  };

  systemd.timers.docker-runner-prune = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*:0/15";
      Persistent = true;
    };
  };
}
