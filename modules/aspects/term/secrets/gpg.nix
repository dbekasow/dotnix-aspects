{
  flake.modules.homeManager.gpg = {
    programs.gpg.enable = true;
    services.gpg-agent.enable = true;
    services.gpg-agent.enableSshSupport = true;
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".gnupg" ];
  };
}

