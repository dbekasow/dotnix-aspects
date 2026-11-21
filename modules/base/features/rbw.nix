{
  dotnix.home.rbw.homeManager = { lib, pkgs, ... }: {
    programs.rbw = {
      enable = true;
      settings.pinentry = lib.mkDefault pkgs.pinentry-curses;
    };
  };
}
