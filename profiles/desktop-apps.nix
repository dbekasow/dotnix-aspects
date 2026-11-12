# GUI applications, separable from the graphical socket (graphical); office and
# browser suites live in their own domain bundles (office, browsers).
{ dotnix, ... }: {
  dotnix.home.desktop-apps.includes = with dotnix.home; [
    alacritty
    anki
    ghostty
    handy
  ];
}
