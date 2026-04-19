{
  flake.modules.nixos.network = { pkgs, ... }: {
    networking = {
      networkmanager = {
        enable = true;
        dhcp = "internal";
        dns = "default";
        wifi.powersave = true;
        plugins = [ pkgs.networkmanager-openvpn ];
      };

      # Global fallback DNS
      nameservers = [ "1.1.1.1" "1.0.0.1" ];
      nftables.enable = true;

      useDHCP = false;
      dhcpcd.enable = false;

      firewall.enable = true;
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        domain = true;
        userServices = true;
      };
    };

    environment.systemPackages = with pkgs; [ curl dig ];
  };
}
