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
      host.git
      host.locale
      host.nh
      host.nix
      host.nur
      host.security
      ssh
      stylix
      host.system-packages
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
