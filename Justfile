default:
    @just --list

# Switch this host, a named host, or deploy to one over SSH
deploy host="" ip="":
    @if [ -n "{{ ip }}" ]; then \
      nixos-rebuild switch --flake ".#{{ host }}" \
        --target-host "hassan@{{ ip }}" --build-host "hassan@{{ ip }}" \
        --sudo --ask-elevate-password --no-reexec; \
    elif [ -z "{{ host }}" ] && [ "$(uname)" = "Darwin" ]; then \
      nh darwin switch .; \
    elif [ -z "{{ host }}" ]; then \
      nh os switch .; \
    elif [ "$(uname)" = "Darwin" ]; then \
      nh darwin switch . -H "{{ host }}"; \
    else \
      nh os switch . -H "{{ host }}"; \
    fi

# Format check, lint, then nix flake check
check: fmt-check lint
    nix flake check --all-systems --no-build

# Format everything (alejandra, shfmt, just)
fmt:
    nix fmt

# Fail if anything is unformatted
fmt-check:
    nix fmt -- --ci

# Report nix antipatterns
lint:
    statix check .

# Edit the encrypted secrets file
sops-edit:
    sops secrets/secrets.yaml

# Re-encrypt every secret to the current .sops.yaml recipients
sops-update:
    for file in secrets/*; do sops updatekeys "$file"; done

# Rotate the data key on every secret
sops-rotate:
    for file in secrets/*; do sops --rotate --in-place "$file"; done

# Enable the .githooks/ pre-commit format gate (`nix develop` does this too)
hooks:
    git config core.hooksPath .githooks
    @echo "core.hooksPath -> .githooks"

update: update-packages
    nix flake update

update-packages:
    ./scripts/update-packages

# Re-vendor the Hyprland wiki skill from upstream
update-hyprland-skill:
    ./scripts/update-hyprland-skill

clean:
    nh clean all --keep 5 --keep-since 7d
