{ inputs, ... }:
{
  dotnix.herdr.homeManager =
    { lib
    , popup-launcher
    , pkgs
    , ...
    }:
    let
      keys = {
        bluetui = "prefix+shift+b";
        bottom = "prefix+alt+b";
        lazydocker = "prefix+d";
        shell = "prefix+f";
        lazygit = "prefix+alt+g";
        k9s = "prefix+alt+k";
        aerc = "prefix+m";
        nix-graph = "prefix+alt+n";
        gh-dash = "prefix+alt+p";
        dua = "prefix+u";
        wifitui = "prefix+alt+w";
        yazi = "prefix+y";
        tv = "prefix+t";
        scratch = "prefix+shift+s";
      };
      commandBindings = map
        (launcher:
          let popup = lib.recursiveUpdate launcher { key = keys.${launcher.name}; };
          in {
            inherit (popup)
              key
              command
              width
              height
              ;
            type = "popup";
            description = popup.name;
          })
        popup-launcher;
    in
    {
      programs.herdr = {
        enable = true;
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
        # Opinionated defaults — same intent as the tmux aspect: fish is pinned
        # (users.defaultUserShell), the prefix matches tmux's C-Space. Theme and
        # scrollback keep herdr's defaults (catppuccin; 10 MB scrollback already
        # exceeds tmux's 20000-line historyLimit).
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
