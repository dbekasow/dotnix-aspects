# GUI applications, separable from the graphical socket (graphical).
{ dotnix, ... }: {
  dotnix.home.desktop-apps.includes = with dotnix.home; [
    alacritty
    anki
    firefox
    ghostty
    handy
    onlyoffice
    thunderbird
  ];
}
