{ lib, ... }:
let
  bootstrap = with lib.types; {
    url = lib.mkOption { type = nullOr str; default = null; };
    repository = lib.mkOption { type = nullOr str; default = "dotnix"; };
    destination = lib.mkOption { type = str; default = ".dotnix"; };
  };
in
{
  flake.modules.nixos.bootstrap = { config, lib, pkgs, ... }:
    let cfg = config.dotnix.bootstrap; in {
      options.dotnix = { inherit bootstrap; };

      # Only install the script when a repo URL is configured
      config = lib.mkIf (cfg.url != null) {
        environment.systemPackages = [
          (pkgs.writeShellScriptBin "dotnix-bootstrap" ''
            set -euo pipefail

            REPO="${cfg.url}/${cfg.repository}"
            DEST="$HOME/${cfg.destination}"
            HOSTNAME="$(hostname)"

            if [ ! -d "$DEST/.git" ]; then
              echo "=> Cloning $REPO ..."
              ${lib.getExe pkgs.git} clone "$REPO" "$DEST"
            else
              echo "=> Updating $DEST ..."
              ${lib.getExe pkgs.git} -C "$DEST" pull --ff-only
            fi

            echo "=> Switching to .#$HOSTNAME ..."
            nh os switch "$DEST" -H "$HOSTNAME"
          '')
        ];
      };
    };
}
