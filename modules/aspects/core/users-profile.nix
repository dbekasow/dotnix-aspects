{ lib, self, ... }:
let
  profile = with lib.types; {
    username = lib.mkOption {
      type = str;
      description = "Login name of the user this profile describes.";
    };
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
    sshAuthorizedKeys = lib.mkOption {
      type = listOf str;
      default = [ ];
      description = "Public SSH keys authorized for this user's login; the profile is the data holder.";
    };
    theme = lib.mkOption {
      type = str;
      default = "catppuccin-mocha";
      description = "Palette name; the default matches the stylix scheme.";
    };
  };
in
{
  flake.modules = {
    generic.users-profile.options = { inherit profile; };

    homeManager.users-profile.imports = [ self.modules.generic.users-profile ];

    nixos.users-profile = { config, ... }: {
      home-manager.users = lib.genAttrs config.dotnix.host.members (username: {
        imports = with self.modules; [ generic."${username}" ];
        home.username = username;
      });
    };
  };
}
