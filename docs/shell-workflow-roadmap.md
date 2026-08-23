# Shell / terminal workflow roadmap

Assessment done 2026-08-01 against this repo plus 9,497 commands of atuin
history. Suggestions are ordered by **learning difficulty**, not by value —
the point is to be able to pick work that fits the time available.

## Baseline: what the history says

| Command                    | Count | Share   |
| -------------------------- | ----- | ------- |
| `git status`               | 1813  | **19%** |
| `nx`                       | 1280  | 13%     |
| `gitui`                    | 421   | 4.4%    |
| `just`                     | 342   |         |
| `pn` / `pnpx`              | 482   |         |
| `code`                     | 296   |         |
| `wt` (worktrunk)           | 260   |         |
| `claude`                   | 225   |         |
| `darwin-rebuild`           | 191   |         |
| `git rebase` + `git stash` | 245   |         |

Total 9,497 commands, 1,851 unique. One in five commands typed is
`git status` — that is the single loudest signal in the dataset.

## Already solid

The fzf preview script, the zellij keybind rework, zj-radar, worktrunk, and
the inline comments explaining _why_ (the zvm/autosuggestions load ordering,
the `historyWidget.command = ""` handoff to atuin, the `autocrlf = "input"`
note) are all above average. Everything below is a gap, not a fix.

---

## Tier 1 — trivial (under 30 min, no new concepts)

### 1. `fzf-tab` — highest ROI item in this document ✅ DONE

The fzf preview pipeline in `home/fzf.nix` only fired on `Ctrl-T`, `Alt-C`,
and `**<TAB>`. fzf-tab routes _every_ completion — `git checkout <TAB>`,
`kubectl` namespaces, `nx run <TAB>` — through fzf with the same previews.
The expensive part (the preview script) was already built.

Implemented in `home/fzf.nix`. Notes that mattered:

- Must load after `compinit`. Home Manager runs `compinit` at line 8 of the
  generated `.zshrc`, before any `initContent`, so this is automatic.
- Binds `^I`, so it has to load from `zvm_after_init_commands` or zsh-vi-mode
  clobbers the binding — the same trap already documented for
  zsh-autosuggestions in `home/shell.nix`.
- `zstyle ':completion:*' menu no` is **required**; fzf-tab is incompatible
  with zsh's `menu select`.
- The `descriptions format` zstyle is what gives fzf-tab its group headers.

### 2. Syntax highlighting ✅ DONE

`zsh-autosuggestions` was configured but nothing highlighted the line itself,
so a typo'd command stayed the default colour until you hit enter.
`zsh-fast-syntax-highlighting` added to `home/shell.nix`, loaded last in the
`zvm_after_init_commands` array (after autosuggestions, which is the only
ordering constraint that actually matters).

### 3. Set `EDITOR` explicitly ✅ DONE

`EDITOR` was `vim` only by inheritance — nothing in this repo set it. It is
what `git commit`, `git rebase -i`, zellij's `EditScrollback` and yazi all
drop you into, so it should be a deliberate choice. Now set explicitly to
`vim` (with `VISUAL` to match, which was previously empty) in
`home/shell.nix`.

### 4. zsh history settings ✅ DONE

Why bother when atuin exists, since it was not obvious:

Atuin and zsh's own history are **two separate stores**, and atuin only
replaces one of the two ways you reach history:

- **Atuin owns recall.** `Ctrl-R` is atuin's SQLite database — cross-session,
  cross-machine, synced, searchable. This is most of what you use.
- **zsh's `$HISTFILE` still owns everything else.** Up-arrow, `!!`,
  `!$` / `!*` (last argument of the previous command), `^foo^bar` quick
  substitution, and `fc` all read zsh's in-memory history list, not atuin's.
  So does any plugin doing its own history lookup.

So the settings are worth setting if you use up-arrow or `!$` — and are close
to pointless if you reach for `Ctrl-R` every time. The relevant ones:

```nix
history = {
  size = 100000;
  save = 100000;
  ignoreDups = true;            # collapse consecutive duplicates
  ignoreSpace = true;           # leading space = don't record (useful for secrets)
  expireDuplicatesFirst = true; # evict dupes before unique commands when trimming
};
```

