{ inputs, lib, config, ... }:
let
  dotnixInputs = inputs;

  wrapMods = files: map
    (file:
      let mod = import file;
      in if builtins.isFunction mod
      then
        lib.setDefaultModuleLocation file
          (lib.mirrorFunctionArgs mod
            (args: mod (args // { inputs = dotnixInputs // args.inputs; })))
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
  imports = [ inputs.flake-parts.flakeModules.flakeModules ];

  flake.flakeModules.default.imports = wrapMods (aspects ++ productParts);

  # Registry without the factory: aspects + tiers plus the flake-parts.nix
  # substrate that declares the flake.modules option they register into.
  # For consumers that assemble hosts themselves (own nixosSystem,
  # nix-darwin) — the dotnix options namespace, nixosConfigurations
  # writer, age-rekey apps and template registration stay out.
  # flakeModule is the complete product; this is the registry only.
  flake.flakeModules.aspects = {
    imports = wrapMods (aspects ++ [ "${modules}/parts/flake-parts.nix" ]);
  };

  flake.flakeModules.devTools = { imports = wrapMods devParts; };

  # Flat standard outputs so plain NixOS/Home Manager flakes can import
  # aspects (inputs.dotnix.nixosModules.fish) without flake-parts. Pure
  # alias surface — the classes stay owned by flake.modules.
  flake.nixosModules = config.flake.modules.nixos;
  flake.homeManagerModules = config.flake.modules.homeManager;
}
