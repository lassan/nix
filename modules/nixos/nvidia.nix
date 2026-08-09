{config, ...}: {
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Wayland compositors need the KMS driver.
    modesetting.enable = true;

    # GA102 is Ampere, where the open kernel modules are the supported path.
    open = true;

    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
