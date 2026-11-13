let
  mkPlugins = map (it: {
    inherit (it) src;
    name = it.pname;
  });
in
{
  dotnix.host.fish.nixos = { lib, ... }: {
    programs.fish.enable = lib.mkDefault true;
    programs.fish.useBabelfish = lib.mkDefault true;
  };

  dotnix.home.fish.homeManager = { lib, pkgs, ... }: {
    home.shell.enableFishIntegration = lib.mkDefault true;

    programs.fish = {
      enable = lib.mkDefault true;

      plugins =
        with pkgs.fishPlugins;
        mkPlugins [
          autopair
          fish-you-should-use
        ];
    };
  };

  dotnix.home.fish.homePersistence = {
    home.persistence."/persist".directories = [ ".local/share/fish" ];
  };

  dotnix.account.fish.user = { lib, pkgs, ... }: {
    shell = lib.mkDefault pkgs.fish;
  };
}
