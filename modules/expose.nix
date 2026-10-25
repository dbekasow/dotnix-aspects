{ inputs, lib, ... }:
let
  modules = ./.;
  featureRoot = ../features;

  featureModules = lib.pipe inputs.import-tree [
    # Use pinned import-tree defaults for feature entry-point discovery.
    (i: i.addPath "${featureRoot}")
    (i: i.withLib lib)
    (i: i.files)
  ];

  profileModules = [
    ../profiles/base.nix
    ../profiles/core.nix
    ../profiles/desktop-apps.nix
    ../profiles/desktop-shell.nix
    ../profiles/desktop.nix
    ../profiles/development.nix
    ../profiles/mail.nix
    ../profiles/server.nix
    ../profiles/term-cli.nix
    ../profiles/term-monitoring.nix
    ../profiles/term-nix.nix
    ../profiles/term-secrets.nix
    ../profiles/term-shell.nix
    ../profiles/term-ux.nix
    ../profiles/terminal-herdr.nix
    ../profiles/terminal.nix
    ../profiles/workstation.nix
  ];

  consumerAdapter = (import ./integration/default.nix) inputs.self;

  devParts = map (name: "${modules}/parts/${name}") [
    "flake-parts.nix"
    "age.nix"
    "devshell.nix"
    "pre-commit.nix"
    "treefmt.nix"
  ];
in
{
  imports = featureModules ++ profileModules ++ devParts;

  config = {
    flake-file.outputs = ''
      inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [
          inputs.flake-file.flakeModules.default
          inputs.den.flakeModule
          (inputs.den.namespace "dotnix" true)
          ./modules/expose.nix
        ];
      }
    '';

    flake-file.inputs = {
      den.url = "github:denful/den/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f";
      flake-file.url = "github:vic/flake-file";
      import-tree.url = "github:vic/import-tree";
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    flake.flakeModules.default = consumerAdapter;
    flake.flakeModules.devTools.imports = [ inputs.flake-file.flakeModules.default ]
      ++ map (f: f { inherit inputs lib; }) (map import devParts);
    flake.templates.default = {
      description = "Dendritic NixOS configuration using dotnix";
      path = ../templates/dotnix;
    };
  };
}
