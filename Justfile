default:
    @just --list

rebuild:
    sudo darwin-rebuild switch --flake .#macbook

check:
    nix flake check

darwin-rebuild host="macbook":
    sudo darwin-rebuild switch --flake .#{{host}}

nixos-rebuild host:
    sudo nixos-rebuild switch --flake .#{{host}}

update:
    nix flake update

clean:
    sudo nix-collect-garbage -d
