{ inputs, ... }:
{
  dotnix.herdr.homeManager =
    { lib
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
              "dotnix.herdr: omitting popup launcher '${launcher.name}' because it has no `keys.herdr` binding; add one to its record in features/popup-launchers.nix."
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
        # Opinionated defaults — fish is pinned independently of account login
        # shell, and the prefix matches tmux's C-Space. Theme and scrollback keep
        # herdr's defaults (catppuccin; 10 MB scrollback already exceeds tmux's
        # 20000-line historyLimit).
        settings = {
          terminal.default_shell = lib.mkDefault (lib.getExe pkgs.fish);
          keys.prefix = lib.mkDefault "ctrl+space";
          keys.command = lib.mkDefault commandBindings;
        };
      };
    };

  # Worktree checkouts are real working copies; the default root lives in
  # $HOME, which impermanence wipes at boot. Follows worktrees.directory's
  # default (~/.herdr/worktrees).
  dotnix.herdr.homePersistence = {
    home.persistence."/persist".directories = [ ".herdr/worktrees" ];
  };
}
