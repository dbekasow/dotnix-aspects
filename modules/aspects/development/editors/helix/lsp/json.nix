{ config, ... }:
let inherit (config.flake.factory.helix) withTypos prettier; in
{
  dotnix.helix-lsp.homeManager = { pkgs, ... }: {
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
