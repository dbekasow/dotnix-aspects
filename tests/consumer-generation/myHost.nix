{ dotnix, inputs, lib, ... }:
let
  system = "x86_64-linux";
  withDesktop = false;
  host.users.myuser.classes = [ "homeManager" ];

  hostAspect = selectDesktop: {
    includes = with dotnix.host; [ age age-rekey home-manager pipewire yubikey-pam ] ++ lib.optional selectDesktop niri;

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
      includes = with dotnix.home; [ core terminal development gpg-agent ]
        ++ lib.optionals selectDesktop [ graphical gpg-agent-gui rbw-gui ];
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
in
{
  imports = [ (inputs.dotnix + "/modules/base.nix") ]
    ++ lib.optional withDesktop (inputs.dotnix + "/modules/desktop.nix");

  flake-file.outputs = "dendritic";
  flake-file.inputs = {
    dotnix = {
      url = "path:./library";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/2074cc672349f14240fb7ea90d509e0b643e9dd4";
  };

  den.hosts.${system} = {
    myHost = host // {
      instantiate = args: inputs.nixpkgs.lib.nixosSystem (args // {
        pkgs = import inputs.nixpkgs { inherit system; };
      });
    };
  } // lib.optionalAttrs withDesktop { graphicalHost = host; };

  den.aspects = {
    myHost = hostAspect false;
  } // lib.optionalAttrs withDesktop { graphicalHost = hostAspect true; };
}
