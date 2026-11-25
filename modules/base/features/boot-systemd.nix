{
  dotnix.host.boot-systemd.nixos = { lib, ... }: {
    boot.loader.systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = lib.mkDefault 3;
      consoleMode = "auto";
    };
  };
}
