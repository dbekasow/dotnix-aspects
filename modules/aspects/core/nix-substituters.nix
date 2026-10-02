{
  flake.modules.nixos.nix = { lib, ... }: {
    # mkDefault so hosts can replace the caches (e.g. a VPS attaching its
    # own binary cache) instead of fighting the shared defaults.
    nix.settings = {
      substituters = lib.mkDefault [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = lib.mkDefault [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
