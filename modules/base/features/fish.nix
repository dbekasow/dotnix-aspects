{ dotnix, ... }:
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

  dotnix.account.fish.user = { lib, pkgs, ... }: {
    shell = lib.mkDefault pkgs.fish;
  };

  dotnix.home.fish.includes = [ dotnix.account.fish dotnix.home.fish.provides.without-shell ];

  dotnix.home.fish.provides.without-shell.homeManager = { lib, pkgs, ... }: {
    home.shell.enableFishIntegration = lib.mkDefault true;

    programs.fish = {
      enable = lib.mkDefault true;
      # Empty fish_greeting disables the "Welcome to fish" banner.
      interactiveShellInit = "set -g fish_greeting";

      plugins =
        with pkgs.fishPlugins;
        mkPlugins [
          autopair
          fish-you-should-use
        ];
    };
  };

  dotnix.home.fish.provides.without-shell.homePersistence = {
    home.persistence."/persist".directories = [ ".local/share/fish" ];
  };
}
