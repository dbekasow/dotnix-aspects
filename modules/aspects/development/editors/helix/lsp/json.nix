{ config, ... }:
let inherit (config.flake.factory.helix) withTypos prettier; in
{
  flake.modules.homeManager.helix-lsp = { pkgs, ... }: {
    programs.helix.languages = {
      language = [{
        name = "json";
        language-servers = withTypos [ ];
        formatter = prettier pkgs "json";
        auto-format = true;
      }];
    };
  };
}
