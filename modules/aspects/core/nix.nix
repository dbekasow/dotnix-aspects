{ inputs, ... }: {
  flake.modules.nixos.nix = { pkgs, config, ... }: {
    imports = [ config.dotnix.host.modules ];

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

    nixpkgs.config.allowUnfree = true;
  };
}
