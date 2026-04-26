{
  flake.modules.nixos.docker = { config, lib, ... }: {
    virtualisation.docker = {
      enable = true;
      enableNvidia = false;

      rootless.enable = true;
      rootless.setSocketVariable = true;

      storageDriver = "overlay2";

      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };

    users.users = lib.genAttrs config.dotnix.host.members (lib.const {
      # required for rootless docker user namespace mapping
      subUidRanges = [{ startUid = 100000; count = 65536; }];
      subGidRanges = [{ startGid = 100000; count = 65536; }];
    });
  };

  flake.modules.homeManager.docker = { pkgs, ... }: {
    programs.lazydocker.enable = true;
    programs.fish.shellAbbrs.lzd = "lazydocker";

    home.packages = [ pkgs.dive ];
  };
}
