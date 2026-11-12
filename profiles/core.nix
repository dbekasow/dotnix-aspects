{ dotnix, ... }: {
  dotnix.host.core.includes = with dotnix.host; [
    age
    certificates
    home-manager
    locale
    nix
    security
    ssh
    system-packages
  ];

  dotnix.home.core.includes = with dotnix.home; [
    age
    age-rekey
    ssh
  ];
}
