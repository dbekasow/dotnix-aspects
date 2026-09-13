{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    homeManager.terminal.imports = with homeManager; [
      # Shells & Prompts
      bash
      fish
      nushell
      starship

      # UX & Multiplexer
      atuin
      carapace
      clipboard
      direnv
      fzf
      sesh
      skim
      tuicr
      tmux
      workmux
      yazi
      zellij
      zoxide

      # Modern Coreutils (Files/Data)
      bat
      dua
      dust
      eza
      fd
      fx
      jq
      mdcat
      ouch
      ripgrep
      ripgrep-all
      sd
      xh

      # Monitoring
      bandwhich
      bottom
      fastfetch
      hyperfine
      procs
      rustscan
      tealdeer
      television
      tokei

      # Nix & Secrets
      nix-index-database
      nix-tools
      rbw

      # Mail
      aerc
      maildir
    ];
  };
}
