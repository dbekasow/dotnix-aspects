# Graphical foundation plus applications; consumers can select desktop-shell alone.
{ dotnix, ... }: {
  dotnix.host.desktop.includes = [ dotnix.host.desktop-shell ];
  dotnix.home.desktop.includes = [ dotnix.home.desktop-shell dotnix.home.desktop-apps ];
}
