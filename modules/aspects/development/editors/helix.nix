{
  flake.modules.homeManager.helix = { lib, ... }: {
    programs.helix = {
      enable = true;
      defaultEditor = lib.mkDefault true;

      ignores = [
        "!.direnv/"
        "!.editorconfig"
        "!.helix/"
        "!.github/"
        "!.gitattributes"
        "!.gitignore"
        "!.gitmodules"
      ];

      settings.editor = {
        # Visual Navigation & UI
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        bufferline = "multiple";
        scrolloff = 8;

        # Editor Behavior
        text-width = 100;
        rulers = [ 100 ];
        completion-timeout = 150;
        idle-timeout = 200;
        trim-trailing-whitespace = true;

        # Visual Elements
        popup-border = "all";
        true-color = true;

        # Gutters - Git first
        gutters = [
          "diff"
          "diagnostics"
          "line-numbers"
          "spacer"
        ];

        # Cursor Shapes
        cursor-shape = {
          insert = "bar";
          select = "underline";
        };

        # LSP
        lsp.display-inlay-hints = true;

        # Diagnostics - new feature
        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "error";
        };
        end-of-line-diagnostics = "hint";

        # Statusline
        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "spacer"
            "file-name"
            "file-modification-indicator"
            "read-only-indicator"
          ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "total-line-numbers"
            "file-type"
          ];
        };

        # Indent Guides
        indent-guides.render = true;

        # Soft Wrap
        soft-wrap.enable = true;

        # Auto-Save
        auto-save = {
          focus-lost = true;
          after-delay.enable = true;
        };
      };
    };
  };
}
