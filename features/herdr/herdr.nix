{ inputs, ... }:
{
  dotnix.home.herdr.homeManager =
    { config
    , lib
    , osConfig ? null
    , popup-launcher
    , pkgs
    , ...
    }:
    let
      # `enable` gates are closures from features/popup-launchers.nix; they
      # must run here, where `config` is the user's home-manager config.
      # herdr 0.9.5 has no key sequences, so the menu is one popup bound to
      # prefix+o: it lists the enabled launchers, reads one keypress, and
      # execs the tool in place. All tools share the popup geometry; the
      # per-tool upgrade path is documented in
      # docs/plans/herdr-menu-plugin-research.md.
      launchers = lib.sortOn (l: lib.toLower l.key + l.key) (
        lib.concatMap
          (launcher:
            if !(launcher ? key) then
              builtins.trace
                "dotnix.home.herdr: omitting popup launcher '${launcher.name}' because it has no `key`; add one to its record in features/popup-launchers.nix."
                [ ]
            else if !(launcher.enable { inherit config osConfig; }) then
              [ ]
            else
              [ launcher ])
          popup-launcher
      );
      dispatchKeys = map (l: l.key) launchers;
      # One line of sh via herdr's /bin/sh -c: the case arms dispatch the
      # keypress case-sensitively; any other key (including Escape) exits.
      menuScript = lib.concatStringsSep "; " (
        (map (l: "echo '${l.key}  ${l.name}'") launchers)
        ++ [ "read -rsn1 k" ]
        ++ [ "case $k in ${lib.concatStringsSep " " (map (l: "${l.key}) exec ${l.command} ;;") launchers)} *) exit 0 ;; esac" ]
      );
    in
    {
      assertions = [{
        assertion = dispatchKeys == lib.unique dispatchKeys;
        message = "dotnix.home.herdr: duplicate popup menu dispatch keys: ${lib.concatStringsSep " " dispatchKeys}";
      }];

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
          ui.host_cursor = "native";
          terminal.default_shell = lib.getExe pkgs.fish;
          keys = {
            # Session
            prefix = "ctrl+space";
            goto = "prefix+s";
            settings = "prefix+shift+s";

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

            # Tool menu (features/popup-launchers.nix): prefix+o opens the
            # popup, one keypress execs the launcher in place.
            command = [
              {
                key = "prefix+o";
                command = menuScript;
                width = "90%";
                height = "85%";
                type = "popup";
                description = "popups";
              }
            ];
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
