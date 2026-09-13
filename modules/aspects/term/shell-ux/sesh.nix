{
  flake.modules.homeManager.sesh = { config, lib, pkgs, ... }: {
    programs.sesh = {
      enable = true;

      enableAlias = true; # home.shellAliases.s = sesh connect $(sesh list | fzf)
      enableTmuxIntegration = true;
      tmuxKey = "s"; # replaces tmux's default choose-tree
      icons = true;

      settings = {
        default_session = {
          startup_command = "eza --tree --icons --level 2";
          preview_command = "eza --tree --icons --color=always --level 2 {}";
        };

        # Every repo declared via dotnix.git.repositories becomes a named
        # session, so sesh lists them before they have ever been opened.
        session = lib.mapAttrsToList
          (dest: _: {
            name = baseNameOf dest;
            path = "${config.home.homeDirectory}/${dest}";
          })
          config.dotnix.git.repositories;
      };
    };

    programs.fish.interactiveShellInit = ''
      if not set -q TMUX
        ${lib.getExe pkgs.sesh} connect (pwd)
      end
    '';

    # programs.sesh asserts on this — its tmux binding calls `fzf --tmux`.
    programs.fzf.tmux.enableShellIntegration = true;
  };

  # The module binds the picker but not the jump-back.
  flake.modules.homeManager.tmux = { lib, pkgs, ... }: {
    programs.tmux.extraConfig = ''
      bind -N "Last session" S run-shell "${lib.getExe pkgs.sesh} last"
    '';
  };
}
