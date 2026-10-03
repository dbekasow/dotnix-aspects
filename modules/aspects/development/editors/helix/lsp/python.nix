{ config, ... }:
let inherit (config.flake.factory.helix) withTypos; in
{
  flake.modules.homeManager.helix-lsp = { pkgs, lib, ... }: {
    # One LSP per language: basedpyright covers completion, refs, diagnostics.
    programs.helix.extraPackages = with pkgs; [ basedpyright ruff ];
    programs.helix.languages = {
      language-server = {
        basedpyright = {
          command = lib.getExe' pkgs.basedpyright "basedpyright-langserver";
          args = [ "--stdio" ];
        };
      };
      language = [{
        name = "python";
        language-servers = withTypos [ "basedpyright" ];
        formatter = {
          # Helix formatters read stdin and write stdout; --stdin-filename
          # keeps per-file ruff config (per-file-ignores etc.) resolvable.
          command = lib.getExe pkgs.ruff;
          args = [ "format" "--stdin-filename" "%{buffer_name}" "-" ];
        };
        auto-format = true;
      }];
    };
  };
}
