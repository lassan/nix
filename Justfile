default:
    @just --list

rebuild:
  sudo darwin-rebuild switch --flake .#macbook

update:
    nix flake update

clean:
    sudo nix-collect-garbage -d