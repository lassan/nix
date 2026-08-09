{
  inputs,
  vars,
  ...
}: {
  imports = [
    ../common

    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.stylix.nixosModules.stylix

    ./system.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit inputs vars;};
    sharedModules = [inputs.worktrunk.homeModules.default];
    users.${vars.userName}.imports = [../../home ../../home/linux];
  };
}
