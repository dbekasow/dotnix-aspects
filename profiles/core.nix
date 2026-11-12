{ dotnix, ... }: {
  dotnix.host.core.includes = with dotnix.host; [
    age
    age-rekey
    certificates
    fish
    git
    gnupg
    home-manager
    locale
    nh
    nix
    nur
    security
    ssh
    stylix
    system-packages
  ];

  dotnix.home.core.includes = with dotnix.home; [
    age
    age-rekey
    git
    git-alias
    gpg-agent
    ssh
    stylix
  ];
}
