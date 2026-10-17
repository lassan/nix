{
  config,
  inputs,
  vars,
  ...
}: let
  home = config.users.users.${vars.userName}.home;
  sprite = name: {
    inherit name;
    kind = "sprite";
    repoDir = "/home/sprite/repos/sup/main";
    capacity = 1;
    lane = "light";
  };
in {
  imports = [inputs.agent-toolkit.nixosModules.agent-factory];

  sops.secrets = {
    agent-factory-linear-client-id = {};
    agent-factory-linear-client-secret = {};
    agent-factory-linear-webhook-secret = {};
    agent-factory-github-webhook-secret = {};
  };
  sops.templates.agent-factory = {
    owner = vars.userName;
    content = ''
      LINEAR_CLIENT_ID=${config.sops.placeholder.agent-factory-linear-client-id}
      LINEAR_CLIENT_SECRET=${config.sops.placeholder.agent-factory-linear-client-secret}
      LINEAR_WEBHOOK_SECRET=${config.sops.placeholder.agent-factory-linear-webhook-secret}
      GITHUB_WEBHOOK_SECRET=${config.sops.placeholder.agent-factory-github-webhook-secret}
    '';
    restartUnits = ["agent-factory.service"];
  };

  services.agent-factory = {
    enable = true;
    user = vars.userName;
    environmentFile = config.sops.templates.agent-factory.path;
    funnel.enable = true;
    funnel.operatorHttps = true;
    settings = {
      statusUrl = "https://nixbox.tailee4949.ts.net";
      maxRunningTurns = 3;
      fullLaneLabels = ["agency" "creator"];
      hosts = [
        {
          name = "nixbox";
          kind = "local";
          repoDir = "${home}/repos/sup/main";
          capacity = 2;
          lane = "full";
        }
        (sprite "sup-01")
        (sprite "sup-02")
        (sprite "sup-03")
      ];
    };
  };
}
