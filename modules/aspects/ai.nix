{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    nixos.ai.imports = [
      # Derzeit keine reinen NixOS-Module für Development
    ];

    homeManager.ai.imports = with homeManager; [
      aichat
      claude-code
    ];
  };
}
