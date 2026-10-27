{
  dotnix.nix-search-tv.homeManager = {
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

  # Impermanence contribution for nix-search-tv.
  # Persist the downloaded indexes (tool default: $XDG_CACHE_HOME/nix-search-tv).
  dotnix.nix-search-tv.homePersistence = {
    home.persistence."/persist".directories = [ ".cache/nix-search-tv" ];
  };
}
