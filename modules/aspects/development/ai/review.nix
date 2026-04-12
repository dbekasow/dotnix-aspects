{
  flake.modules.homeManager.review = { pkgs, ... }: {
    home.packages = with pkgs; [
      ast-grep
      llm-agents.tuicr
    ];
  };
}
