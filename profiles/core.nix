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
      host.locale
      host.nh
      host.nix
      host.nur
      host.security
      ssh
      host.stylix
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
    dotnix.home.stylix
  ];

}
