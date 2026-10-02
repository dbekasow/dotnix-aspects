# Graphical socket: compositor, session, portals and file UI — everything a
# GUI needs before applications.
{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.desktop-shell.imports = with nixos; [
      dms
      dms-greeter
      fonts
      gnome-services
      niri
      thunar
      xdg-portals
    ];

    homeManager.desktop-shell.imports = with homeManager; [
      dms
      dms-plugins
      niri
      xdg
    ];
  };
}
