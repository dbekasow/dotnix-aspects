{
  flake.modules.homeManager.helix-lsp = { pkgs, lib, ... }: {
    programs.helix.extraPackages = with pkgs; [ nixd nil nixpkgs-fmt statix deadnix ];
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
        nil = {
          command = lib.getExe pkgs.nil;
        };
      };
      language = [{
        name = "nix";
        language-servers = [ "nixd" "nil" ];
        formatter.command = "nixpkgs-fmt";
        auto-format = true;
      }];
    };
  };
}
