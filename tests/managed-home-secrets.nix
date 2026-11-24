{ source ? builtins.getFlake (toString ../.), missingRecipientOnly ? false }:
let
  fixtureRoot = ./managed-home-secrets;
  system = "x86_64-linux";
  inputs = source.inputs // { self = source // { outPath = toString fixtureRoot; }; };
  inherit (inputs.nixpkgs) lib;
  dotnix = source.denful.dotnix;

  evaluate = hostName: { bootstrap ? false, shared ? false, withVault ? true, hostPubkey ? null, homeSecretsDir ? null, hostSecretsDir ? null }:
    let
      accounts = [ "alice" ] ++ lib.optional shared "bob";
      flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } {
        imports = with (import source); [ home managedSecrets ];
        den.hosts.${system}.${hostName}.users = lib.genAttrs accounts (_: {
          classes = [ "user" "homeManager" ];
        });
        den.aspects.${hostName} = {
          includes = with dotnix.host; lib.optionals withVault [ age age-rekey ];
          nixos = {
            system.stateVersion = "26.11";
            boot.loader.grub.device = "nodev";
            fileSystems."/" = { device = "fixture"; fsType = "ext4"; };
          } // lib.optionalAttrs withVault {
            age.identityPaths = [ "/nonexistent/dotnix-test-host-identity" ];
            # Public example recipients only; this fixture never generates or decrypts.
            age.rekey = {
              hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1cJdcoW69R+NrWzwGK/+3gJpqD1t8L2zE";
              extraEncryptionPubkeys = [ "age178wfu8598yp9vgcq3c5vwfmvtsqncypd0gkmal873yzl0y8zq5ls07q2cz" ];
            } // lib.optionalAttrs (hostSecretsDir != null) {
              secretsDir = hostSecretsDir;
            };
          };
          provides = lib.genAttrs accounts (account: {
            includes = [ dotnix.account.users ] ++ lib.optionals (account == "alice") (
              if bootstrap then [ dotnix.home.managed-secrets-bootstrap ]
              else [ dotnix.home.managed-secrets ]
            );
            homeManager = { osConfig, ... }: {
              home.stateVersion = "26.11";
            } // lib.optionalAttrs (!bootstrap && account == "alice") {
              age.rekey = {
                extraEncryptionPubkeys = osConfig.age.rekey.extraEncryptionPubkeys;
              } // lib.optionalAttrs (hostPubkey != null) {
                inherit hostPubkey;
              } // lib.optionalAttrs (homeSecretsDir != null) {
                secretsDir = homeSecretsDir;
              };
            };
          });
        };
      };
    in
    flake.nixosConfigurations.${hostName}.config;

  first = evaluate "first" { shared = true; };
  second = evaluate "second" { };
  bootstrap = evaluate "unregistered" { bootstrap = true; };
  missing = evaluate "unregistered" { };
  missingVault = evaluate "unregistered" { bootstrap = true; withVault = false; };
  alice = config: config.home-manager.users.alice;
  hostIdentity = config: config.age.secrets.home-identity-alice;
  recipientFile = host: "${inputs.self.outPath}/modules/users/alice/secrets/hosts/${host}/home-key.pub";
  rekeyDir = host: "${inputs.self.outPath}/modules/hosts/${host}/secrets/homes/alice/local";
  recipient = host: builtins.readFile (recipientFile host);
  legacyRecipient = builtins.readFile "${inputs.self.outPath}/modules/hosts/unregistered/secrets/homes/alice/home-key.pub";
  overridden = evaluate "unregistered" { hostPubkey = legacyRecipient; };
  customHomeSecretsDir = "${fixtureRoot}/custom-home-secrets";
  customHostSecretsDir = "${fixtureRoot}/custom-host-secrets";
  relocated = evaluate "first" {
    homeSecretsDir = customHomeSecretsDir;
    hostSecretsDir = customHostSecretsDir;
  };
  missingMessage = "Managed home secrets for unregistered/alice are missing a recipient public key: ${recipientFile "unregistered"}";
in
if missingRecipientOnly then missing.system.build.toplevel.drvPath else
  assert builtins.attrNames first.age.secrets == [ "home-identity-alice" ];
  assert (first.home-manager.users.bob.age.identityPaths or [ ]) == [ ];
  assert (hostIdentity first).owner == "alice" && (hostIdentity first).mode == "600";
  assert (alice first).age.identityPaths == [ (hostIdentity first).path ];
  assert (alice second).age.identityPaths == [ (hostIdentity second).path ];
  assert (alice first).age.rekey.hostPubkey == recipient "first";
  assert (alice second).age.rekey.hostPubkey == recipient "second";
  assert (alice first).age.rekey.hostPubkey != (alice second).age.rekey.hostPubkey;
  assert (alice first).age.rekey.localStorageDir == rekeyDir "first";
  assert (alice second).age.rekey.localStorageDir == rekeyDir "second";
  assert (alice overridden).age.rekey.hostPubkey == legacyRecipient;
  assert builtins.all (a: a.assertion) overridden.assertions;
  assert (alice relocated).age.rekey.hostPubkey == recipient "second";
  assert (alice relocated).age.rekey.localStorageDir == "${customHostSecretsDir}/homes/alice/local";
  assert (hostIdentity first).rekeyFile != (hostIdentity second).rekeyFile;
  assert (hostIdentity bootstrap).generator.script == "ssh-ed25519";
  assert (alice bootstrap).home.activationPackage.drvPath != "";
  assert builtins.all (a: a.assertion) bootstrap.assertions;
  assert builtins.any (a: !a.assertion && a.message == "alice profile: ${missingMessage}") missing.assertions;
  assert !(missingVault ? age);
  assert builtins.any
    (a: !a.assertion && lib.hasPrefix
      "Managed home secrets for unregistered/alice require host.age and host.age-rekey"
      a.message)
    missingVault.assertions;
  "managed home secret recipient and bootstrap checks passed"
