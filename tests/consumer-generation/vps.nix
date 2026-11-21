{ dotnix, inputs, ... }:
let
  modules = import inputs.dotnix;
in
{
  imports = [ modules.system ];

  flake-file.outputs = "dendritic";
  flake-file.inputs = {
    dotnix = {
      url = "path:./library";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/2074cc672349f14240fb7ea90d509e0b643e9dd4";
  };

  den.hosts.x86_64-linux.vps.users.operator.classes = [ "user" ];

  den.aspects.operator = {
    includes = [ dotnix.account.users ];
    # RFC 8032 test vector, not a deployable account key.
    user.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINdamAGCsQq31Uv+08lkBzoO4XLz2qYjJa8CGmj3B1Ea vps-fixture"
    ];
  };

  den.aspects.vps = {
    includes = [ dotnix.host.server ];
    nixos = {
      boot.loader.grub = {
        enable = true;
        device = "nodev";
      };
      fileSystems."/" = {
        device = "/dev/vda1";
        fsType = "ext4";
      };
      system.stateVersion = "26.11";
    };
  };
}
