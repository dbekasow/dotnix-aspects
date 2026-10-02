{ inputs, lib, ... }:
let
  dotnixInputs = inputs;

  wrapMods = files: map
    (file:
      let mod = import file;
      in if builtins.isFunction mod
      then args: mod (args // { inputs = dotnixInputs // args.inputs; })
      else mod)
    files;

  modules = "${inputs.self}/modules";

  aspects = lib.pipe inputs.import-tree [
    (i: i.addPath "${modules}/aspects")
    (i: i.withLib lib)
    (i: i.files)
  ];

  # Product parts: the wiring every consumer needs to boot a host.
  productParts = map (name: "${modules}/parts/${name}") [
    "flake-parts.nix"
    "configuration.nix"
    "age.nix"
    "home-manager.nix"
    "templates.nix"
  ];

  # Dev parts: only the library evaluates these by default; consumers opt
  # in via flakeModules.devTools. Keep them as one bundle — pre-commit needs
  # treefmt, devshell needs the agenix-rekey package from age.nix.
  devParts = map (name: "${modules}/parts/${name}") [
    "devshell.nix"
    "pre-commit.nix"
    "treefmt.nix"
  ];
in
{
  flake.flakeModule.imports = wrapMods (aspects ++ productParts);

  flake.flakeModules.devTools = { imports = wrapMods devParts; };
}
