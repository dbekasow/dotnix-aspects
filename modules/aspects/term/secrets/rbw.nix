{
  flake.modules.homeManager.rbw = { config, pkgs, ... }: {
    programs.rbw = {
      enable = true;

      settings = {
        inherit (config.profile) email;
        pinentry = pkgs.pinentry-gnome3;
      };
    };
  };
}

