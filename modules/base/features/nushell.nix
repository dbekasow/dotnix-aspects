{ dotnix, ... }: {
  dotnix.host.nushell.nixos = { lib, ... }: {
    programs.nushell.enable = lib.mkDefault true;
  };

  dotnix.account.nushell.user = { lib, pkgs, ... }: {
    shell = lib.mkDefault pkgs.nushell;
  };

  dotnix.home.nushell.includes = [ dotnix.account.nushell dotnix.home.nushell.provides.without-shell ];

  dotnix.home.nushell.provides.without-shell.homeManager = { lib, ... }: {
    programs.nushell.enable = lib.mkDefault true;
  };
}
