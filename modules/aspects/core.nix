{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.core.imports = with nixos; [
      age
      age-rekey
      age-rekey-generators
      certificates
      git
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

    homeManager.core.imports = with homeManager; [
      age
      age-rekey
      age-rekey-generators
      git
      git-alias
      git-credentials
      git-sync
      home-manager
      ssh
      stylix
      users-profile
    ];
  };
}
