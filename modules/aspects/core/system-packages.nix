{
  flake.modules.nixos.system-packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Coreutils but in rust
      uutils-coreutils-noprefix

      # Editor
      helix

      # Hardware inspection
      pciutils
      usbutils

      # Diagnostics
      lsof
      strace
    ];
  };
}
