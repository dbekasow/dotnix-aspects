{
  flake.modules.homeManager.utilities = { pkgs, ... }: {
    home.packages = with pkgs.llm-agents; [
      agent-browser
      mcporter
      rtk
      toon
    ];
  };
}
