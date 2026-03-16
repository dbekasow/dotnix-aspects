{
  flake.modules.homeManager.terminal = { pkgs, ... }: {
    programs.bat = {
      enable = true;

      extraPackages = with pkgs.bat-extras; [
        batman
        batgrep
        prettybat
      ];
    };
  };
}

