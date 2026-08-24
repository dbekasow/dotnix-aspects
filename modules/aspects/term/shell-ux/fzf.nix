{
  flake.modules.homeManager.fzf = {
    programs.fzf = {
      enable = true;

      defaultCommand = "fd --type f";
      defaultOptions = [ "--height 50%" "--layout reverse" ];

      changeDirWidget.command = "fd --type d";
      changeDirWidget.options = [
        "--preview 'eza --tree --icons --color=always --level 3 --git-ignore {}'"
        "--pointer ' '"
      ];

      fileWidget.command = "fd --type f";
      fileWidget.options = [
        "--preview 'bat --color=always {}'"
        "--pointer ' '"
      ];

      historyWidget.command = ""; # Ctrl-R for Atuin
    };
  };
}

