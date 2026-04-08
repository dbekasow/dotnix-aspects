{ inputs, ... }: {
  flake.modules.nixos.dms-greeter = { lib, config, ... }: {
    imports = [ inputs.dms.nixosModules.greeter ];

    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = "niri";

      configHome = lib.mkDefault config.users.users.dns.home;

      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };
    };
  };
}
