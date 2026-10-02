{ inputs, lib, ... }: {
  imports = [ inputs.agenix-rekey.flakeModule ];

  perSystem = { config, pkgs, ... }: {
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
