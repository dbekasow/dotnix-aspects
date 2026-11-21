{
  dotnix.home.rbw.homeManager = { config, lib, pkgs, ... }:
    let
      primary = lib.findFirst (account: account.primary) null (lib.attrValues config.accounts.email.accounts);
    in
    {
      programs.rbw = {
        enable = true;
        settings = {
          pinentry = lib.mkDefault pkgs.pinentry-curses;
          email = lib.mkIf (primary != null) (lib.mkDefault primary.address);
        };
      };
    };
}
