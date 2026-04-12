{
  flake.modules.homeManager.opencode = { lib, pkgs, config, ... }: {
    programs.opencode = {
      package = pkgs.llm-agents.opencode;
      enable = lib.mkDefault true;
      enableMcpIntegration = true;
      rules = "";
      settings = { };
    };

    home.packages = lib.mkIf config.programs.opencode.enable (
      with pkgs.llm-agents; [
        ccusage-opencode
        oh-my-opencode
      ]
    );
  };
}
