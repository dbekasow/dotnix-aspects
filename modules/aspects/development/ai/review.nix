{
  flake.modules.homeManager.ai-review = { pkgs, ... }: {
    home.packages = with pkgs; [
      ast-grep
    ];
  };
}
