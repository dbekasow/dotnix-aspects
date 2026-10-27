{ dotnix, ... }:
{
  dotnix.home.gpg-agent = {
    homeManager = { lib, pkgs, ... }: {
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
    homePersistence = {
      home.persistence."/persist".directories = [ ".gnupg" ];
    };
  };

  # Optional GUI integration, owned by the gpg-agent feature.
  dotnix.home.gpg-agent-gui = {
    includes = [ dotnix.home.gpg-agent ];
    homeManager = { lib, pkgs, ... }: {
      services.gpg-agent.pinentry.package = lib.mkOverride 900 pkgs.pinentry-gnome3;
    };
  };
}
