# Native Den user aspect. The host provides it to the `myuser` user entity, so
# the includes and classes below land in that user's scope.
{ dotnix, lib, ... }: {
  dotnix.myuser = {
    includes = with dotnix; [
      account.users # create this explicitly selected OS account
      home.terminal # shells, tools, multiplexer
      home.development # editor, vcs, automation
      home.core # universal home baseline: age, age-rekey, ssh
      home.persistence # generic persistence baseline for this home
    ];

    user.extraGroups = [ "wheel" "networkmanager" ];

    homeManager = {
      home.stateVersion = "26.11";
      # Home identity and rekey resources are owned by this consumer home,
      # independently of host authentication.
      # Set age.identityPaths here when this home uses a local age identity.
      age.rekey = {
        secretsDir = ./secrets;
        generatedSecretsDir = ./secrets/generated;
        localStorageDir = ./secrets/local;
        hostPubkey = lib.optionalString
          (builtins.pathExists ./secrets/home-key.pub)
          (builtins.readFile ./secrets/home-key.pub);
        storageMode = "local";
        # Throwaway master pubkey so a fresh clone evaluates and demos
        # against a key nobody holds; replace before going live.
        extraEncryptionPubkeys = [ "age178wfu8598yp9vgcq3c5vwfmvtsqncypd0gkmal873yzl0y8zq5ls07q2cz" ];
      };
      # RBW (Bitwarden CLI) needs the account address as a native Home Manager
      # option; it is the user's own identity and stays out of the shared aspect.
      programs.rbw.settings.email = "user@example.com";
      programs.git.settings.user = {
        name = "Full Name";
        email = "user@example.com";
      };
    };
  };
}
