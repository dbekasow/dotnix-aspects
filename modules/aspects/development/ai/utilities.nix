{
  flake.modules.homeManager.ai-utilities = { pkgs, ... }: {
    home.packages = with pkgs.llm-agents; [
      agent-browser
      mcporter
      rtk
      toon
    ];
  };
}
