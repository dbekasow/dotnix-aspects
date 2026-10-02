{
  flake.modules.nixos.nix-ld = { lib, pkgs, ... }: {
    programs.nix-ld = {
      enable = lib.mkDefault true;
      libraries = with pkgs; [
        openssl
        stdenv.cc.cc
        zlib
      ];
    };
  };
}
