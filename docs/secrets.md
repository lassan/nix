# Secrets

Secrets are committed to this repo encrypted with [sops-nix]. Every value in
`secrets/secrets.yaml` is encrypted to a fixed set of `age` recipients listed in
`.sops.yaml`; a machine can decrypt only if its host key was a recipient at
encryption time.

This repo is **public**. See [Threat model](#threat-model) before adding
anything.

## Recipients

| Anchor    | Derived from                    | Role                                       |
| --------- | ------------------------------- | ------------------------------------------ |
| `hassan`  | `~/.ssh/id_ed25519`             | Editing secrets, and the only recovery key |
| `macbook` | `/etc/ssh/ssh_host_ed25519_key` | Decryption at activation on macbook        |

`nixbox` is not yet a recipient — it has no host key until NixOS is installed.
See [Adding a machine](#adding-a-machine).

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

If macbook is lost and `~/.ssh/id_ed25519` was not backed up, `secrets.yaml` is
**permanently undecryptable** and every credential in it must be reissued at
source. Back that key up to Bitwarden.

Stronger: generate a dedicated recovery identity with `age-keygen`, store it
only in Bitwarden, and add it as a third recipient. Do this while you still
hold a working key — recipients can only be added by someone who can already
decrypt.

[sops-nix]: https://github.com/Mic92/sops-nix
