{
  flake.modules.homeManager.gpg-agent = { lib, pkgs, ... }: {
    programs.gpg.enable = true;
    programs.gpg.scdaemonSettings.disable-ccid = true;
    services.gpg-agent = rec {
      enable = true;
      enableSshSupport = true;
      # Desktop default; headless hosts override to pinentry-curses.
      pinentry.package = lib.mkDefault pkgs.pinentry-gnome3;

      defaultCacheTtl = 7200; # 2h idle cache for normal keys
      maxCacheTtl = 28800; # 8h absolute cap

      defaultCacheTtlSsh = defaultCacheTtl;
      maxCacheTtlSsh = maxCacheTtl;
    };
  };
}
