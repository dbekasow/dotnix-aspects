{
  inputs = {
    dotnix.url = "path:../../";
    flake-parts.follows = "dotnix/flake-parts";
    nixpkgs.follows = "dotnix/nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ inputs.dotnix.flakeModule ];

    flake.modules.nixos.alice = { users.users.alice.isNormalUser = true; };
    flake.modules.nixos.bob = { users.users.bob.isNormalUser = true; };

    dotnix.hosts = {
      alpha = {
        members = [ "alice" ];
        modules = [
          { users.users.alice.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAATEST alice" ]; }
        ];
      };
      beta.members = [ "bob" ];
      empty.modules = [ ];
    };

    flake.checks.x86_64-linux.options-cleanup =
      let
        hosts = inputs.self.nixosConfigurations;
        alpha = hosts.alpha.config;
        beta = hosts.beta.config;
        empty = hosts.empty.config;
        profileOptions = builtins.attrNames
          (builtins.head (builtins.head inputs.dotnix.modules.generic.users-profile.imports).imports).options.profile;
      in
      assert alpha.dotnix.hostname == "alpha";
      assert alpha.dotnix.members == [ "alice" ];
      assert alpha.users.users.alice.openssh.authorizedKeys.keys == [ "ssh-ed25519 AAAATEST alice" ];
      assert beta.dotnix.hostname == "beta";
      assert beta.dotnix.members == [ "bob" ];
      assert empty.dotnix.hostname == "empty";
      assert empty.dotnix.members == [ ];
      assert alpha.networking.hostName == "alpha";
      assert alpha.dotnix.vaultReady == false;
      assert hosts.alpha.options.dotnix.vaultReady.readOnly;
      assert !(hosts.alpha.options.dotnix ? host);
      assert profileOptions == [ "email" "fullname" ];
      inputs.nixpkgs.legacyPackages.x86_64-linux.runCommand "options-cleanup" { } "touch $out";
  };
}
