{
  flake.modules.nixos.boot-systemd = { lib, ... }: {
    boot.loader.systemd-boot = {
      enable = lib.mkDefault true;
      editor = false;
      configurationLimit = 10;
      consoleMode = "auto";
    };
  };
}
