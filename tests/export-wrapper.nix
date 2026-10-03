let
  flake = builtins.getFlake (toString ../.);
  lib = flake.inputs.nixpkgs.lib;
  callerInputs = {
    self = "/caller";
    shared = "caller";
  };
  tree = {
    addPath = _: tree;
    withLib = _: tree;
    files = [ ./export-wrapper-module.nix ];
  };
  inputs = {
    self = "/library";
    shared = "library";
    libraryOnly = "library-fallback";
    import-tree = tree;
  };
  exposed = (import ../modules/expose.nix) {
    inherit inputs lib;
    config = { };
  };
  wrapped = builtins.head exposed.flake.flakeModules.default.imports;
  evaluated = lib.evalModules {
    specialArgs.inputs = callerInputs;
    modules = [
      wrapped
      { _module.args.extra = "module-argument"; }
    ];
  };
in
assert wrapped._file == ./export-wrapper-module.nix;
assert evaluated.config.test.extra == "module-argument";
assert evaluated.config.test.self == "/caller";
assert evaluated.config.test.shared == "caller";
assert evaluated.config.test.fallback == "library-fallback";
"export wrapper regression passed"
