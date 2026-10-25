# Native Den user aspect. The host provides it to the `myuser` user entity, so
# the includes and classes below land in that user's scope.
{ dotnix, lib, ... }: {
  dotnix.myuser = {
    includes = with dotnix; [
      account.users # create this explicitly selected OS account
      terminal # shells, tools, multiplexer
      development # editor, vcs, automation
      core-home # user-scope Home Manager modules, including Stylix
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
        # Add consumer-owned master identities before running agenix-rekey.
        masterIdentities = [ ];
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
