{
  dotnix.home.fastfetch.homeManager = _: {
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
  };
}

