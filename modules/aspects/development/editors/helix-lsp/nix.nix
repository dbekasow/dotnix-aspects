{
  flake.modules.homeManager.helix-lsp = { pkgs, lib, ... }: {
    # One LSP per language: nixd covers completion + options; nil, statix and
    # deadnix only duplicated server startup per buffer.
    programs.helix.extraPackages = with pkgs; [ nixd nixpkgs-fmt ];
    programs.helix.languages = {
      language-server = {
        nixd = {
          command = lib.getExe pkgs.nixd;
          config.nixd = {
            formatting.command = "nixpkgs-fmt";
            nixpkgs.expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }";
            options.flake-parts.expr = "(builtins.getFlake (toString ./.)).debug.options";
            options.flake-parts-perSystem.expr = "(builtins.getFlake (toString ./.)).currentSystem.options";
          };
        };
      };
      language = [{
        name = "nix";
        language-servers = [ "nixd" ];
        formatter.command = "nixpkgs-fmt";
        auto-format = true;
      }];
    };
  };
}
