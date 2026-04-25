{
  flake.modules.nixos.network-wifi = { pkgs, ... }: {
    networking = {
      networkmanager.wifi.backend = "iwd";
      wireless.iwd = {
        enable = true;
        settings = {
          General.AddressRandomization = "network";
          General.AddressRandomizationRange = "full";
          IPv6.Enabled = true;
          Settings.AutoConnect = true;
        };
      };
    };

    environment.systemPackages = [ pkgs.wifitui ];
  };
}
