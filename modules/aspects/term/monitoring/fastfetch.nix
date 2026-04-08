{
  flake.modules.homeManager.fastfetch = { config, lib, ... }: {
    programs.fastfetch = {
      enable = true;

      settings = {
        logo.type = "small";
        modules = [
          "title"
          "separator"
          "os"
          "kernel"
          "shell"
          "terminal"
          "cpu"
          "memory"
          "disk"
        ];
      };
    };

    programs.fish.functions.fish_greeting = lib.mkIf config.programs.fish.enable {
      description = "Greeting with fastfetch";
      body = "fastfetch";
    };
  };
}

