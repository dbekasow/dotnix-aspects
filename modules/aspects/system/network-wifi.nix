{
  flake.modules.nixos.network-wifi = {
    networking = {
      networkmanager.wifi.backend = "iwd";
      wireless.iwd = {
        enable = true;
        settings = {
          IPv6.Enabled = true;
          Settings.AutoConnect = true;
        };
      };
    };
  };
}
