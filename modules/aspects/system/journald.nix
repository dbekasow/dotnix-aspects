{
  # @log is a persistent subvolume, so the journal needs a size cap.
  flake.modules.nixos.journald = {
    services.journald.settings.Journal."SystemMaxUse" = "1G";
  };
}
