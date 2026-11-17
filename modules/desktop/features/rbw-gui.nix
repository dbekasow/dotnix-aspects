{ dotnix, ... }:
{
  dotnix.home.rbw-gui = {
    includes = [ dotnix.home.rbw ];
    homeManager = { lib, pkgs, ... }: {
      programs.rbw.settings.pinentry = lib.mkOverride 900 pkgs.pinentry-gnome3;
    };
  };
}
