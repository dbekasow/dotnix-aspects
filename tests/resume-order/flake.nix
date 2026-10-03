{
  inputs = {
    dotnix.url = "path:../..";
    flake-parts.follows = "dotnix/flake-parts";
    nixpkgs.follows = "dotnix/nixpkgs";
  };

  outputs = { dotnix, nixpkgs, ... }: {
    checks.x86_64-linux.resume-order = import ./vm.nix {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      library = dotnix;
    };
  };
}
