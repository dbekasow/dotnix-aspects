{ dotnix, ... }: {
  dotnix.core = {
    includes = with dotnix; [
      age
      age-rekey
      certificates
      fish
      git
      gnupg
      host.home-manager
      locale
      nh
      nix
      nur
      security
      ssh
      stylix
      system-packages
      users
    ];
  };

  dotnix.core-home.includes = with dotnix; [
    age
    age-rekey
    git
    git-alias
    gpg-agent
    ssh
    stylix
  ];

}
