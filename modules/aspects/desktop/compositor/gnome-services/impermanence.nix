# Impermanence contribution for gnome-services — collector pattern: the
# entry lives with the contributing feature, not in the impermanence collector.
# gnome-services itself is a nixos aspect, but dconf and the keyring live in
# the user's home, so the persistence entry is homeManager-side.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [
      ".config/dconf"
      ".local/share/keyrings"
    ];
  };
}
