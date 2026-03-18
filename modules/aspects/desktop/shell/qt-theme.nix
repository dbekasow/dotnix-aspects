{
  flake.modules.nixos.desktop = { lib, ... }: {
    qt = {
      enable = true;
      platformTheme = lib.mkDefault "gnome";
      style = lib.mkDefault "adwaita-dark";
    };
  };
}
