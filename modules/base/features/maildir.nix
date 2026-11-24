{
  dotnix.home.maildir.homeManager = { config, lib, ... }:
    let
      primary = lib.findFirst (account: account.primary) null (lib.attrValues config.accounts.email.accounts);
    in
    {
      accounts.email.maildirBasePath = "mail";

      programs.msmtp.enable = true;

      # Sync is notmuch-driven: the preNew hook below runs mbsync before every
      # `notmuch new`, so an extra systemd timer would only duplicate the work.
      programs.mbsync.enable = true;

      programs.notmuch = {
        enable = true;

        settings = {
          user = lib.mkIf (primary != null) {
            name = lib.mkDefault primary.realName;
            primary_email = lib.mkDefault primary.address;
          };

          new.tags = [
            "inbox"
            "new"
            "unread"
          ];
          search.exclude_tags = [
            "deleted"
            "trash"
            "spam"
          ];
        };

        hooks.preNew = "mbsync --all";
      };
    };

  # Impermanence contribution for maildir.
  dotnix.home.maildir.homePersistence = {
    home.persistence."/persist".directories = [ "mail" ];
  };
}
