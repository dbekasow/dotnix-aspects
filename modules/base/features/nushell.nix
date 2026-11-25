{ dotnix, ... }: {
  dotnix.host.nushell.nixos = {
    programs.nushell.enable = true;
  };

  dotnix.account.nushell.user = { lib, pkgs, ... }: {
    shell = lib.mkDefault pkgs.nushell;
  };

  dotnix.home.nushell.includes = [ dotnix.account.nushell dotnix.home.nushell.provides.without-shell ];

  dotnix.home.nushell.provides.without-shell.homeManager = {
    programs.nushell.enable = true;
  };
}
