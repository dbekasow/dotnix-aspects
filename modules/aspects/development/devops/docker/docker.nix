{
  flake.modules.nixos.docker = { config, lib, ... }: {
    virtualisation.docker = {
      enable = true;

      rootless.enable = true;
      rootless.setSocketVariable = true;

      # Prunes the rootful daemon, which this aspect leaves enabled: dead
      # weight on rootless hosts, but the live daemon on WSL hosts where
      # the wsl aspect forces rootless off — so keep it.
      autoPrune.enable = true;
    };

    users.users = lib.genAttrs config.dotnix.members (lib.const {
      # Rootless docker needs subordinate ids. Auto-allocation (via
      # update-users-groups.pl) hands every member a distinct 65536-wide
      # range; explicit ranges here would collide across members.
      autoSubUidGidRange = lib.mkDefault true;
      linger = true;
    });
  };

  flake.modules.homeManager.docker = { pkgs, ... }: {
    programs.lazydocker.enable = true;
    programs.fish.shellAbbrs.lzd = "lazydocker";

    home.packages = [ pkgs.dive ];
  };

  # Impermanence contribution for docker.
  flake.modules.homeManager.impermanence = {
    # Rootless docker keeps images and containers in the user's home;
    # /var/lib/docker would only persist a rootful daemon no member talks
    # to (WSL hosts run rootful but have no wipe to begin with).
    home.persistence."/persist".directories = [ ".local/share/docker" ];
  };
}
