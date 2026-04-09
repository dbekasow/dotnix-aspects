{
  flake.modules.homeManager.git-credentials = { lib, pkgs, osConfig, ... }: {
    programs.git.settings.credential = {
      helper = "${lib.getExe pkgs.git-credential-manager}";

      credentialStore = lib.mkDefault (
        if osConfig ? wsl && osConfig.wsl.enable then "plaintext"
        else if pkgs.stdenv.isLinux then "secretservice"
        else "cache"
      );

      useHttpPath = true;
    };
  };
}
