{ inputs, ... }: {
  flake.modules.nixos.dms-greeter = { lib, config, ... }: {
    imports = [ inputs.dms.nixosModules.greeter ];

    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = "niri";

      configHome =
        let
          primaryUser = lib.head config.dotnix.host.members;
          primaryHome = config.users.users."${primaryUser}".home;
        in
        lib.mkDefault primaryHome;

      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };
    };
  };
}
