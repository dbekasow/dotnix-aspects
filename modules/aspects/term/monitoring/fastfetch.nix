{
  flake.modules.homeManager.fastfetch = { config, lib, ... }: {
    programs.fastfetch = {
      enable = true;

      settings = {
        logo.source = "nixos_small";
        modules = [
          "title"
          "separator"
          "os"
          "kernel"
          "packages"
          "shell"
          "terminal"
          "cpu"
          "memory"
          "disk"
        ];
      };
    };

    # Skip inside tmux: fish is the default pane shell and fastfetch costs
    # 50–200 ms on every pane split (the sesh autostart already guards itself).
    programs.fish.functions.fish_greeting = lib.mkIf config.programs.fish.enable {
      description = "Greeting with fastfetch";
      body = "if not set -q TMUX; fastfetch; end";
    };
  };
}

