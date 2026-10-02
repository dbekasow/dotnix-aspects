# Graphical socket: compositor, session, portals and file UI — everything a
# GUI needs before applications. The shell (dms | noctalia) and the greeter
# (dms-greeter | noctalia-greeter) are per-host choices, not socket parts:
# import exactly one of each next to this tier.
{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.desktop-shell.imports = with nixos; [
      fonts
      gnome-services
      niri
      thunar
      xdg-portals
    ];

    homeManager.desktop-shell.imports = with homeManager; [
      niri
      xdg
    ];
  };
}
