{ lib, self, ... }:
let
  profile = with lib.types; {
    username = lib.mkOption { type = str; };
    fullname = lib.mkOption { type = nullOr str; default = null; };
    email = lib.mkOption { type = nullOr str; default = null; };
    theme = lib.mkOption { type = str; default = "catppuccin-mocha"; };
  };
in
{
  flake.modules = {
    generic.profile.options = { inherit profile; };

    nixos.core = { config, ... }: {
      home-manager.users = lib.genAttrs config.dotnix.host.members (username: {
        imports = with self.modules; [ generic."${username}" ];
        home.username = username;
      });
    };

    homeManager.core.imports = [ self.modules.generic.profile ];
  };
}
