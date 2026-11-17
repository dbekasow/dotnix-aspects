{ inputs, ... }: {
  flake-file.inputs.dank-greeter = {
    url = "github:AvengeMedia/dank-greeter";
    inputs = {
      dank-qml-common.follows = "dms/dank-qml-common";
      nixpkgs.follows = "nixpkgs";
    };
  };
  dotnix.host.dms-greeter.nixos =
    { ... }:
    {
      imports = [ inputs.dank-greeter.nixosModules.default ];

      programs.dms-greeter = {
        enable = true;
        compositor.name = "niri";

        logs = {
          save = true;
          path = "/tmp/dms-greeter.log";
        };
      };
    };

  # Impermanence contribution for dms-greeter.
  dotnix.host.dms-greeter.systemPersistence = {
    environment.persistence."/persist".directories = [ "/var/lib/dms-greeter" ];
  };
}
