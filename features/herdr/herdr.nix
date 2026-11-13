{ inputs, ... }:
{
  dotnix.home.herdr.homeManager =
    { config
    , lib
    , popup-launcher
    , pkgs
    , ...
    }:
    let
      commandBindings = lib.concatMap
        (launcher:
          let
            key = lib.attrByPath [ "keys" "herdr" ] null launcher;
          in
          if key == null then
            builtins.trace
              "dotnix.home.herdr: omitting popup launcher '${launcher.name}' because it has no `keys.herdr` binding; add one to its record in features/popup-launchers.nix."
              [ ]
          else
            let popup = lib.recursiveUpdate launcher { inherit key; }; in
            [
              {
                inherit (popup)
                  key
                  command
                  width
                  height
                  ;
                type = "popup";
                description = popup.name;
              }
            ])
        popup-launcher;
    in
    {
      programs.herdr = {
        enable = true;
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
        # Herdr persists runtime state (e.g. the onboarding flag) into
        # config.toml, which fails with EROFS on the default immutable store
        # link. Merge declared settings into a writable file instead; declared
        # values still win over state written by Herdr.
        mutableSettings = lib.mkDefault true;
        # Opinionated defaults — fish is pinned independently of account login
        # shell, and the prefix matches tmux's C-Space. Theme and scrollback keep
        # herdr's defaults (catppuccin; 10 MB scrollback already exceeds tmux's
        # 20000-line historyLimit).
        settings = {
          terminal.default_shell = lib.mkDefault (lib.getExe pkgs.fish);
          keys = {
            # Session
            prefix = "ctrl+space";
            goto = "prefix+s";
            settings = "prefix+shfit+s";

            # Workspaces
            previous_workspace = "prefix+(";
            next_workspace = "prefix+)";
            open_worktree = "prefix+shift+o";
            remove_worktree = "prefix+shift+i";

            # Tabs
            switch_tab = [ "prefix+1..9" "alt+1..9" ];
            move_tab_previous = "prefix+<";
            move_tab_next = "prefix+>";
            rename_tab = "prefix+comma";

            # Panes
            last_pane = "prefix+semicolon";
            split_vertical = "prefix+|";
            split_horizontal = "prefix+-";

            # Popup launchers (features/popup-launchers.nix).
            command = commandBindings;
          };
        };
      };

      # Autostart on the same seam as sesh/tmux: every interactive fish
      # outside a multiplexer attaches to herdr's default session. tmux and
      # sesh win when a consumer composes them alongside herdr.
      programs.fish.interactiveShellInit =
        lib.mkIf (!config.programs.tmux.enable && !config.programs.sesh.enable) ''
          if not set -q HERDR_ENV
            ${lib.getExe config.programs.herdr.package}
          end
        '';
    };

  # Worktree checkouts are real working copies; the default root lives in
  # $HOME, which impermanence wipes at boot. Follows worktrees.directory's
  # default (~/.herdr/worktrees).
  dotnix.home.herdr.homePersistence = {
    home.persistence."/persist".directories = [
      # herdr's own runtime state: the plugin registry, plugin config
      # dirs, named sessions, and config.toml state.
      ".config/herdr"
      ".herdr/worktrees"
    ];
  };
}
