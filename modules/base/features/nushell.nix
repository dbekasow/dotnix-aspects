{
  dotnix.host.nushell.nixos = { lib, ... }: {
    programs.nushell.enable = lib.mkDefault true;
  };

  dotnix.home.nushell.homeManager = { lib, ... }: {
    programs.nushell.enable = lib.mkDefault true;
  };
}
