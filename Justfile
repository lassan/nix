default:
    @just --list

rebuild:
  sudo darwin-rebuild switch --flake .

update:
    nix flake update