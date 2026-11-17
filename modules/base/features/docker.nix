{
  dotnix.host.docker.nixos = _: {
    virtualisation.docker = {
      enable = true;

      rootless.enable = true;
      rootless.setSocketVariable = true;

      # Auto-pruning applies to the rootful daemon, which remains enabled
      # alongside the optional rootless Docker service.
      autoPrune.enable = true;
    };
  };

  dotnix.account.docker.user = { lib, ... }: {
    # Rootless Docker needs subordinate IDs and a lingering user service.
    # This does not grant Docker group membership or additional privileges.
    autoSubUidGidRange = lib.mkDefault true;
    linger = lib.mkDefault true;
  };

  dotnix.home.docker.homeManager = { pkgs, ... }: {
    programs.lazydocker.enable = true;
    programs.fish.shellAbbrs.lzd = "lazydocker";

    home.packages = [ pkgs.dive ];
  };

  # Rootless Docker stores images and containers in this account's home.
  # Select explicitly only when that state should survive persistence cleanup.
  dotnix.home.docker-persistence.homePersistence = {
    home.persistence."/persist".directories = [ ".local/share/docker" ];
  };
}
