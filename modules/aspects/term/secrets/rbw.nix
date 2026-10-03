{
  flake.modules.homeManager.rbw = { config, lib, pkgs, ... }: {
    programs.rbw = {
      enable = true;

      settings = {
        inherit (config.profile) email;
        pinentry = lib.mkDefault pkgs.pinentry-curses;
      };
    };
  };
}