`ignoreSpace` is the one with standalone value regardless of `Ctrl-R` habits:
prefix a command with a space and it stays out of the history file entirely.

Applied in `home/shell.nix`, replacing the 10,000-entry no-dedup default.

### 5. Git credential helper — _skipped by choice_

`credential.helper = "store"` in `home/git.nix` writes tokens as plaintext to
`~/.git-credentials`. macOS `osxkeychain` is the drop-in fix. Deliberately
left alone for now; noted here so it is not forgotten.

### 6. `nh` (nix-helper) ✅ DONE

Wraps `darwin-rebuild` / `nixos-rebuild` / `home-manager` behind one command
with better output. What it adds over the current `just rebuild`:

- **A package diff after every build.** Prints exactly which packages were
  added, removed, or version-bumped between the old and new generation. This
  is the main draw — right now `darwin-rebuild switch` gives you no idea what
  actually changed, which matters given the `nix flake update` cadence here.
- **Real progress output** instead of a wall of nix build log, with the actual
  error surfaced at the end rather than buried.
- **`nh clean`** — generation GC with retention policy (`--keep 5`,
  `--keep-since 7d`) rather than the all-or-nothing
  `nix-collect-garbage -d` currently in the Justfile.
- Reads `$NH_FLAKE` so you can run it from any directory.

It does **not** replace `just` — it replaces the command _inside_ the recipe,
so the `just` muscle memory (342 invocations) is preserved entirely.

Applied in the `Justfile` and `modules/common/apps.nix`, with `NH_FLAKE` set in
`home/shell.nix` so `nh` also works from outside the repo. Gotchas found while
wiring it up:

- **Do not prefix the recipes with `sudo`.** nh elevates itself for activation
  and panics when it is already root, unless `-R/--bypass-root-check` is given.
  All the rebuild recipes lost their `sudo` in this change.
- **`--impure` goes after `--`.** nh's signature is
  `nh darwin switch [OPTIONS] [INSTALLABLE] [-- <EXTRA_ARGS>...]`, and the extra
  args are forwarded to `nix build`. The flag is genuinely still required:
  `hosts/macbook/github-runner.nix` reads an absolute token path, so a pure
  eval fails.
- Hostname detection needs no help — `hostname` is already `macbook`, matching
  the `darwinConfigurations` attr. `-H` is only passed in the parameterised
  recipes.

### Pre-existing issues noticed while doing this

Neither is caused by the changes above; both were already there.

- **`just rebuild-home` is broken.** It runs
  `home-manager switch --flake .#macbook`, but `flake.nix` only outputs
  `darwinConfigurations` and `nixosConfigurations` — there is no
  `homeConfigurations.macbook`. Home Manager is wired in as a darwin module, so
  `just rebuild` already covers it. The recipe is probably just dead and could
  be deleted.
- **`just darwin-rebuild` was missing `--impure`**, so it would have failed for
  the same token-path reason as above. Fixed in passing as part of the nh
  conversion.

### 7. `comma` — _skipped by choice_

`, cowsay hello` runs any nixpkgs binary without installing it. No compelling
use case identified.

---

---

## Note: zsh-vi-mode init mode

Worth knowing before touching `home/shell.nix`, because it explains why the
plugin loading there looks unremarkable.

zsh-vi-mode defaults to `precmd_functions+=(zvm_init)` — it initializes at the
**first prompt**, after the whole of `.zshrc` has run, and overwrites
keybindings set earlier. The usual workaround is to funnel every plugin and
`bindkey` through `zvm_after_init_commands` /
`zvm_after_lazy_keybindings_commands`, which is what this config used to do.

That workaround is worse than it looks:

- it couples unrelated config (fzf, atuin, autosuggestions) to zvm's lifecycle
- `zvm_after_lazy_keybindings_commands` **only fires on the first entry into
  normal mode**, because zvm calls it from inside
  `if [[ $mode == $ZVM_MODE_NORMAL ]] && (( $#ZVM_LAZY_KEYBINDINGS_LIST > 0 ))`.
  Anything in that hook is silently dead until you happen to press Escape.
  This is what made `Alt-t` (and `Alt-f`, `Alt-b`, `Alt-←/→`) report
  `undefined-key` in a fresh shell.
