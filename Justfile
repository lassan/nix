default:
    @just --list

rebuild:
  sudo darwin-rebuild switch --flake .#macbook

update:
    nix flake update