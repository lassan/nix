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
      };
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 30;
      ProcessType = "Background";
    };
  };
}
