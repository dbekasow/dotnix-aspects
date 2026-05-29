{
  flake.modules.homeManager.maildir = { config, ... }: {
    accounts.email.maildirBasePath = "mail";

    programs.msmtp.enable = true;

    programs.mbsync.enable = true;
    services.mbsync.enable = true;
    services.mbsync.frequency = "*:0/15";

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

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ "mail" ];
  };
}
