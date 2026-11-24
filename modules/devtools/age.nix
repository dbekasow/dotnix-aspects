{ inputs, lib, ... }:
{
  flake-file.inputs.agenix-rekey = {
    url = "github:oddlama/agenix-rekey";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      devshell.follows = "devshell";
      pre-commit-hooks.follows = "git-hooks";
      treefmt-nix.follows = "treefmt";
    };
  };

  imports = lib.optionals (inputs ? agenix-rekey && inputs ? devshell) [
    inputs.agenix-rekey.flakeModule
    {
      perSystem = { config, pkgs, ... }: {
        devshells.default.packages = [ pkgs.rage pkgs.age-plugin-yubikey config.agenix-rekey.package ];

        # agenix-rekey moved its apps to flake.agenix-rekey.<system>.<app>, which
        # `nix run` cannot reach; re-expose the two documented flows around the
        # agenix wrapper so `nix run .#rekey` / `.#generate` keep working.
        apps.generate = {
          program = lib.getExe (pkgs.writeShellScriptBin "agenix-generate"
            ''exec ${lib.getExe config.agenix-rekey.package} generate "$@"'');
          meta.description = "Generate the agenix-rekey vault for all hosts";
        };
        apps.rekey = {
          program = lib.getExe (pkgs.writeShellScriptBin "agenix-rekey"
            ''exec ${lib.getExe config.agenix-rekey.package} rekey "$@"'');
          meta.description = "Rekey the agenix-rekey vault for all hosts";
        };
      };
    }
  ];
}
