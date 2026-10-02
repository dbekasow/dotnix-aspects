{
  flake.modules.homeManager.nix-search-tv = {
    programs.nix-search-tv = {
      enable = true;

      # Surfaced as a television channel instead of a standalone binary run;
      # the HM module wires programs.television.channels.nix-search-tv.
      enableTelevisionIntegration = true;

      settings = {
        indexes = [
          "nixpkgs"
          "nixos"
          "home-manager"
          "noogle"
        ];
      };
    };
  };
}
