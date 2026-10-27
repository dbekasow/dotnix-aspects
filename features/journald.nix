{
  # @log is a persistent subvolume — but journald's Storage=auto never
  # creates /var/log/journal on its own, so the journal silently stayed
  # volatile on the wiped @root and every boot log was lost at reboot
  # (the documented auto-trap, nixpkgs#9614). Storage=persistent makes
  # journald create the directory on @log; the cap then guards it.
  dotnix.host.journald.nixos = {
    services.journald.settings.Journal."Storage" = "persistent";
    services.journald.settings.Journal."SystemMaxUse" = "1G";
  };
}
