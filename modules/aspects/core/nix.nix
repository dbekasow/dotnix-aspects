{ inputs, ... }: {
  flake.modules.nixos.core = { pkgs, ... }: {
    nix = {
      settings = {
        accept-flake-config = true;
        auto-optimise-store = true;
        builders-use-substitutes = true;

        experimental-features = [ "nix-command" "flakes" ];

        keep-outputs = true;
        keep-derivations = true;

        trusted-users = [ "root" "@wheel" ];
      };

      package = pkgs.nixVersions.latest;
      registry.nixpkgs.flake = inputs.nixpkgs;

      channel.enable = false;
      optimise.automatic = true;
    };

    nix.settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    nixpkgs.config.allowUnfree = true;
  };
}
