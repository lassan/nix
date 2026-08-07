{
  inputs,
  vars,
  ...
}: {
  imports = [
    ../common

    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.sops-nix.darwinModules.sops

    ./apps.nix
    ./homebrew.nix
    ./system.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit inputs vars;};
    sharedModules = [inputs.worktrunk.homeModules.default];
    users.${vars.userName}.imports = [../../home];
  };
}
