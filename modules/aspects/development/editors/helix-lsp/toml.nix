{ config, ... }:
let inherit (config.flake.factory.helix) withTypos; in
{
  flake.modules.homeManager.development = { pkgs, lib, ... }: {
    programs.helix.extraPackages = [ pkgs.taplo ];
    programs.helix.languages = {
      language-server.taplo = {
        command = lib.getExe pkgs.taplo;
        args = [ "lsp" "stdio" ];
      };
      language = [{
        name = "toml";
        language-servers = withTypos [ "taplo" ];
        formatter = {
          command = lib.getExe pkgs.taplo;
          args = [ "fmt" "-" ];
        };
        auto-format = true;
      }];
    };
  };
}
