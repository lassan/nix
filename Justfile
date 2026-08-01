default:
    @just --list

rebuild:
    nh darwin switch . -- --impure

# `nix flake check` covers formatting too, via checks.<system>.formatting — but
# it currently dies first on nixosConfigurations.nixbox (no root fileSystems),
# so fmt-check runs up front where it can actually be seen.

# Format check, then nix flake check
check: fmt-check
    nix flake check

# Format everything (alejandra, shfmt, prettier, just)
fmt:
    nix fmt

# --ci implies --no-cache --fail-on-change

# Fail if anything is unformatted
fmt-check:
    nix fmt -- --ci

# Git will not take core.hooksPath from a tracked file, so this cannot be
# declarative. `nix develop` does the same thing on shell entry.

# Enable the .githooks/ pre-commit format gate
hooks:
    git config core.hooksPath .githooks
    @echo "core.hooksPath -> .githooks"

darwin-rebuild host="macbook":
    nh darwin switch . -H {{ host }} -- --impure

nixos-rebuild host:
    nh os switch . -H {{ host }}

update: update-packages
    nix flake update

update-packages:
    ./scripts/update-packages

clean:
    nh clean all --keep 5 --keep-since 7d
