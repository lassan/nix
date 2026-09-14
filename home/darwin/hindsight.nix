{config, ...}: {
  home.file.".hindsight/coding-agent.json".text = builtins.toJSON {
    serverMode = "self-hosted";
    apiUrl = "http://127.0.0.1:8888";
    # The first-prompt reflect is capped at 25s by the hook window; a local
    # 20B model needs ~100s, so it failed nearly every session.
    autoReflect = false;
    banks."coding-agent::sup" = {
      gitIngest = "full";
      codebaseSurvey = true;
    };
  };

  launchd.agents.hindsight-tunnel = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/ssh"
        "-NT"
        "-o"
        "ExitOnForwardFailure=yes"
        "-o"
        "ServerAliveInterval=30"
        "-o"
        "ServerAliveCountMax=3"
        "-L"
        "8888:127.0.0.1:8888"
        "-L"
        "9999:127.0.0.1:9999"
        "nixbox"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 30;
      ProcessType = "Background";
    };
  };
}
