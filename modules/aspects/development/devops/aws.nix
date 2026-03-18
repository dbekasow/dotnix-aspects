{
  flake.modules.homeManager.devops = {
    programs.awscli = {
      enable = true;

      credentials = { };
      settings = { };
    };
  };
}

