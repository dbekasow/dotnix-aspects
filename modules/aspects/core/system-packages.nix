{
  flake.modules.nixos.system-packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Essential tools
      git
      helix

      # Coreutils but in rust
      uutils-coreutils-noprefix

      # Hardware inspection
      pciutils
      usbutils
    ];
  };
}
