{
  dotnix.host.tailscale = {
    nixos = { config, lib, ... }: {
      services.tailscale = {
        enable = true;
        disableTaildrop = true;
        extraSetFlags = [ "--ssh=false" ];
        authKeyFile = lib.mkDefault (config.age.secrets.tailscale-auth-key.path or null);
      };
    };

    systemPersistence = {
      environment.persistence."/persist".directories = [ "/var/lib/tailscale" ];
      # Do not start against transient state if the persistent mount failed.
      systemd.services.tailscaled.unitConfig.RequiresMountsFor = "/var/lib/tailscale";
    };
  };
}
