{ config, ... }:
let inherit (config.flake.factory.helix) withTypos prettier; in
{
  flake.modules.homeManager.helix-lsp = { pkgs, lib, ... }: {
    # One LSP per language: markdown-oxide covers completion, refs, diagnostics.
    programs.helix.extraPackages = with pkgs; [ markdown-oxide ];
    programs.helix.languages = {
      language-server = {
        markdown-oxide.command = lib.getExe pkgs.markdown-oxide;
      };
      language = [{
        name = "markdown";
        language-servers = withTypos [ "markdown-oxide" ];
        formatter = prettier pkgs "markdown";
        auto-format = false;
        soft-wrap.enable = true;
        soft-wrap.wrap-at-text-width = true;
      }];
    };
  };
}
