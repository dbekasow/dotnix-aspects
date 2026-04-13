{ lib, ... }:
let
  credentialsModule = with lib.types; submodule {
    options = {
      host = lib.mkOption { type = str; };
      user = lib.mkOption { type = str; };
    };
  };
in
{
  flake.modules.homeManager.git-credentials = { pkgs, config, lib, ... }:
    let
      mkScriptSecret = name: "git-credential-pat-${name}";
      mkScript = name: user: pkgs.writeShellScriptBin "git-credential-${name}" ''
        [ "$1" = "get" ] || exit 0
        echo "username=${user}"
        echo "password=$(cat ${config.age.secrets."${mkScriptSecret name}".path})"
      '';
      cfg = config.dotnix.git.credentials;
    in
    {
      options.dotnix.git.credentials = lib.mkOption {
        type = with lib.types; attrsOf credentialsModule;
        default = { };
      };

      config = lib.mkIf (cfg != { }) {
        programs.git.settings.credential = { useHttpPath = true; } // lib.mapAttrs'
          (name: cred: lib.nameValuePair "https://${cred.host}" {
            helper = lib.getExe (mkScript name cred.user);
          })
          cfg;

        age.secrets = lib.genAttrs
          (map mkScriptSecret (lib.attrNames cfg))
          (_: { generator.script = "alnum"; mode = "600"; });
      };
    };
}
