{
  flake.modules.homeManager.herdr = { config, lib, osConfig ? null, pkgs, ... }:
    let
      # Hardware popups follow the host, which is absent in standalone Home
      # Manager; a missing or partial osConfig simply disables them.
      hostFlag = path: osConfig != null && lib.attrByPath path false osConfig;

      # Popup launcher mirroring the tmux aspect's prefix+o menu: same tools,
      # same size reasoning (dashboards and anything with a diff or a preview
      # pane need width, plain lists don't). Herdr binds commands directly, so
      # each tool takes its own prefix key; letters that herdr already uses
      # (g/n/p/k/w) shift onto alt.
      # bluetui/wifitui ship with NixOS system aspects, so gate on their service.
      popups = with config.programs; [
        { key = "prefix+shift+b"; name = "bluetui"; command = lib.getExe pkgs.bluetui; width = "60%"; height = "55%"; enable = hostFlag [ "hardware" "bluetooth" "enable" ]; }
        { key = "prefix+b"; name = "bottom"; command = lib.getExe pkgs.bottom; width = "95%"; height = "90%"; inherit (bottom) enable; }
        { key = "prefix+d"; name = "lazydocker"; command = lib.getExe pkgs.lazydocker; width = "90%"; height = "85%"; inherit (lazydocker) enable; }
        { key = "prefix+f"; name = "shell"; command = lib.getExe pkgs.fish; width = "80%"; height = "70%"; enable = true; }
        { key = "prefix+alt+g"; name = "lazygit"; command = lib.getExe pkgs.lazygit; width = "95%"; height = "90%"; inherit (lazygit) enable; }
        { key = "prefix+alt+k"; name = "k9s"; command = lib.getExe pkgs.k9s; width = "95%"; height = "90%"; inherit (k9s) enable; }
        { key = "prefix+m"; name = "aerc"; command = lib.getExe pkgs.aerc; width = "90%"; height = "85%"; inherit (aerc) enable; }
        { key = "prefix+alt+n"; name = "nix-graph"; command = lib.getExe pkgs.nix-graph; width = "90%"; height = "80%"; enable = true; }
        { key = "prefix+alt+p"; name = "gh-dash"; command = lib.getExe pkgs.gh-dash; width = "90%"; height = "80%"; inherit (gh-dash) enable; }
        { key = "prefix+u"; name = "dua"; command = "${lib.getExe pkgs.dua} i"; width = "75%"; height = "75%"; enable = true; }
        { key = "prefix+alt+w"; name = "wifitui"; command = lib.getExe pkgs.wifitui; width = "60%"; height = "55%"; enable = hostFlag [ "networking" "wireless" "iwd" "enable" ]; }
        { key = "prefix+y"; name = "yazi"; command = lib.getExe pkgs.yazi; width = "95%"; height = "90%"; inherit (yazi) enable; }
        { key = "prefix+t"; name = "tv"; command = lib.getExe pkgs.television; width = "70%"; height = "60%"; inherit (television) enable; }
        # Scratch terminal: the popup closes when the shell exits.
        { key = "prefix+shift+s"; name = "scratch"; command = lib.getExe pkgs.fish; width = "90%"; height = "85%"; enable = true; }
      ];

      commandBindings = map
        (p: {
          inherit (p) key command width height;
          type = "popup";
          description = p.name;
        })
        (lib.filter (p: p.enable) popups);
    in
    {
      programs.herdr = {
        enable = true;
        package = pkgs.llm-agents.herdr;
        # Opinionated defaults — same intent as the tmux aspect: fish is pinned
        # (users.defaultUserShell), the prefix matches tmux's C-Space. Theme and
        # scrollback keep herdr's defaults (catppuccin; 10 MB scrollback already
        # exceeds tmux's 20000-line historyLimit).
        settings = lib.mkDefault {
          terminal.default_shell = lib.getExe pkgs.fish;
          keys = {
            prefix = "ctrl+space";
            command = commandBindings;
          };
        };
      };
    };

  # Worktree checkouts are real working copies; the default root lives in
  # $HOME, which impermanence wipes at boot. Follows worktrees.directory's
  # default (~/.herdr/worktrees).
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".herdr/worktrees" ];
  };
}
