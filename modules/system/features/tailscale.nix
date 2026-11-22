{
  dotnix.host.tailscale = {
    nixos.services.tailscale = {
      enable = true;
      disableTaildrop = true;
      extraSetFlags = [ "--ssh=false" ];
    };

    systemPersistence = {
      environment.persistence."/persist".directories = [
        {
          directory = "/var/lib/tailscale";
          mode = "0700";
        }
      ];
      # Do not start against transient state if the persistent mount failed.
      systemd.services.tailscaled.unitConfig.RequiresMountsFor = "/var/lib/tailscale";
    };
  };
}
