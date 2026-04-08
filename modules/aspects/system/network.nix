{
  flake.modules.nixos.network = { pkgs, lib, ... }: {
    networking = {
      networkmanager = {
        enable = true;
        dns = "none";
        wifi.powersave = true;
        plugins = with pkgs; [
          networkmanager-openvpn
        ];
      };

      nameservers = [ "1.1.1.1" "1.0.0.1" ];
      nftables.enable = true;

      useDHCP = lib.mkDefault true;
      dhcpcd.enable = true;
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
