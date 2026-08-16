{lib, ...}: {
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

    # Hardlinks identical store paths; gc alone never deduplicates.
    optimise.automatic = true;

    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };
}
