{ inputs, ... }:
let
  # Keep the agenix dependency closed over the library flake.
  libraryInputs = inputs;
in
{
  flake-file.inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  dotnix.host.age = {
    nixos.imports = [ libraryInputs.agenix.nixosModules.default ];

    # Impermanence contribution for the host's SSH identity.
    systemPersistence = {
      age.identityPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
  };

  dotnix.home.age = {
    homeManager.imports = [ libraryInputs.agenix.homeManagerModules.default ];
  };
}
