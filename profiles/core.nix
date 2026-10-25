{ dotnix, ... }: {
  dotnix.core = {
    includes = with dotnix; [
      host.age
      host.age-rekey
      host.certificates
      host.fish
      host.git
      host.gnupg
      host.home-manager
      host.locale
      host.nh
      host.nix
      host.nur
      host.security
      host.ssh
      host.stylix
      host.system-packages
    ];
  };

  dotnix.core-home.includes = with dotnix; [
    home.age
    home.age-rekey
    git
    git-alias
    home.gpg-agent
    home.ssh
    home.stylix
  ];

}
