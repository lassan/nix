{lib, ...}: {
  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-20.20.2"
    "nodejs-slim-20.20.2"
  ];

  nix = {
    settings = {
      # enable flakes globally
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    # do garbage collection weekly to keep disk usage low
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };
}
