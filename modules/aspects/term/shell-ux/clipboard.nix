{
  flake.modules.homeManager.clipboard = { pkgs, ... }: {
    home.packages = with pkgs; [ clipboard-jh ];
  };
}
