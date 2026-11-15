{ inputs, lib, ... }:
{
  perSystem = { pkgs, system, ... }:
    let
      source = inputs.self;
      securityInputs = {
        inherit (source.inputs) den flake-parts nixpkgs;
        dotnix = source;
        self = securityFixture;
      };
      # The standalone flake's perSystem output expects its own self.inputs.
      securityFixture = (import ../../tests/headless-security/flake.nix).outputs securityInputs // {
        inputs = builtins.removeAttrs securityInputs [ "self" ];
      };
      # Force behavioral assertions even when the marker derivation is cached.
      evaluated = name: value:
        builtins.deepSeq value (pkgs.runCommand name { } "touch $out");
    in
    {
      checks = lib.optionalAttrs (system == "x86_64-linux") {
        consumer-headless-composition = evaluated "consumer-headless-composition"
          (import ../../tests/headless-composition.nix { inherit source; });
        consumer-headless-security = securityFixture.checks.${system}.headless-security;
        consumer-niri-dms = evaluated "consumer-niri-dms"
          (import ../../tests/niri-dms.nix { inherit source; });
        consumer-review-access = evaluated "consumer-review-access"
          (import ../../tests/review-access.nix { inherit source; });
      };
    };
}
