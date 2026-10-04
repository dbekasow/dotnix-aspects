# GUI applications, separable from the graphical socket (desktop-shell).
{ dotnix, ... }: {
  dotnix.desktop-apps.includes = with dotnix; [
    alacritty
    anki
    firefox
    ghostty
    handy
    onlyoffice
    thunderbird
  ];
}
