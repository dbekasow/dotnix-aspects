{ config, ... }:
let inherit (config.flake.factory.helix) withTypos; in
{
  dotnix.helix-lsp.homeManager = { pkgs, lib, ... }: {
    programs.helix.extraPackages = [ pkgs.fish-lsp ];
    programs.helix.languages = {
      language-server.fish-lsp = {
        command = lib.getExe pkgs.fish-lsp;
        args = [ "start" ];
      };
      language = [{
        name = "fish";
        language-servers = withTypos [ "fish-lsp" ];
        auto-format = true;
      }];
    };
  };
}
