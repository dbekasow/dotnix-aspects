{
  flake.modules.nixos.bootstrap = { pkgs, ... }:
    let
      dotnix-install = pkgs.writeShellScriptBin "dotnix-install" ''
        set -euo pipefail
        : "''${1:?hostname required}" "''${2:?disk required}"

        exec sudo nix run github:nix-community/disko/latest#disko-install -- \
          --write-efi-boot-entries \
          --flake "''${DOTNIX_FLAKE:-github:dbekasow/dotnix}#$1" \
          --disk main "$2"
      '';
    in
    {
      environment.systemPackages = [ dotnix-install ];
    };
}
