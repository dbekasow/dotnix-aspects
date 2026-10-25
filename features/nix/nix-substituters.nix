{
  dotnix.host.nix-community-cache.nixos = { lib, ... }: {
    # mkDefault so hosts can replace the extra caches (e.g. a VPS attaching its
    # own binary cache) instead of fighting the shared defaults.
    nix.settings = {
      extra-substituters = lib.mkDefault [ "https://nix-community.cachix.org" ];
      extra-trusted-public-keys = lib.mkDefault [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
