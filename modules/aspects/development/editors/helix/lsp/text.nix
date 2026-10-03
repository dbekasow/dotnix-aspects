{
  flake.factory.helix = {
    withTypos = servers: servers ++ [ "typos-lsp" ];

    prettier = pkgs: lang: {
      command = pkgs.lib.getExe pkgs.prettier;
      args = [ "--parser" lang ];
    };
  };

  flake.modules.homeManager.helix-lsp = { pkgs, ... }: {
    programs.helix.extraPackages = with pkgs; [ typos-lsp prettier ];
    programs.helix.languages.language-server = {
      typos-lsp.command = pkgs.lib.getExe pkgs.typos-lsp;
    };
  };
}
