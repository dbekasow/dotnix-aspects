{
  # Weather/gammastep auto-location drives geoclue, and geoclue triggers
  # NetworkManager scan cycles — the off-channel ping spikes seen on WLAN.
  # Pin the weather location instead, or leave this aspect unimported.
  flake.modules.nixos.geolocation = {
    location.provider = "geoclue2";

    services.geoclue2 = {
      enable = true;

      geoProviderUrl = "https://beacondb.net/v1/geolocate";

      submissionUrl = "https://beacondb.net/v2/geosubmit";
      submissionNick = "geoclue";

      appConfig.gammastep = {
        isAllowed = true;
        isSystem = false;
      };
    };
  };
}
