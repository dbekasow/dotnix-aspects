# Graphical socket; shell and greeter remain explicit host choices.
{ dotnix, ... }: {
  dotnix.desktop-shell.includes = with dotnix; [ fonts gnome-services niri thunar xdg-portals clipboard xdg ];
}
