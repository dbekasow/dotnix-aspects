{
  flake.modules.nixos.docker = { lib, ... }: {
    virtualisation.docker = {
      enable = true;
      enableNvidia = lib.mkDefault false;

      rootless.enable = true;
      rootless.setSocketVariable = true;

      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };
  };

  flake.modules.homeManager.docker = { pkgs, ... }: {
    programs.lazydocker.enable = true;
    programs.fish.shellAbbrs.lzd = "lazydocker";

    home.packages = [ pkgs.dive ];
  };
}
