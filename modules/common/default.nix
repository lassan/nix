{vars, ...}: {
  imports = [
    ./apps.nix
    ./nix.nix
    ./secrets.nix
    ./theme.nix
  ];

  nixpkgs = {
    overlays = [(import ../../overlays)];

    config = {
      allowUnfree = true;

      permittedInsecurePackages = [
        "nodejs-20.20.2"
        "nodejs-slim-20.20.2"
        # logseq pins an EOL electron; drop this once upstream moves to a
        # supported one. https://github.com/NixOS/nixpkgs/issues/273611
        "electron-39.8.10"
      ];
    };
  };

  environment.variables.EDITOR = "vim";

  nix.settings.trusted-users = [vars.userName];
}
