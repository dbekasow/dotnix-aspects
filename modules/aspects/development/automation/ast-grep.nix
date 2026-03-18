{
  flake.modules.homeManager.development-grep = { pkgs, ... }: {
    home.packages = [ pkgs.ast-grep ];
  };
}

