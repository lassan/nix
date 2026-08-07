{
  platform,
  sops-nix,
  ...
}: {
  imports = [
    (
      if platform == "darwin"
      then sops-nix.darwinModules.sops
      else sops-nix.nixosModules.sops
    )
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;

    # The NixOS default derives this from services.openssh.hostKeys, which is
    # empty while sshd is off; the darwin module hardcodes a different list.
    # Pinning it keeps both platforms on the key that .sops.yaml encrypts to.
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    # https://github.com/Mic92/sops-nix/issues/427 — the non-empty default
    # imports the RSA host key into a GPG keyring on every activation.
    gnupg.sshKeyPaths = [];
  };
}
