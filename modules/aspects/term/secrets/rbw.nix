{
  flake.modules.homeManager.rbw = { config, lib, pkgs, ... }: {
    programs.rbw = {
      enable = true;

      settings = {
        inherit (config.profile) email;
        # Desktop default; headless hosts override to pinentry-curses.
        # dbus/gcr for the gnome3 prompt come from the desktop-shell tier.
        pinentry = lib.mkDefault pkgs.pinentry-gnome3;
      };
    };
  };
}

