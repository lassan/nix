{
  config,
  pkgs,
  ...
}: let
  tokenFile = config.sops.secrets.github-runner-suphq.path;
  inherit (config.networking) hostName;
  workRoot = "/var/lib/github-runner-work";

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
    extraPackages = with pkgs; [docker gnused unzip jq kubectl gh yq-go curl openssl];
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
  ];

  # The runner PATH is nix-minimal, so every CLI a workflow calls must be listed
  # in extraPackages; a missing one can fail silently inside $(...) loops.
  # yq-go is mikefarah yq, whose GitHub action is a container action and would
  # otherwise pull an image per step.
  services.github-runners = {
    "${hostName}-01" = mkRunner "${hostName}-01";
    "${hostName}-02" = mkRunner "${hostName}-02";
  };

  # Not `system prune --all`: its until filter reads image *creation* time, so
  # every upstream base the e2e harness pins (playwright is built 8 weeks before
  # the tag ships, supabase 4-15 months) is older than any useful threshold and
  # gets deleted, then re-pulled ~10GiB on the next job. Tagged images are kept
  # and the sha-tagged deploy images, which are the only ones that actually
  # accumulate, are swept by name instead.
  #
  # Build cache is the real hog and grows with CI volume, not with time: it
  # reached 24GiB in four days on the macbook against 16GiB of free disk, which
  # is the full-disk failure SUP-2217 mis-read as a testcontainers fault. Capping
  # the size bounds it whatever the merge rate does; an age filter does not.
  # Daily, because a week of cache overruns the cap between runs.
  systemd.services.docker-prune = {
    path = with pkgs; [docker gawk findutils coreutils];
    script = ''
      set -u
      docker container prune --force --filter until=168h
      docker image prune --force
      docker volume prune --force
      docker buildx prune --force --reserved-space=20GB --min-free-space=30GB
      docker images --filter reference='registry.digitalocean.com/suphq/*:sha-*' \
        --format '{{.ID}} {{.CreatedAt}}' \
      | awk -v cutoff="$(date -u -d '7 days ago' '+%Y-%m-%d')" '$2 < cutoff {print $1}' \
      | xargs -r docker rmi --force
    '';
    serviceConfig.Type = "oneshot";
    after = ["docker.service"];
    requires = ["docker.service"];
  };

  systemd.timers.docker-prune = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
    };
  };
}