- `ZVM_LAZY_KEYBINDINGS=false` is **not** the fix. It leaves
  `ZVM_LAZY_KEYBINDINGS_LIST` uncreated, so the guard above is never true and
  the hook fires _never_ instead of late.

The actual fix is `ZVM_INIT_MODE=sourcing`, which runs `zvm_init` at source
time (`zsh-vi-mode.zsh`: `case $ZVM_INIT_MODE in sourcing) zvm_init;; ...`).
After that the file is ordinary zsh startup — source a plugin, bind a key, in
the order written — and the only rule left is the normal one: load after
whatever you intend to override. Current order in `home/shell.nix`:

    zsh-vi-mode -> atuin -> autosuggestions -> fzf-tab -> bindkeys -> fast-syntax-highlighting

fast-syntax-highlighting stays last because it wraps the widgets everything
above defines.

**Verifying changes here:** `zsh -i -c` is useless for this — ZLE never
engages, so zvm's hooks don't run and every binding looks wrong. Drive a real
pty instead (`python3 -c 'import pty; pty.fork()'`, write keystrokes to the
fd), which is how the `undefined-key` bug was actually pinned down.

---

## Tier 2 — moderate (a weekend, one new concept each)

### 8. direnv + nix-direnv — biggest structural gap

`home/shell.nix` currently has:

```nix
nx = "pnpm nx"; # temporary alias until I figure out dev shells for globals
```

direnv **is** the answer to that comment. A per-project `.envrc` gives:

- correct node per repo via a flake, replacing `fnm --use-on-cd`
- project-scoped `nx` / `pn` without global aliases
- per-repo secrets and env vars
- `nix-direnv` caches the dev shell so `cd` does not stall

This is the change that makes the rest of the nix investment pay off daily.

### 9. `git-absorb`

145 `git rebase` and 100 `git stash` invocations. `git absorb --and-rebase`
takes uncommitted changes and automatically squashes each hunk into the
commit that introduced that line. Removes most manual `rebase -i`.

### 10. Kill the 1,813 `git status` calls ✅ DONE

Both halves landed: `git_status` now carries counts in `home/starship.nix`, and
`Alt-Shift-g` opens `gitui` in a floating pane in `home/zellij.nix`.

The prompt went from starship's bare default (`[!?]` — enough to know
_something_ changed, not enough to stop you typing the command) to a counted,
coloured block:

```
+489 -391 [!35✘5?3$3]     # monorepo: 35 modified, 5 deleted, 3 untracked, 3 stashed
          [+11!3⇡2]       # this repo: 11 staged, 3 modified, 2 commits ahead
          [+1!1?2$1⇕⇡1⇣2] # diverged 1 ahead / 2 behind
                          # clean and synced renders nothing at all
```

Things that were not obvious:

- **`$` is a variable sigil to starship.** The conventional stash symbol has to
  be written `\$`; a bare `$` doesn't error, it silently renders the _entire_
  segment empty. Same trap as `${ahead_count}` in `diverged`, which then needs
  escaping again on the way through Nix (`"\${ahead_count}"`).
- **`up_to_date` means "in sync with upstream", not "clean".** Setting it to
  `✓` produces `[!35✘5?3$3✓]` — a tick sitting next to 43 dirty files, which
  reads as all-clear. It is deliberately left empty, so "no bracket block at
  all" is the unambiguous signal for clean _and_ synced.
- **`git_metrics` renders immediately before `git_status`** and also uses a
  bold green `+N`, so `+489 -391 +11!3` reads as one run of numbers. Hence the
  literal `\[ \]` in the format: bracketed = file counts, bare = line counts.
- **No `command_timeout` bump was needed.** Measured 47 ms in the 3,806-file
  monorepo against starship's 500 ms default — 10× headroom. Worth knowing
  because a timeout here fails _silently_ (the block just vanishes), which
  would break the item exactly where it matters most.

And on the zellij side:

