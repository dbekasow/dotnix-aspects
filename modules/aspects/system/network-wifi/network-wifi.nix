{
  flake.modules.nixos.network-wifi = { pkgs, ... }: {
    networking = {
      networkmanager.wifi = {
        backend = "iwd";
        powersave = false;
        scanRandMacAddress = true;
        macAddress = "preserve";
      };

      wireless.iwd.enable = true;
      wireless.iwd.settings.General.Country = "DE";
    };

    boot.kernelParams = [
      "iwlwifi.power_save=0"
      "iwlwifi.uapsd_disable=1"
      "iwlmvm.power_scheme=1"
    ];

    # The firmware set also carries the wireless regulatory database
    # (wirelessRegulatoryDatabase defaults to enableRedistributableFirmware),
    # so Country=DE unlocks full TX power and the wide 5 GHz channels.
    # Without it, iwlwifi falls back to world roaming. Verify with
    # `iw reg get` — should show DE, not "country 00".
    hardware.enableRedistributableFirmware = true;

    environment.systemPackages = with pkgs; [ wifitui iw ];
  };
}
