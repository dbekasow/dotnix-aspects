{ inputs, ... }: {
  flake.modules.nixos.dms-greeter = { lib, config, pkgs, ... }: {
    imports = [ inputs.dank-greeter.nixosModules.default ];

    programs.dms-greeter = {
      enable = true;
      compositor.name = "niri";

      configHome =
        let
          members = config.dotnix.members;
          primary = lib.throwIf (members == [ ])
            "dms-greeter needs at least one dotnix.hosts.<name>.members entry to borrow a home directory for greeter theming"
            (lib.head members);
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
