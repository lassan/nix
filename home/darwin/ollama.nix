{vars, ...}: {
  launchd.agents.ollama-tailnet = {
    enable = true;
    config = {
      ProgramArguments = [
        "/opt/homebrew/bin/ollama"
        "serve"
      ];
      EnvironmentVariables = {
        # Binding the tailnet address rather than 0.0.0.0 leaves Ollama.app's
        # own 127.0.0.1:11434 server untouched and keeps the LAN out.
        OLLAMA_HOST = "${vars.tailnet.macbook}:11434";
        OLLAMA_MAX_LOADED_MODELS = "1";
        # Reflect calls arrive minutes apart; the default 5m keep-alive
        # reloads 13GB before most of them.
        OLLAMA_KEEP_ALIVE = "-1";
        # Hindsight's reflect context budget is 32768, the same as the default
        # window, so the final synthesis prompt overflowed into context-shift.
        OLLAMA_CONTEXT_LENGTH = "65536";
      };
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 30;
      ProcessType = "Background";
    };
  };
}
