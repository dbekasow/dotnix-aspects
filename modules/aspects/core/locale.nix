{
  flake.modules.nixos.locale = { config, lib, ... }: {
    time = {
      timeZone = "Europe/Berlin";
      hardwareClockInLocalTime = lib.mkDefault true;
    };

    i18n = {
      defaultLocale = lib.mkDefault "en_US.UTF-8";
      extraLocaleSettings = {
        LC_MESSAGES = config.i18n.defaultLocale;
        LC_TIME = config.i18n.defaultLocale;
        LC_ADDRESS = config.i18n.defaultLocale;
        LC_IDENTIFICATION = config.i18n.defaultLocale;
        LC_MEASUREMENT = config.i18n.defaultLocale;
        LC_MONETARY = config.i18n.defaultLocale;
        LC_NAME = config.i18n.defaultLocale;
        LC_NUMERIC = config.i18n.defaultLocale;
        LC_PAPER = config.i18n.defaultLocale;
        LC_TELEPHONE = config.i18n.defaultLocale;
      };
    };

    console.keyMap = lib.mkDefault "de";

    # NTP time sync
    services.timesyncd.enable = lib.mkDefault true;
  };
}
