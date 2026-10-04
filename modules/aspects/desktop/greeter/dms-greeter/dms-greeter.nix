{ inputs, ... }: {
  flake-file.inputs.dank-greeter = {
    url = "github:AvengeMedia/dank-greeter";
    inputs = {
      dank-qml-common.follows = "dms/dank-qml-common";
      nixpkgs.follows = "nixpkgs";
    };
  };
  dotnix.dms-greeter.nixos =
    { host
    , lib
    , config
    , pkgs
    , ...
    }:
    {
      imports = [ inputs.dank-greeter.nixosModules.default ];

      programs.dms-greeter = {
        enable = true;
        compositor.name = "niri";

        configHome =
          let
            users = builtins.attrNames host.users;
            primary =
              lib.throwIf (users == [ ])
                "dms-greeter needs a host user to borrow a home directory for greeter theming"
                (builtins.head users);
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

  # Impermanence contribution for dms-greeter.
  dotnix.dms-greeter.systemPersistence = {
    environment.persistence."/persist".directories = [ "/var/lib/dms-greeter" ];
  };
}
