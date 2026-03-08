{
  perSystem = { config, pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      name = "dotnix";

      inputsFrom = [
        config.pre-commit.devShell
        config.treefmt.build.devShell
      ];

      packages = with pkgs; [
        # Development
        nil
        nixd

        # Management
        nh
        nvd
        nurl
        nix-tree
        nix-index
        nix-inspect
        nix-search-tv
        nix-search-cli
        nix-output-monitor

        # Misc
        git
        just
        direnv

        # Agenix
        rage
        config.agenix-rekey.package
      ];
    };
  };
}
