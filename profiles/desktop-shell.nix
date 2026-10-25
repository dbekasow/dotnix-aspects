# Shared graphical foundation; compositor support and greeter remain explicit.
{ dotnix, ... }: {
  dotnix.desktop-shell = {
    includes = with dotnix; [ fonts gnome-services thunar xdg-portals clipboard xdg ];
    homeManager = { lib, options, pkgs, ... }: {
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
