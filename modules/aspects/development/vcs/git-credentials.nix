{
  flake.modules.homeManager.development = { lib, pkgs, ... }: {
    home.packages = [ pkgs.git-credential-manager ];

    programs.git.settings.credential = {
      helper = "manager";

      credentialStore = lib.mkDefault (
        if pkgs.stdenv.isLinux then "secretservice"
        else "cache"
      );

      azreposCredentialType = "oauth";
    };
  };
}
