{ dotnix, ... }:
{
  dotnix.home.gpg-agent-gui = {
    includes = [ dotnix.home.gpg-agent ];
    homeManager = { lib, pkgs, ... }: {
      services.gpg-agent.pinentry.package = lib.mkOverride 900 pkgs.pinentry-gnome3;
    };
  };
}
