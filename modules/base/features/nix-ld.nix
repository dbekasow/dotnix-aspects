{
  dotnix.host.nix-ld.nixos = { pkgs, ... }: {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        openssl
        stdenv.cc.cc
        zlib
      ];
    };
  };
}
