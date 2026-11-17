{
  dotnix.host.nix-ld.nixos = { lib, pkgs, ... }: {
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