- **A `Run` pane inherits the focused pane's _current_ cwd**, including after a
  `cd` — undocumented, and the thing the whole binding depends on. Verified by
  driving a real pty, since it's what makes `Alt-Shift-g` open the right repo when
  hopping between worktrunk worktrees rather than always landing in `$HOME`.
- **`close_on_exit true`** means `q` in gitui leaves nothing behind, so
  repeated presses can't stack floating panes. The tradeoff: outside a git repo
  gitui exits immediately with an error and the pane just flashes — reads as
  "nothing happened", which is the honest outcome.
- Testing this needs a pty for the same reason the zsh-vi-mode note above gives:
  key handling never engages otherwise. `starship prompt` is easier — point
  `STARSHIP_CONFIG` at a generated file and read stdout — but note its output
  starts with a blank line, so naive `head -1` on it shows nothing and looks
  like a broken config.

### 11. treefmt-nix + git hooks ✅ DONE

`alejandra` was installed but nothing enforced it, and `nix fmt` only knew
about `*.nix` — the shell script, the Justfile, the JSON and these docs had no
formatter at all.

`treefmt.nix` now drives four formatters behind one `nix fmt`: alejandra
(`*.nix`), shfmt (shell), prettier (`*.md`, `*.json`, `*.yaml`) and
`just --fmt`. `flake.nix` exposes it three ways — `formatter` (so `nix fmt`
works), `checks.<system>.formatting` (so `nix flake check` fails on drift) and
a `devShells.default` carrying the treefmt wrapper.

New commands: `just fmt`, `just fmt-check`, `just hooks`.

Things that were not obvious:

- **`--fail-on-change` is not a dry run.** treefmt always writes; `--ci` (which
  implies `--no-cache --fail-on-change`) formats the files and _then_ exits
  non-zero. The pre-commit hook is written around that: it lets the rewrite
  happen but deliberately does not `git add` the result, because treefmt reads
  the working tree rather than the index and re-staging would sweep in the
  unstaged half of a partially staged file.
