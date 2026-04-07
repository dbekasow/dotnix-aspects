{
  flake.modules.homeManager.terminal = { pkgs, ... }: {
    programs.yazi = {
      enable = true;

      plugins = {
        inherit (pkgs.yaziPlugins)
          bookmarks
          git
          glow
          jump-to-char
          no-status
          ouch
          smart-enter
          smart-filter
          toggle-pane
          ;
      };

      settings = {
        plugin = {
          # git: show status badge on files
          prepend_fetchers = [
            { id = "git"; name = "*"; run = "git"; }
            { id = "git"; name = "/"; run = "git"; }
          ];

          prepend_previewers = [
            # glow: render markdown (before rich-preview catches text/*)
            { mime = "text/markdown"; run = "glow"; }
            # ouch: preview archive contents before extraction
            { mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd}"; run = "ouch"; }
          ];
        };
      };

      keymap.mgr.prepend_keymap = [
        # bookmarks: save / jump / delete
        { on = "m"; run = "plugin bookmarks save"; desc = "Bookmark save"; }
        { on = "'"; run = "plugin bookmarks jump"; desc = "Bookmark jump"; }
        { on = [ "b" "d" ]; run = "plugin bookmarks delete"; desc = "Bookmark delete"; }
        { on = [ "b" "D" ]; run = "plugin bookmarks delete_all"; desc = "Bookmark delete all"; }
        # smart-enter: open file or enter directory with one key
        { on = "l"; run = "plugin smart-enter"; desc = "Enter or open"; }
        # smart-filter: live filter, cursor follows match
        { on = "F"; run = "plugin smart-filter"; desc = "Smart filter"; }
        # jump-to-char: vi-style f-jump to filename character
        { on = "f"; run = "plugin jump-to-char"; desc = "Jump to char"; }
        # ouch: compress selected entries
        { on = "C"; run = "plugin ouch"; desc = "Compress with ouch"; }
        # toggle-pane: show/hide preview
        { on = "T"; run = "plugin toggle-pane min-preview"; desc = "Show or hide preview pane"; }
        # toggle-pane: maximize/restore preview
        { on = "<A-T>"; run = "plugin toggle-pane max-preview"; desc = "Maximize or restore preview pane"; }
      ];

      initLua = ''
        -- git: activate status decorations in file list
        require("git"):setup()

        -- no-status: remove the bottom status bar for a cleaner UI
        require("no-status"):setup()
      '';
    };
  };
}

