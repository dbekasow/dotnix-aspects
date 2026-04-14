{
  flake.modules.homeManager.ai-management = { pkgs, ... }: {
    home.packages = with pkgs.llm-agents; [
      backlog-md
      beads
      beads-viewer
      openskills
      openspec
    ];
  };
}
