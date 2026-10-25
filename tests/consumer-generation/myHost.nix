{ inputs, ... }:
let
  system = "x86_64-linux";
  dotnix = inputs.dotnix.denful.dotnix;
in
{
  den.hosts.${system}.myHost = {
    users.myuser.classes = [ "homeManager" ];
    instantiate = args: inputs.nixpkgs.lib.nixosSystem (args // {
      pkgs = import inputs.nixpkgs { inherit system; };
    });
  };

  den.aspects.myHost = {
    includes = [ dotnix.host.home-manager ];

    nixos = {
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "nodev";
      fileSystems."/" = {
        device = "/dev/vda1";
        fsType = "ext4";
      };
      nixpkgs.hostPlatform = system;
      system.stateVersion = "26.11";
    };

    provides.myuser = {
      includes = [ dotnix.direnv ];
      homeManager = {
        home.username = "myuser";
        home.homeDirectory = "/home/myuser";
        home.stateVersion = "26.11";
      };
    };
  };
}
