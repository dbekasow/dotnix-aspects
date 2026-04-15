{ config, ... }:
let inherit (config.flake.factory.helix) withTypos prettier; in
{
  flake.modules.homeManager.helix-lsp = { pkgs, lib, ... }: {
    programs.helix.extraPackages = with pkgs; [ yaml-language-server ];
    programs.helix.languages = {
      language-server.yaml-language-server = {
        command = lib.getExe pkgs.yaml-language-server;
        args = [ "--stdio" ];
      };
      language = [{
        name = "yaml";
        language-servers = withTypos [ "yaml-language-server" ];
        formatter = prettier pkgs "yaml";
        auto-format = true;
      }];
    };
  };
}
