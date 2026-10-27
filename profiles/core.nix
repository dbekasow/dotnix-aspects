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

  dotnix.home.core-home.includes = with dotnix; [
    home.age
    home.age-rekey
    git
    git-alias
    home.gpg-agent
    home.ssh
    home.stylix
  ];
}
