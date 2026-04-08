{
  flake.modules.nixos.docker = { lib, ... }: {
    virtualisation.docker = {
      enable = true;
      enableNvidia = lib.mkDefault false;

      rootless.enable = true;
      rootless.setSocketVariable = true;

      storageDriver = "overlay2";

      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };
  };

  flake.modules.homeManager.docker = { pkgs, ... }: {
    programs.lazydocker.enable = true;

    home.packages = with pkgs; [
      dive
    ];
  };
}
