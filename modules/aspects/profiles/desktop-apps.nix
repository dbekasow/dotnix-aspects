# GUI applications, separable from the graphical socket (desktop-shell) so
# minimal desktops compose socket-only.
{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    homeManager.desktop-apps.imports = with homeManager; [
      alacritty
      anki
      firefox
      ghostty
      handy
      onlyoffice
      thunderbird
    ];
  };
}
