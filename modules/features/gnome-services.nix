{
  dotnix.host.gnome-services.nixos = { pkgs, ... }: {
    services = {
      dbus = {
        implementation = "broker";
        packages = with pkgs; [
          gcr_4
          gnome-settings-daemon
          libsecret
        ];
      };

      gnome.gnome-keyring.enable = true;
      gvfs.enable = true;
    };

    security.pam.services.greetd.enableGnomeKeyring = true;
  };

  # Impermanence contribution for gnome-services.
  # GNOME services run on the host, but dconf and the keyring live in the
  # user's home, so the persistence entry is Home Manager-side.
  dotnix.home.gnome-services.homePersistence = {
    home.persistence."/persist".directories = [
      ".config/dconf"
      ".local/share/keyrings"
    ];
  };
}
