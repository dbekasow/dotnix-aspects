{
  # The daemonless CLI does not need the API sockets from the NixOS Podman module.
  dotnix.host.podman.nixos.virtualisation.containers.enable = true;

  dotnix.account.podman.user = { lib, ... }: {
    autoSubUidGidRange = lib.mkDefault true;
  };

  dotnix.home.podman = {
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.podman ];
    };

    homePersistence.home.persistence."/persist".directories = [ ".local/share/containers/storage" ];
  };
}
