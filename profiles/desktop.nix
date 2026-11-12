# Graphical foundation plus applications; consumers can select graphical alone.
{ dotnix, ... }: {
  dotnix.host.desktop.includes = [ dotnix.host.graphical ];
  dotnix.home.desktop.includes = [ dotnix.home.graphical dotnix.home.desktop-apps ];
}
