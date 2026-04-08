{
  flake.modules.nixos.qt-theme = { lib, ... }: {
    qt = {
      enable = true;
      platformTheme = lib.mkDefault "gnome";
      style = lib.mkDefault "adwaita-dark";
    };
  };
}
