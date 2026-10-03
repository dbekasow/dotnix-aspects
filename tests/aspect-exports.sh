#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
nix eval --impure --no-write-lock-file --file tests/aspect-exports.nix

diagnostic=$(nix eval --impure --no-write-lock-file --show-trace --expr '
  let
    flake = builtins.getFlake (toString ./.);
    host = flake.inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        flake.nixosModules.dotnix
        flake.nixosModules.dms-greeter
        { dotnix.hostname = "fixture"; }
      ];
    };
  in
  host.config.programs.dms-greeter.configHome
' 2>&1) && {
  printf '%s\n' "invalid exported module unexpectedly evaluated" >&2
  exit 1
}

printf '%s\n' "$diagnostic" | grep -F \
  'modules/aspects/desktop/greeter/dms-greeter/dms-greeter.nix:' >/dev/null
