{
  flake.modules.nixos.gnupg = { pkgs, ... }: {
    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;
  };

  flake.modules.homeManager.gpg-agent = { pkgs, ... }: {
    programs.gpg.enable = true;
    programs.gpg.scdaemonSettings.disable-ccid = true;
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-gnome3;
    };
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".gnupg" ];
  };
}

