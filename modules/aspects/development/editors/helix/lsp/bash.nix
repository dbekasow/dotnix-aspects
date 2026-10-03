{ config, ... }:
let inherit (config.flake.factory.helix) withTypos; in
{
  flake.modules.homeManager.helix-lsp = { pkgs, lib, ... }: {
    programs.helix.extraPackages = with pkgs; [ bash-language-server shellcheck shfmt ];
    programs.helix.languages = {
      language-server.bash-language-server = {
        command = lib.getExe pkgs.bash-language-server;
        args = [ "start" ];
      };
      language = [{
        name = "bash";
        language-servers = withTypos [ "bash-language-server" ];
        formatter = {
          command = lib.getExe pkgs.shfmt;
          args = [ "-i" "2" ];
        };
        auto-format = true;
      }];
    };
  };
}
