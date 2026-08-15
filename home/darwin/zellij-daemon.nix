{
  config,
  lib,
  pkgs,
  ...
}: let
  zellij = lib.getExe config.programs.zellij.package;
  # zj-radar publishes per-session presence files ({running, updated_epoch_s},
  # 60s heartbeat, immediate write on status edges) for its cross-session
  # badge; they double as the "is any agent working" signal. Hold a sleep
  # assertion only while a fresh file reports running > 0 — the 150s freshness
  # window is 2.5x the heartbeat, and anything Running pins the plugin's fast
  # cadence so a live agent can't go stale. The -t cap bounds an orphaned
  # caffeinate if the watcher dies uncleanly; kill -0 respawns it when it
  # expires mid-run.
  keepawake = pkgs.writeShellScript "zellij-keepawake" ''
    cache="$HOME/Library/Caches/org.Zellij-Contributors.Zellij"
    pid=""
    while :; do
      if /usr/bin/find "$cache" -name 'zj-radar.presence.*.json' -exec cat {} + 2>/dev/null \
        | ${pkgs.jq}/bin/jq -se --argjson now "$(/bin/date +%s)" \
            'any(.[]; .running > 0 and ($now - .updated_epoch_s) < 150)' >/dev/null; then
        kill -0 "$pid" 2>/dev/null || { /usr/bin/caffeinate -s -t 3600 & pid=$!; }
      elif [ -n "$pid" ]; then
        kill "$pid" 2>/dev/null
        wait "$pid" 2>/dev/null
        pid=""
      fi
      sleep 60
    done
  '';
  # Same name shell.nix's auto-attach uses, so the pre-created session is the
  # one ghostty lands in. Absolute paths: launchd agents get no usable PATH.
  session = ''"$(/usr/bin/id -un)@$(/bin/hostname)"'';
in {
  # attach -b resurrects an EXITED session (layout intact, commands suspended)
  # or creates a fresh one, without a TTY; against a running session it exits 1
  # "Session already exists", hence the || true. StartInterval re-runs it as a
  # cheap no-op so a crashed server heals within 5 minutes.
  launchd.agents.zellij = {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "${zellij} attach --create-background ${session} || true"
      ];
      RunAtLoad = true;
      StartInterval = 300;
    };
  };

  # caffeinate -s is only honored on AC power: plugged in with the lid closed
  # the machine keeps running while an agent works; on battery it sleeps as
  # normal. With nothing running the assertion is released within ~60s and
  # normal sleep resumes.
  launchd.agents.zellij-keepawake = {
    enable = true;
    config = {
      ProgramArguments = ["${keepawake}"];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
