{ config, ... }:
let inherit (config.flake.factory.helix) withTypos; in
{
  flake.modules.homeManager.development = { pkgs, lib, ... }: {
    programs.helix.extraPackages = [ pkgs.just-lsp ];
    programs.helix.languages = {
      language-server.just-lsp.command = lib.getExe pkgs.just-lsp;
      language = [{
        name = "just";
        language-servers = withTypos [ "just-lsp" ];
        formatter = {
          command = lib.getExe pkgs.just;
          args = [ "--fmt" "--unstable" "-f" "-" ];
        };
        auto-format = true;
      }];
    };
  };
}
