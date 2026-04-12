{
  flake.modules.homeManager.claudecode = { lib, pkgs, config, ... }: {
    programs.claude-code = {
      package = pkgs.llm-agents.claude-code;

      enable = lib.mkDefault true;

      agents = { };
      commands = { };
      hooks = { };
      mcpServers = { };
      skills = { };
      settings = { };
    };

    home.packages = lib.mkIf config.programs.claude-code.enable (
      with pkgs.llm-agents; [
        claude-plugins
        ccstatusline
        ccusage
        skills-installer
      ]
    );
  };
}
