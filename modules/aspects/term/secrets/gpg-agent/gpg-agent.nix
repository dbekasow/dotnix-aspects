{
  flake.modules.homeManager.gpg-agent = { lib, pkgs, ... }: {
    programs.gpg.enable = true;
    programs.gpg.scdaemonSettings.disable-ccid = true;
    services.gpg-agent = rec {
      enable = true;
      enableSshSupport = true;
      pinentry.package = lib.mkDefault pkgs.pinentry-curses;

      defaultCacheTtl = 7200; # 2h idle cache for normal keys
      maxCacheTtl = 28800; # 8h absolute cap

      defaultCacheTtlSsh = defaultCacheTtl;
      maxCacheTtlSsh = maxCacheTtl;
    };
  };

  # Impermanence contribution for gpg-agent.
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".gnupg" ];
  };
}
