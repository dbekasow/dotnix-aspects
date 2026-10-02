{ inputs, lib, ... }: {
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-parts.flakeModules.flakeModules # expose flake.flakeModules
  ];

  systems = lib.mkDefault [ "x86_64-linux" ];
  # debug stays off: the introspection mirror taxes every outputs walk of
  # every consumer. The helix-lsp nixd options exprs expect a `debug = true`
  # flake — opt in locally when you want editor completion for flake-parts options.
}
