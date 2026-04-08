{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.bootstrap.imports = with nixos; [
      age
      age-rekey
      age-rekey-generators
      certificates
      home-manager
      locale
      nh
      nix
      security
      ssh
      stylix
      system-packages
      users
      users-profile
    ];

    homeManager.bootstrap.imports = with homeManager; [
      age
      age-rekey
      age-rekey-generators
      git
      git-alias
      git-credentials
      git-sync
      home-manager
      ssh
      users-profile
    ];
  };
}
