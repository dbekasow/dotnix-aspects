{ config, ... }:
let inherit (config.flake.factory.helix) withTypos prettier; in
{
  flake.modules.homeManager.development = { pkgs, lib, ... }: {
    programs.helix.extraPackages = with pkgs; [ marksman markdown-oxide nodePackages.prettier ];
    programs.helix.languages = {
      language-server = {
        marksman = {
          command = lib.getExe pkgs.marksman;
          args = [ "server" ];
        };
        markdown-oxide.command = lib.getExe pkgs.markdown-oxide;
      };
      language = [{
        name = "markdown";
        language-servers = withTypos [ "marksman" "markdown-oxide" ];
        formatter = prettier pkgs "markdown";
        auto-format = false;
        soft-wrap.enable = true;
        soft-wrap.wrap-at-text-width = true;
      }];
    };
  };
}
