# Secrets

Secrets are committed to this repo encrypted with [sops-nix]. Every value in
`secrets/secrets.yaml` is encrypted to a fixed set of `age` recipients listed in
`.sops.yaml`; a machine can decrypt only if its host key was a recipient at
encryption time.

This repo is **public**. See [Threat model](#threat-model) before adding
anything.

## Recipients

| Anchor          | Derived from                    | Role                                       |
| --------------- | ------------------------------- | ------------------------------------------ |
| `hassan`        | `~/.ssh/id_ed25519` on macbook  | Editing secrets from macbook               |
| `macbook`       | `/etc/ssh/ssh_host_ed25519_key` | Decryption at activation on macbook        |
| `nixbox`        | `/etc/ssh/ssh_host_ed25519_key` | Decryption at activation on nixbox         |
| `hassan-nixbox` | `age-keygen` on nixbox          | Editing secrets from nixbox                |
| `recovery`      | `age-keygen`, stored in Bitwarden only | Last resort if every machine is lost |

`hassan-nixbox` is a standalone identity rather than a copy of `hassan`, so
editing from nixbox never required moving the recovery key onto a second
machine, and revoking nixbox is an edit to `.sops.yaml` plus `just sops-update`.

## How it fits together

`modules/common/secrets.nix` imports the platform-appropriate sops-nix module
and points every host at `secrets/secrets.yaml`. At activation
`sops-install-secrets` converts the host's SSH key to an age identity in memory
and writes decrypted values to `/run/secrets/<name>` — on macOS a 64 MB HFS
ramdisk, recreated each boot. Nothing is ever written to disk in plaintext.

Consumers reference `config.sops.secrets.<name>.path`, never a literal path.
`hosts/macbook/github-runner.nix` is the worked example.

## Bootstrap on a machine you already own

The sops CLI needs an age identity to decrypt. Derive it from the SSH key that
is already a recipient:

```sh
mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

`SOPS_AGE_KEY_FILE` points there from `home/shell.nix`. This file is
machine-local and must never be committed.

On a machine that should be able to edit secrets without holding the recovery
key, generate a standalone identity instead and enrol its public half, as
`hassan-nixbox` was:

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt   # the age1… to add to .sops.yaml
```

Generate it on the machine that will use it; the private half never needs to
move, and dropping that machine is an edit to `.sops.yaml` plus
`just sops-update`.

> **The single most confusing failure mode.** There are two incompatible ways to
> use an SSH key as an age key, and they are mutually undecryptable:
>
> - `ssh-to-age` derives an X25519 `age1…` recipient. This is what
>   `sops-install-secrets` uses, and it is the **only** form that works at
>   activation.
> - The sops CLI, given no config, probes `~/.ssh/id_ed25519` directly and
>   expects `ssh-ed25519 AAAA…` recipient stanzas.
>
> Everything here uses the `age1…` form, which is why `keys.txt` above is
> mandatory rather than optional. If sops reports that your identity did not
> match any of the recipients when you are certain you hold the key, this is
> why.

## Day-to-day

```sh
just sops-edit      # decrypt to $EDITOR, re-encrypt on save
just sops-update    # re-encrypt to the current .sops.yaml recipients
just sops-rotate    # generate a new data key for every secret
```

After editing, commit the file and `just deploy`.

Adding a secret is two steps: a new key in `just sops-edit`, and a
`sops.secrets.<name> = {};` declaration in the module that consumes it. Set
`owner`/`group` if the reader is not root — the darwin defaults are
`owner = "root"`, `group = "staff"`, `mode = "0400"`.

## Adding a machine

Order matters: a machine cannot decrypt a file that it was not a recipient of
when that file was encrypted. Generate the host key **before** the first
`deploy`, not after.

1. On the new machine (from the installer, before `nixos-install`):

   ```sh
   ssh-keygen -t ed25519 -N "" -C "" -f /mnt/etc/ssh/ssh_host_ed25519_key
   ssh-to-age < /mnt/etc/ssh/ssh_host_ed25519_key.pub
   ```

   On macOS the key already exists if Remote Login was ever enabled; otherwise
   `sudo ssh-keygen -A` creates it.

2. On a machine that already holds a recipient key, add the printed `age1…` to
   `.sops.yaml` as a new anchor and add it to the `key_groups` list.

3. `just sops-update`, then commit and push.

4. Only now install/deploy the new machine.

Skipping steps 2–3 leaves the machine unable to decrypt; it boots with secrets
missing and needs a second rebuild after you rekey.

## Rotation

Rotating a credential is `just sops-edit`, paste the new value, commit, deploy.
Rotating the _keys_ — after replacing an SSH key, or to drop a machine — is an
edit to `.sops.yaml` followed by `just sops-update`. Removing a recipient does
**not** retroactively protect anything already pushed; see below.

## Threat model

The repo is public, so every encrypted file is permanently harvestable. The
crypto is sound — `age` X25519 — but the exposure is not time-bounded:

- **Committed ciphertext is forever.** Anyone can clone today and decrypt years
  later if they obtain a recipient key. Deleting the commit does not help, and
  neither does removing a recipient.
- **`~/.ssh/id_ed25519` currently has no passphrase.** It is a recipient, so
  compromise of that one file exposes every secret here. Consider a passphrase,
  or replacing it as a recipient with a dedicated age identity kept only in
  Bitwarden.
- **Every recipient can read every secret.** There is one creation rule.
  Per-secret scoping requires additional `creation_rules` with narrower
  `path_regex`.
- **Metadata is public**: recipient public keys verbatim, how many there are,
  the secret _names_, `lastmodified`, and exact plaintext length. Only the
  values are hidden. If a name is itself sensitive, use a separate file with
  `format = "binary"` — though the filename then leaks the same thing.

Treat anything committed here as eventually-exposed. Keep tokens
minimally-scoped and short-lived, and rotate on a schedule.

## Recovery

The `recovery` identity exists for the case where every machine is gone. It was
generated with `age-keygen`, never written to any disk, and lives only in
Bitwarden. To use it, put its secret key in `keys.txt` on a trusted machine,
decrypt, then rotate — see [Rotation](#rotation).

Recipients can only be added by someone who can already decrypt, so a lost key
cannot be replaced after the fact. Everything below therefore has to stay true
while at least one key still works:

- `recovery` must be reachable without either machine. If unlocking Bitwarden
  depends on something only on macbook, the independence is illusory.
- `hassan` is `~/.ssh/id_ed25519` on macbook and has no passphrase; back it up
  to Bitwarden too, since anyone holding that one file can read every secret
  ever committed to this public repo.
- `hassan-nixbox` is an editing convenience, not a backup — it sits on a machine
  that dual-boots Windows.

If all five recipients are lost, `secrets.yaml` is **permanently undecryptable**
and every credential in it must be reissued at source.

[sops-nix]: https://github.com/Mic92/sops-nix
