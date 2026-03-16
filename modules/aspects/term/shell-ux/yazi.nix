{
  flake.modules.homeManager.terminal = { pkgs, ... }: {
    programs.yazi = {
      enable = true;

      plugins = {
        inherit (pkgs.yaziPlugins)
          git
          glow
          jump-to-char
          no-status
          ouch
          rich-preview
          smart-enter
          smart-filter
          toggle-pane
          ;
      };

      settings = { };
    };
  };
}

