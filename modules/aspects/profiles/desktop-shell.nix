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

    homeManager.desktop-shell = { lib, options, pkgs, ... }: {
      imports = with homeManager; [
        clipboard
        niri
        xdg
      ];

      config = lib.mkMerge [
        (lib.optionalAttrs (options.services ? "gpg-agent") {
          services.gpg-agent.pinentry.package = lib.mkOverride 900 pkgs.pinentry-gnome3;
        })
        (lib.optionalAttrs (options.programs ? rbw) {
          programs.rbw.settings.pinentry = lib.mkOverride 900 pkgs.pinentry-gnome3;
        })
      ];
    };
  };
}
