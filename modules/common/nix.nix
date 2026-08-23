{
  config,
  lib,
  vars,
  ...
}: {
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      max-jobs = "auto";

      # gc otherwise evicts `nix develop` closures within the week, forcing a
      # rebuild of every dev shell.
      keep-outputs = true;
      keep-derivations = true;
    };

    # Unauthenticated api.github.com allows 60 requests an hour, which flake
    # input fetching exhausts. The token is a nix.conf line in the secret
    # rather than an option here: nix.settings lands in the world-readable
    # /etc/nix/nix.conf. `!include` tolerates the file being absent, so nix
    # still works before the first activation decrypts it.
    extraOptions = "!include ${config.sops.secrets.nix-access-tokens.path}\n";

    # Hardlinks identical store paths; gc alone never deduplicates.
    optimise.automatic = true;

    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };

  # Flake input fetching runs as the invoking user, not the daemon.
  sops.secrets.nix-access-tokens.owner = vars.userName;
}
