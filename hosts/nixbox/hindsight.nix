{
  pkgs,
  vars,
  ...
}: let
  compose = pkgs.formats.yaml {};
  composeFile = compose.generate "hindsight-compose.yaml" {
    services = {
      llama = {
        image = "ghcr.io/ggml-org/llama.cpp:server-cuda@sha256:cf2e30bc855cf58cdbdc65d05b5b5e02afa95fb788343a5334d704367ac5c9ac";
        pull_policy = "always";
        restart = "unless-stopped";
        devices = ["nvidia.com/gpu=all"];
        environment = {
          LLAMA_ARG_HOST = "0.0.0.0";
          LLAMA_ARG_PORT = "8080";
          LLAMA_ARG_HF_REPO = "bartowski/Qwen_Qwen3.5-9B-GGUF";
          LLAMA_ARG_HF_FILE = "Qwen_Qwen3.5-9B-Q6_K.gguf";
          LLAMA_ARG_CTX_SIZE = "32768";
          LLAMA_ARG_N_PARALLEL = "1";
          LLAMA_ARG_N_GPU_LAYERS = "99";
          LLAMA_ARG_MMPROJ_AUTO = "false";
          LLAMA_ARG_REASONING = "off";
        };
        volumes = ["llama-models:/root/.cache/huggingface"];
        healthcheck = {
          test = ["CMD-SHELL" "curl -fsS http://localhost:8080/health || exit 1"];
          interval = "10s";
          timeout = "5s";
          retries = 60;
          start_period = "30s";
        };
      };

      hindsight = {
        image = "ghcr.io/vectorize-io/hindsight:0.9.1";
        pull_policy = "always";
        restart = "unless-stopped";
        depends_on.llama.condition = "service_healthy";
        environment = {
          HINDSIGHT_API_LLM_PROVIDER = "openai";
          HINDSIGHT_API_LLM_BASE_URL = "http://llama:8080/v1";
          HINDSIGHT_API_LLM_API_KEY = "not-needed";
          HINDSIGHT_API_LLM_MODEL = "qwen3.5-9b";
          HINDSIGHT_API_LLM_MAX_CONCURRENT = "1";
          HINDSIGHT_API_LLM_TIMEOUT = "300";
          HINDSIGHT_API_LLM_MAX_RETRIES = "2";
          HINDSIGHT_API_WORKER_ID = "nixbox-hindsight";
        };
        ports = [
          "127.0.0.1:8888:8888"
          "127.0.0.1:9999:9999"
        ];
        volumes = ["hindsight-data:/home/hindsight/.pg0"];
        healthcheck = {
          test = [
            "CMD"
            "python"
            "-c"
            "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8888/health', timeout=5)"
          ];
          interval = "30s";
          timeout = "5s";
          retries = 3;
          start_period = "30s";
        };
      };
    };
    volumes = {
      hindsight-data.name = "hindsight-data";
      llama-models.name = "hindsight-llama-models";
    };
  };
  dockerCompose = "${pkgs.docker-compose}/bin/docker-compose";
in {
  hardware.nvidia-container-toolkit.enable = true;
  users.users.${vars.userName}.extraGroups = ["docker"];

  systemd.services.hindsight = {
    description = "Hindsight memory service";
    wantedBy = ["multi-user.target"];
    after = [
      "docker.service"
      "network-online.target"
      "nvidia-container-toolkit-cdi-generator.service"
    ];
    requires = [
      "docker.service"
      "nvidia-container-toolkit-cdi-generator.service"
    ];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${dockerCompose} -f ${composeFile} up --detach --wait --remove-orphans";
      ExecStop = "${dockerCompose} -f ${composeFile} down";
      TimeoutStartSec = 900;
      TimeoutStopSec = 120;
    };
  };
}
