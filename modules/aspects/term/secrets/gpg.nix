{
  flake.modules.nixos.gnupg = { pkgs, ... }: {
    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;
  };

  flake.modules.homeManager.gpg-agent = { pkgs, ... }: {
    programs.gpg.enable = true;
    programs.gpg.scdaemonSettings.disable-ccid = true;
    services.gpg-agent = rec {
      enable = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-gnome3;

      defaultCacheTtl = 7200; # 2h idle cache for normal keys
      maxCacheTtl = 28800; # 8h absolute cap

      defaultCacheTtlSsh = defaultCacheTtl;
      maxCacheTtlSsh = maxCacheTtl;
    };
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".gnupg" ];
  };
}

