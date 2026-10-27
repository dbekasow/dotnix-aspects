{ inputs, ... }: {
  flake-file.inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  dotnix.nix-index-database.homeManager = { ... }: {
    imports = [ inputs.nix-index-database.homeModules.default ];

    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;
  };

  # Impermanence contribution for nix-index-database.
  dotnix.nix-index-database.homePersistence = {
    home.persistence."/persist".directories = [
      # nix-index-database/comma
      ".cache/nix-index"
    ];
  };
}
