{ inputs, ... }: {
  flake.modules.nixos.dms-greeter = { lib, config, pkgs, ... }: {
    imports = [ inputs.dms.nixosModules.greeter ];

    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = "niri";

      configHome =
        let
          primary = lib.head config.dotnix.host.members;
          inherit (config.users.users."${primary}") home;
        in
        lib.mkDefault home;

      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };

      quickshell.package = pkgs.quickshell;
    };
  };
}
