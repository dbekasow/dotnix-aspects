{
  flake.modules.homeManager.development = {
    programs.zed-editor = {
      enable = true;

      extensions = [ ];
      extraPackages = [ ];
    };
  };
}

