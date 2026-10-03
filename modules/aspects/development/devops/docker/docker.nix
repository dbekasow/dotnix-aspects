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
      # required for rootless docker user namespace mapping
      subUidRanges = [{ startUid = 100000; count = 65536; }];
      subGidRanges = [{ startGid = 100000; count = 65536; }];
      linger = true;
    });
  };

  flake.modules.homeManager.docker = { pkgs, ... }: {
    programs.lazydocker.enable = true;
    programs.fish.shellAbbrs.lzd = "lazydocker";

    home.packages = [ pkgs.dive ];
  };
}
