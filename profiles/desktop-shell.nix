# Shared graphical foundation; compositor support and greeter remain explicit.
{ dotnix, ... }: {
  dotnix.desktop-shell.includes = with dotnix; [ fonts gnome-services thunar xdg-portals clipboard xdg ];
}
