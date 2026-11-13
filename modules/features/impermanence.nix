{ den, inputs, ... }: {
  dotnix.classes = {
    homePersistence.description = "Home Manager persistence contributed by selected features";
    systemPersistence.description = "NixOS persistence contributed by selected features";
  };

  den.policies = {
    home-persistence-to-homeManager =
      { user ? null
      , ...
      }:
      if user != null then
        [
          (den.lib.policy.route {
            fromClass = "homePersistence";
            intoClass = "homeManager";
            path = [ ];
          })
        ]
      else
        [ ];
    system-persistence-to-nixos =
      { user ? null
      , host
      , ...
      }:
      if user == null then
        [
          (den.lib.policy.route {
            fromClass = "systemPersistence";
            intoClass = host.class;
            path = [ ];
          })
        ]
      else
        [ ];
  };

  flake-file.inputs.impermanence = {
    url = "github:nix-community/impermanence";
    inputs = {
      home-manager.follows = "home-manager";
      nixpkgs.follows = "nixpkgs";
    };
  };
  dotnix.host.persistence = {
    includes = [
      den.policies.home-persistence-to-homeManager
      den.policies.system-persistence-to-nixos
    ];

    nixos = { ... }: {
      imports = [ inputs.impermanence.nixosModules.impermanence ];

      environment.persistence."/persist" = {
        hideMounts = true;
        files = [ "/etc/machine-id" ];
        directories = [
          # Post-mortem debugging across reboots; upstream example path.
          "/var/lib/systemd/coredump"
        ];
      };
    };
  };
  dotnix.home.persistence.homeManager = {
    home.persistence."/persist".hideMounts = true;
  };
}
