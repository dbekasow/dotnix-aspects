{
  # The Bitwarden account address defaults to the consumer's primary
  # `accounts.email` account; an explicit `programs.rbw.settings.email` still
  # wins, and relying on the default without a primary account fails
  # evaluation.
  dotnix.home.rbw.homeManager = { config, lib, pkgs, ... }:
    let
      primaryAccount = lib.head (lib.attrValues (lib.filterAttrs (_: account: account.primary) config.accounts.email.accounts));
    in
    {
      programs.rbw = {
        enable = true;

        settings = {
          email = lib.mkDefault primaryAccount.address;
          pinentry = lib.mkDefault pkgs.pinentry-curses;
        };
      };
    };
}
