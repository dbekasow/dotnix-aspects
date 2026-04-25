{
  flake.modules.nixos.gnome-services = { pkgs, ... }: {
    services = {
      dbus = {
        implementation = "broker";
        packages = with pkgs; [
          gcr
          gnome-settings-daemon
          libsecret
        ];
      };

      gnome.gnome-keyring.enable = true;
      gvfs.enable = true;
    };

    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
