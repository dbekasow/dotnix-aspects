# Shared graphical foundation; compositor support and greeter remain explicit.
{ dotnix, ... }: {
  dotnix.host.graphical.includes = with dotnix.host; [ fonts gnome-services thunar xdg-portals ];
  dotnix.home.graphical.includes = with dotnix.home; [ gnome-services clipboard xdg ];
}
