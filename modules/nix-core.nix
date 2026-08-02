{lib, ...}: {
  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-20.20.2"
    "nodejs-slim-20.20.2"
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };
}
