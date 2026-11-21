# Shared graphical foundation; compositor support and greeter remain explicit.
{ dotnix, ... }: {
  dotnix.host.graphical.includes = with dotnix.host; [ fonts gnome-services stylix thunar xdg-portals ];
  dotnix.host.graphical.provides.to-users.includes = [ dotnix.home.graphical ];
  dotnix.home.graphical.includes = with dotnix.home; [ gnome-services clipboard stylix xdg ];
}
