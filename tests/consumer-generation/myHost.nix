{ dotnix, inputs, lib, ... }:
let
  system = "x86_64-linux";
  withDesktop = false;
  modules = import inputs.dotnix;
  host.users.myuser.classes = [ "user" "homeManager" ];

  hostAspect = selectDesktop: {
    includes = with dotnix.host; [ home-manager pipewire ] ++ lib.optional selectDesktop niri;

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
      includes = with dotnix.home; [ dotnix.account.users core terminal development gpg-agent aerc ]
        ++ lib.optionals selectDesktop [ graphical gpg-agent-gui rbw-gui ];
      homeManager = {
        home.username = "myuser";
        home.homeDirectory = "/home/myuser";
        home.stateVersion = "26.11";
        accounts.email.accounts.fixture = {
          primary = true;
          address = "fixture@example.com";
          realName = "Consumer Fixture";
          userName = "fixture@example.com";
          imap.host = "imap.example.com";
          aerc.enable = true;
          # Stand-in for a consumer's existing credential helper; never run here.
          passwordCommand = "fixture-mail-password";
        };
        programs.aerc.extraConfig.general.unsafe-accounts-conf = true;
        programs.git.settings.user = {
          name = "Fixture Author";
          email = "author@example.com";
        };
        programs.rbw.settings.email = "bitwarden@example.com";
      };
    };
  };
in
{
  imports = [ modules.home ]
    ++ lib.optional withDesktop modules.desktop;

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
