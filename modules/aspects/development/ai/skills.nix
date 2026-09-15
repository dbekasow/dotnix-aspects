{
  flake.modules.homeManager.ai-tools = { pkgs, ... }: {
    home.packages = with pkgs.llm-agents; [
      beads # distributed issue tracker
      beads-viewer # tui for beads issue tracker
      skills # skill tool installer
      tokscale # token analytics
    ];
  };
}
