# Composition: graphical socket plus applications — consumers pick
# granularity by importing desktop-shell alone.
{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.desktop.imports = with nixos; [ desktop-shell ];

    homeManager.desktop.imports = with homeManager; [
      desktop-shell
      desktop-apps
    ];
  };
}