- **Git will not read `core.hooksPath` from a tracked file** — by design, or
  cloning a repo would be arbitrary code execution. So `.githooks/` cannot be
  enabled declaratively from inside this repo. `just hooks` sets it, and the
  dev shell's `shellHook` does the same, which is what makes it automatic once
  direnv (#8) lands.
- **shfmt's `-s` had to go.** treefmt-nix enables simplify by default, which
  rewrote `[[ "$x" == "$y" ]]` into `[[ $x == "$y" ]]` throughout
  `scripts/update-packages`. Safe inside `[[ ]]`, but it is a change to the
  code rather than its layout. `-ci` was added for the opposite reason: shfmt
  does not indent `case` bodies by default and would have flattened every one.
- **shfmt matches on extension only**, so `scripts/update-packages` and
  `.githooks/pre-commit` were invisible to it until they were added to
  `settings.formatter.shfmt.includes`. That option _appends_ rather than
  replaces — list options merge by concatenation in the module system.
- **prettier searches upward for a `.prettierrc`** when treefmt-nix passes no
  `--config`, which it only does when the program has no settings. Setting
  `proseWrap = "preserve"` both pins the behaviour these hand-wrapped docs need
  and generates a config file, which ends the search at the repo.
- **`git add` before `nix fmt`.** A new file that is untracked is invisible to
  a flake, so `nix fmt` fails with "Path ... is not tracked by Git" rather than
  formatting it. `git add -N` is enough.

Pre-existing issue this surfaced: **`nix flake check` fails on
`nixosConfigurations.nixbox`** — `fileSystems` has no root entry and
`programs.ghostty.systemd.enable` is true with a null package. Confirmed
against a clean clone at HEAD, so it predates this change, but it means the
`checks.formatting` backstop never gets reached. `just check` therefore runs
`fmt-check` first as a dependency.

### 12. Editor fragmentation

VS Code, Zed and WebStorm are all installed; only Zed is in nix and none are
configured declaratively. Three unmanaged states.

---

## Tier 3 — hard (weeks of relearning, genuinely next level)

### 13. Jujutsu (`jj`)

The usage profile is the textbook case: 1,813 status checks, 145 rebases,
100 stashes, heavy worktree use via worktrunk. jj makes the working copy a
commit — no staging area, no stash, conflicts are recorded rather than
blocking, and `jj undo` reverses anything. Colocates with git
(`jj git init --colocate`), so the repo stays a normal git repo.

**Cost is real:** two to three weeks before you are faster than you are now,
and the gitui workflow is temporarily lost (no mature jj TUI equivalent).
Try it on `~/.config/nix` or `~/repos/skills` first, never the monorepo.

### 14. Carapace ✅ DONE

Cross-shell completion specs for ~1,000 CLIs — `gh`, `fly`, `doctl`,
`kubectl`, `pulumi`, `docker`, all in active use here. Composes with fzf-tab.
The difficulty is not conceptual: it conflicts with zsh's native completions
and needs care about which tools it takes over.

Implemented in `home/shell.nix`. The conflict turned out to be the whole
job — `carapace _carapace zsh` `compdef`s **646** commands unconditionally,
and a lot of those already had a better owner:

- **zsh's bundled completers.** `_git` knows your branches, `_make` parses the
  Makefile, `_tar` lists the archive, `_sudo` completes the command _after_
  it. A static spec can't do any of that. Worse on darwin: carapace's
  coreutils specs are generated from GNU man pages, so `ls <TAB>` offers
  `--group-directories-first` and friends that BSD `ls` doesn't have.
- **Completers the tool ships itself**, landing in `share/zsh/site-functions`
  via nixpkgs and so versioned with the binary. 23 of these were already
  installed — including `gh`, `flyctl` and `docker`, three of the six CLIs
  this item was written to fix. That coverage already existed.

So the rule is _fill gaps, never displace_, and it's enforced by diff rather
than by a hand-written `CARAPACE_EXCLUDES` list:

```zsh
typeset -A _comps_before
_comps_before=("${(@kv)_comps}")
source <(carapace _carapace zsh)
for _c in "${(@k)_comps_before}"; do
  [[ ${_comps[$_c]} == _carapace_completer ]] && _comps[$_c]=${_comps_before[$_c]}
done
```

Snapshot what `compinit` found, let carapace overwrite everything, then hand
back every command that already had an owner. 213 of the 646 go back; the
remaining 433 are the ones nothing else covered — `kubectl`, `pulumi`,
`doctl`, `terraform`, `glab`, `aws`, `helm`, `k9s`, `jj`, `pnpm`, `restic`,
`op`, `task`, `vercel`, `turbo`, `deno`. Because it's a diff, the list can't
rot: install a tool that brings its own completer and carapace steps aside on
the next rebuild, with nothing to edit here.

Other notes:

- Snapshotting `_comps` rather than globbing `_*` in `$fpath` matters — one
  file can own several commands (`_gzip` is `#compdef gzip gunzip zcat`), and
  the filename glob misses the aliases. It also picks up the two `compdef`s
  done by hand just above it, for `zellij` and `temporal`.
- `programs.carapace.enableZshIntegration` is **off**. Home Manager's version
  emits the same `source <(...)` but at an `initContent` order it picks, and
  this has to run after those `compdef`s. `enable` is still what puts the
  binary on `PATH`, which the completer needs at runtime — it shells out to
  bare `carapace` on every TAB.
- Composes with fzf-tab with no extra wiring. Carapace sets `group-name` and
  `list-colors` on its own `curcontext`, which is what fzf-tab reads for
  grouped, coloured candidates.
- Costs about 10 ms of shell startup for the subprocess, in line with the five
  `eval "$(... )"` calls already in the file.

---

## Suggested order

1. **Tier 1 items 1, 2, 3, 4, 6** — done. Items 5 and 7 skipped by choice.
2. **treefmt-nix** (#11) — done.
3. **direnv** (#8) — the real unlock, and it dissolves the `nx` alias problem.
   Also what makes the `.githooks/` install from #11 automatic.
4. **git-absorb** (#9) — 5-minute install against 245 rebase/stash calls.
5. **jj** (#13) — when there is a genuinely slow week.
