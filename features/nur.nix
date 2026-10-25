{ inputs, ... }: {
  flake-file.inputs.nur = {
    url = "github:nix-community/NUR";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  dotnix.nur.nixos = {
    imports = [ inputs.nur.modules.nixos.default ];
  };
}
