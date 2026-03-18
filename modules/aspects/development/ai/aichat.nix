{
  flake.modules.homeManager.development = {
    programs.aichat = {
      enable = true;

      agents = { };
      settings = { };
    };
  };
}
