{
  flake.factory.helix = {
    withTypos = servers: servers ++ [ "typos-lsp" ];

    prettier = pkgs: lang: {
      command = pkgs.lib.getExe pkgs.nodePackages.prettier;
      args = [ "--parser" lang ];
    };
  };

  flake.modules.homeManager.development = { pkgs, ... }: {
    programs.helix.extraPackages = [ pkgs.typos-lsp ];
    programs.helix.languages.language-server = {
      typos-lsp.command = pkgs.lib.getExe pkgs.typos-lsp;
    };
  };
}
