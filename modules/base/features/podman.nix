{
  dotnix.host.podman.nixos = { lib, ... }: {
    virtualisation.podman.enable = true;

    # NixOS otherwise starts both API sockets; the local CLI needs neither.
    systemd.sockets.podman.enable = lib.mkDefault false;
    systemd.user.sockets.podman.enable = lib.mkDefault false;
  };

  dotnix.account.podman.user = { lib, ... }: {
    autoSubUidGidRange = lib.mkDefault true;
  };

  dotnix.home.podman = {
    homeManager = { config, lib, ... }: {
      services.podman = {
        enable = true;
        # Home Manager's timer also prunes images, so require explicit opt-in.
        autoUpdate.enable = lib.mkDefault false;
      };

      systemd.user.services.podman-image-prune = {
        Unit.Description = "Prune dangling rootless Podman images";
        Service = {
          Type = "oneshot";
          ExecStart = "${lib.getExe config.services.podman.package} image prune -f";
        };
      };
      systemd.user.timers.podman-image-prune = {
        Unit.Description = "Prune dangling rootless Podman images weekly";
        Timer = {
          OnCalendar = "weekly";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };

    homePersistence.home.persistence."/persist".directories = [ ".local/share/containers/storage" ];
  };
}
