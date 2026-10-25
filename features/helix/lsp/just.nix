{ config, ... }:
let inherit (config.flake.factory.helix) withTypos; in
{
  dotnix.helix-lsp.homeManager = { pkgs, lib, ... }: {
    programs.helix.extraPackages = [ pkgs.just-lsp ];
    programs.helix.languages = {
      language-server.just-lsp.command = lib.getExe pkgs.just-lsp;
      language = [{
        name = "just";
        language-servers = withTypos [ "just-lsp" ];
        formatter = {
          command = lib.getExe pkgs.just;
          args = [ "--dump" ];
        };
        auto-format = true;
      }];
    };
  };
}
