default:
    @just --list

rebuild:
    sudo darwin-rebuild switch --flake .#macbook --impure

rebuild-home:
    sudo home-manager switch --flake .#macbook

check:
    nix flake check

darwin-rebuild host="macbook":
    sudo darwin-rebuild switch --flake .#{{host}}

nixos-rebuild host:
    sudo nixos-rebuild switch --flake .#{{host}}

update: update-packages
    nix flake update

update-packages:
    ./scripts/update-packages

clean:
    sudo nix-collect-garbage -d
