{
  # Notmuch identity (user.name / user.primary_email) is consumer-owned: set
  # `programs.notmuch.settings` in the consumer's own Home Manager module.
  dotnix.maildir.homeManager = {
    accounts.email.maildirBasePath = "mail";

    programs.msmtp.enable = true;

    # Sync is notmuch-driven: the preNew hook below runs mbsync before every
    # `notmuch new`, so an extra systemd timer would only duplicate the work.
    programs.mbsync.enable = true;

    programs.notmuch = {
      enable = true;

      new.tags = [
        "inbox"
        "new"
        "unread"
      ];
      search.excludeTags = [
        "deleted"
        "trash"
        "spam"
      ];

      hooks.preNew = "mbsync --all";
    };
  };

  # Impermanence contribution for maildir.
  dotnix.maildir.homePersistence = {
    home.persistence."/persist".directories = [ "mail" ];
  };
}
