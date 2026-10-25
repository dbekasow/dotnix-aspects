# Graphical foundation plus applications; consumers can select desktop-shell alone.
{ dotnix, ... }: {
  dotnix.desktop = {
    includes = [ dotnix.desktop-shell dotnix.desktop-apps ];
  };
}
