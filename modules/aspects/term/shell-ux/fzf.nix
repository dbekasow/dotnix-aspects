{
  flake.modules.homeManager.fzf = {
    programs.fzf = {
      enable = true;

      defaultCommand = "fd --type f";
      defaultOptions = [ "--height 50%" "--layout reverse" ];

      changeDirWidgetCommand = "fd --type d";
      changeDirWidgetOptions = [
        "--preview 'eza --tree --icons --color=always --level 3 --git-ignore {}'"
        "--pointer ' '"
      ];

      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [
        "--preview 'bat --color=always {}'"
        "--pointer ' '"
      ];

      historyWidgetOptions = [ "--pointer ' '" ];
    };
  };
}

