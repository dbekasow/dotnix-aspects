{ inputs, ... }: {
  flake.modules.homeManager.nix-index-database = { ... }: {
    imports = [ inputs.nix-index-database.homeModules.default ];

    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [
      # nix-index-database/comma
      ".cache/nix-index"
    ];
  };
}

