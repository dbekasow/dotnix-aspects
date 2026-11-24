{ inputs, lib, ... }:
{
  flake-file.inputs.devshell = {
    url = "github:numtide/devshell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = lib.optionals (inputs ? devshell) [
    inputs.devshell.flakeModule
    {
      perSystem = { pkgs, ... }: {
        devshells.default = {
          name = "dotnix";

          motd = ''
            {147}dotnix{reset} - type {italic}just{reset} for commands
          '';

          packages = with pkgs; [
            # Development
            nil
            nixd

            # Management
            nh
            nvd
            nurl
            nix-graph
            nix-index
            nix-inspect
            nix-search-tv
            nix-search-cli
            nix-output-monitor

            # Misc
            git
            just
          ];
        };
      };
    }
  ];
}
