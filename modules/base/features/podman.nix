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
    homeManager.services.podman.enable = true;

    homePersistence.home.persistence."/persist".directories = [ ".local/share/containers/storage" ];
  };
}
