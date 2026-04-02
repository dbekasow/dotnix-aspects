{ inputs, ... }: {
  imports = [ inputs.devshell.flakeModule ];

  perSystem = { config, pkgs, ... }: {
    devshells.default = {
      name = "dotnix";

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
        direnv

        # Agenix
        rage
        config.agenix-rekey.package
      ];
    };
  };
}
