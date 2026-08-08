{
  # treefmt locates the repo root by walking up until it finds this file, so
  # `nix fmt` and the pre-commit hook agree on scope no matter the cwd.
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true;
    just.enable = true;

    shfmt = {
      enable = true;
      indent_size = 2;
      # treefmt-nix enables `-s` by default, which rewrites `[[ "$x" == "$y" ]]`
      # into `[[ $x == "$y" ]]`. That is a change to the code rather than its
      # layout, and it reads as if the quoting were careless.
      simplify = false;
    };
  };

  settings = {
    # `.serena/` is tool-managed and `flake.lock` is generated; reformatting
    # either only produces diff noise the generator will undo.
    excludes = [
      ".serena/**"
      "flake.lock"
      # Vendored upstream docs; reformatting would only fight the next sync.
      ".claude/skills/**"
    ];

    formatter.shfmt = {
      # shfmt globs by extension only, so the extensionless scripts in
      # `scripts/` and `.githooks/` are invisible to it.
      includes = ["scripts/*" ".githooks/*"];
      # Indent `case` arm bodies; off by default, and shfmt would flatten the
      # scripts here that already indent them.
      options = ["-ci"];
    };
  };
}
