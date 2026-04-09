let
  mkPlugins = map (it: { inherit (it) src; name = it.pname; });
in
{
  flake.modules.homeManager.fish = { pkgs, ... }: {
    home.shell.enableFishIntegration = true;

    programs.fish = {
      enable = true;

      plugins = with pkgs.fishPlugins; mkPlugins [
        autopair
        fish-you-should-use
        fzf
      ];
    };
  };
}

