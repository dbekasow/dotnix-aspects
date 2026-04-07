{
  flake.modules.nixos.core = { lib, pkgs, ... }: {
    services.openssh = {
      enable = lib.mkDefault true;

      settings = {
        PermitRootLogin = lib.mkDefault "prohibit-password";
        PasswordAuthentication = lib.mkDefault false;
      };
    };

    networking.firewall.allowedTCPPorts = [ 22 ];

    environment.systemPackages = [ pkgs.openssh ];
  };
}
