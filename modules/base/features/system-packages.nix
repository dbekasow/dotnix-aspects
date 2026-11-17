{
  dotnix.host.system-packages.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Coreutils but in rust
      uutils-coreutils-noprefix

      # Hardware inspection
      pciutils
      usbutils

      # Diagnostics
      lsof
      strace
    ];
  };
}
