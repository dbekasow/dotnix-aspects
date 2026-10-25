{ dotnix, ... }: {
  dotnix.core = {
    includes = with dotnix; [
      age
      age-rekey
      certificates
      host.fish
      git
      gnupg
      host.home-manager
      host.locale
      host.nh
      host.nix
      host.nur
      host.security
      ssh
      stylix
      host.system-packages
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
