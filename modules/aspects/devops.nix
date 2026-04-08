{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.devops.imports = with nixos; [
      docker
    ];

    homeManager.devops.imports = with homeManager; [
      docker
      k9s
      kubernetes
    ];
  };
}
