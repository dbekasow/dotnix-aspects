{
  flake.modules.homeManager.helix = { lib, ... }: {
    programs.helix = {
      enable = true;
      defaultEditor = lib.mkDefault true;

      ignores = [
        "!.editorconfig"
        "!.helix/"
        "!.github/"
        "!.gitattributes"
        "!.gitignore"
        "!.gitmodules"
        "!.justfile"
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
        popup-border = "popup";
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
          normal = "underline";
          select = "underline";
        };

        # LSP
        lsp.display-inlay-hints = true;

        # Diagnostics - new feature
        # inline-diagnostics / end-of-line-diagnostics: helix consolidates
        # diagnostics keys upstream into editor.diagnostics.* — re-check
        # on the next helix bump; a key renamed upstream is silently ignored.
        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "disable";
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
        indent-guides.character = "⸽";

        # Soft Wrap
        soft-wrap.enable = false;

        # Auto-Save
        auto-save = {
          focus-lost = true;
          after-delay.enable = true;
        };

        # Workspace trust
        workspace-trust.trusted = [
          "~/.dotnix/*"
          "~/.dotnix-aspects/*"
        ];
      };
    };
  };

  # Impermanence contribution for helix.
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [
      ".cache/helix"
    ];
  };
}
