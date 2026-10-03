{ lib, self, ... }:
let
  profile = with lib.types; {
    fullname = lib.mkOption {
      type = nullOr str;
      default = null;
      description = "Display name for identities like git and mail.";
    };
    email = lib.mkOption {
      type = nullOr str;
      default = null;
      description = "Address for identities like git and mail.";
    };
  };
in
{
  flake.modules = {
    generic.users-profile.options = { inherit profile; };

    homeManager.users-profile.imports = [ self.modules.generic.users-profile ];

    nixos.users-profile = { config, ... }: {
      home-manager.users = lib.genAttrs config.dotnix.members (username: {
        imports = with self.modules; [ generic."${username}" ];
        home.username = username;
      });
    };
  };
}
