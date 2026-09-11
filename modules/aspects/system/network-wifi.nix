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

    # Without these two, iwlwifi falls back to world roaming: reduced TX
    # power and some 5 GHz channels (especially the wide 80/160 MHz ones)
    # become unavailable. Verify with `iw reg get` — should show DE, not
    # "country 00".
    hardware.enableRedistributableFirmware = true;
    hardware.wirelessRegulatoryDatabase = true;

    environment.systemPackages = with pkgs; [ wifitui iw ];
  };

  flake.modules.nixos.impermanence = {
    environment.persistence."/persist".directories = [ "/var/lib/iwd" ];
  };
}
