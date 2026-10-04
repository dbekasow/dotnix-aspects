{
  flake.modules.homeManager.herdr = { lib, pkgs, ... }: {
    programs.herdr = {
      enable = true;
      package = pkgs.llm-agents.herdr;
      settings = {
        terminal.default_shell = lib.getExe pkgs.fish;
        keys = {
          prefix = "ctrl+space";
        };
      };
    };
  };
}
