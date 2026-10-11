{
  # The Bitwarden account address is consumer-owned: set
  # `programs.rbw.settings.email` in the consumer's own Home Manager module.
  dotnix.rbw.homeManager = { lib, pkgs, ... }: {
    programs.rbw = {
      enable = true;

      settings.pinentry = lib.mkDefault pkgs.pinentry-curses;
    };
  };
}

