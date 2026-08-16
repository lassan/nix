{inputs, ...}: {
  imports = [inputs.nix-index-database.homeModules.nix-index];

  # The prebuilt database ships with the input, so `nix-index` never has to be
  # run locally to populate one.
  programs.nix-index.enable = true;

  # `, <cmd>` runs a package from nixpkgs without installing it.
  programs.nix-index-database.comma.enable = true;
}
