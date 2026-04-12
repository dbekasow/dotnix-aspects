{
  flake.modules.homeManager.forgecode = { pkgs, ... }: {
    home.packages = with pkgs.llm-agents; [ forge ];
  };
}
