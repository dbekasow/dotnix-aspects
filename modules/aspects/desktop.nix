{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.desktop.imports = with nixos; [
      dms
      dms-greeter
      fonts
      gnome-services
      niri
      qt-theme
      xdg-portals
    ];

    homeManager.desktop.imports = with homeManager; [
      alacritty
      anki
      dms
      dms-plugins
      firefox
      ghostty
      niri
      onlyoffice
      thunderbird
    ];
  };
}
