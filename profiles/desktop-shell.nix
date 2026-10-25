# Shared graphical foundation; compositor support and greeter remain explicit.
{ dotnix, ... }: {
  dotnix.host.desktop-shell.includes = with dotnix; [ fonts host.gnome-services thunar xdg-portals ];
  dotnix.home.desktop-shell.includes = with dotnix; [ home.gnome-services clipboard xdg ];
}
