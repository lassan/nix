{lib, ...}: {
  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-20.20.2"
    "nodejs-slim-20.20.2"
    # logseq pins an EOL electron; drop this once upstream moves to a
    # supported one. https://github.com/NixOS/nixpkgs/issues/273611
    "electron-39.8.10"
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
