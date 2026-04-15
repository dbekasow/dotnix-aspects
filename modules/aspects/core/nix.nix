{ inputs, ... }: {
  flake.modules.nixos.nix = { lib, pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    nix = {
      settings = {
        accept-flake-config = true;
        auto-optimise-store = true;
        builders-use-substitutes = true;

        experimental-features = [ "nix-command" "flakes" ];

        keep-outputs = lib.mkDefault false;
        keep-derivations = lib.mkDefault false;

        trusted-users = [ "root" "@wheel" ];
      };

      package = pkgs.nixVersions.latest;
      registry.nixpkgs.flake = inputs.nixpkgs;
      optimise.automatic = true;
      channel.enable = false;
    };

    # Remove legacy channel dirs
    system.activationScripts.removeNixChannels.text = ''
      rm -rf /root/.nix-defexpr/channels
      rm -rf /nix/var/nix/profiles/per-user/root/channels
    '';
  };
}
