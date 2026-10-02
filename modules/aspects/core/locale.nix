{
  flake.modules.nixos.locale = { lib, ... }: {
    time.timeZone = "Europe/Berlin";

    # No extraLocaleSettings: unset LC_* falls back to LANG anyway, so
    # mirroring defaultLocale per category is a no-op.
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

    console.keyMap = lib.mkDefault "de";
  };
}
