{
  # treefmt locates the repo root by walking up until it finds this file, so
  # `nix fmt` and the pre-commit hook agree on scope no matter the cwd.
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true; # *.nix — same formatter flake.nix already exposed
    just.enable = true; # Justfile
    prettier.enable = true; # *.md, *.json, *.yaml/*.yml

    shfmt = {
      enable = true; # *.sh, *.bash, *.envrc, plus the includes below
      indent_size = 2; # matches scripts/update-packages as written
      # treefmt-nix turns `-s` on by default, which rewrites
      # `[[ "$x" == "$y" ]]` into `[[ $x == "$y" ]]`. Dropping the quotes on
      # the left of `==` is safe inside `[[ ]]` but it is a change to the code,
      # not to its layout, and it makes the script read as if the quoting were
      # careless. A formatter should not have opinions this far in.
      simplify = false;
    };

    # Without explicit settings treefmt-nix passes no `--config`, and prettier
    # then walks up past the repo looking for a `.prettierrc` to obey. Pinning
    # proseWrap here both writes a config file (ending that search) and keeps
    # the hand-wrapped ~76-column prose in `docs/` from being reflowed —
    # prettier still normalizes tables, list markers and emphasis.
    prettier.settings.proseWrap = "preserve";
  };

  settings = {
    # `.serena/` is tool-managed and `flake.lock` is generated; reformatting
    # either only produces diff noise the generator will undo.
    excludes = [
      ".serena/**"
      "flake.lock"
    ];

    formatter.shfmt = {
      # shfmt globs by extension only, so the extensionless scripts in
      # `scripts/` and `.githooks/` are invisible to it. Module-system list
      # options merge by concatenation, so this appends to the shfmt module's
      # own includes rather than replacing them.
      includes = ["scripts/*" ".githooks/*"];
      # Indent the body of a `case` arm. Off by default, but every script here
      # already indents, and shfmt would otherwise flatten them all.
      options = ["-ci"];
    };
  };
}
