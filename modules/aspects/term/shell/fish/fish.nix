let
  mkPlugins = map (it: {
    inherit (it) src;
    name = it.pname;
  });
in
{

  dotnix.fish.nixos = {
    programs.fish.enable = true;
    programs.fish.useBabelfish = true;
  };

  dotnix.fish.homeManager = { pkgs, ... }: {
    home.shell.enableFishIntegration = true;

    programs.fish = {
      enable = true;

      plugins =
        with pkgs.fishPlugins;
        mkPlugins [
          autopair
          fish-you-should-use
        ];
    };
  };

  # Impermanence contribution for fish.
  dotnix.fish.homePersistence = {
    home.persistence."/persist".directories = [ ".local/share/fish" ];
  };
}
