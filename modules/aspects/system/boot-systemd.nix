{
  flake.modules.nixos.boot-systemd = { lib, ... }: {
    boot.loader.systemd-boot = {
      enable = lib.mkDefault true;
      editor = false;
      configurationLimit = lib.mkDefault 3;
      consoleMode = "auto";
    };
  };
}
