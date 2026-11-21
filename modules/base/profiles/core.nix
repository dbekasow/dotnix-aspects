{ dotnix, ... }: {
  dotnix.host.core.includes = with dotnix.host; [
    certificates
    home-manager
    locale
    nix
    security
    ssh
    system-packages
  ];

  dotnix.home.core.includes = with dotnix.home; [
    ssh
    xdg
  ];
}
