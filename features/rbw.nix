{ dotnix, ... }:
{
  # The Bitwarden account address is consumer-owned: set
  # `programs.rbw.settings.email` in the consumer's own Home Manager module.
  dotnix.home.rbw.homeManager = { lib, pkgs, ... }: {
    programs.rbw = {
      enable = true;

      settings.pinentry = lib.mkDefault pkgs.pinentry-curses;
    };
  };

  # Optional GUI integration, owned by the rbw feature.
  dotnix.home.rbw-gui = {
    includes = [ dotnix.home.rbw ];
    homeManager = { lib, pkgs, ... }: {
      programs.rbw.settings.pinentry = lib.mkOverride 900 pkgs.pinentry-gnome3;
    };
  };
}
