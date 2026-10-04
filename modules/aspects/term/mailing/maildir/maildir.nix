{
  flake.modules.homeManager.maildir = { config, ... }: {
    accounts.email.maildirBasePath = "mail";

    programs.msmtp.enable = true;

    # Sync is notmuch-driven: the preNew hook below runs mbsync before every
    # `notmuch new`, so an extra systemd timer would only duplicate the work.
    programs.mbsync.enable = true;

    programs.notmuch = {
      enable = true;

      new.tags = [ "inbox" "new" "unread" ];
      search.excludeTags = [ "deleted" "trash" "spam" ];

      hooks.preNew = "mbsync --all";

      extraConfig = {
        user.name = config.profile.fullname;
        user.primary_email = config.profile.email;
      };
    };
  };

  # Impermanence contribution for maildir.
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ "mail" ];
  };
}
