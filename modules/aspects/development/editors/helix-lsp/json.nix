{ config, ... }:
let inherit (config.flake.factory.helix) withTypos prettier; in
{
  flake.modules.homeManager.helix-lsp = { pkgs, ... }: {
    programs.helix.extraPackages = [ pkgs.nodePackages.prettier ];
    programs.helix.languages = {
      language-server = { };
      language = [{
        name = "json";
        language-servers = withTypos [ ];
        formatter = prettier pkgs "json";
        auto-format = true;
      }];
    };
  };
}
