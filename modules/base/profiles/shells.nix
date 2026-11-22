# Configure both shells without choosing a login shell.
{ dotnix, ... }: {
  dotnix.home.shells.includes = with dotnix.home; [
    fish.provides.without-shell
    nushell.provides.without-shell
  ];
}
