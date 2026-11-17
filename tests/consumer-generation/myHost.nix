{ dotnix, inputs, ... }:
let
  system = "x86_64-linux";
in
{
  imports = [ (inputs.dotnix + "/modules/base.nix") ];

  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
  '';
  flake-file.inputs = {
    dotnix = {
      url = "path:./library";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/2074cc672349f14240fb7ea90d509e0b643e9dd4";
  };

  den.hosts.${system}.myHost = {
    users.myuser.classes = [ "homeManager" ];
    instantiate = args: inputs.nixpkgs.lib.nixosSystem (args // {
      pkgs = import inputs.nixpkgs { inherit system; };
    });
  };

  den.aspects.myHost = {
    includes = with dotnix.host; [ age age-rekey home-manager ];

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
      includes = with dotnix.home; [ core terminal development gpg-agent ];
      homeManager = {
        home.username = "myuser";
        home.homeDirectory = "/home/myuser";
        home.stateVersion = "26.11";
        accounts.email.accounts.fixture = {
          primary = true;
          address = "fixture@example.com";
          realName = "Consumer Fixture";
        };
      };
    };
  };
}
