{ inputs, lib, ... }: {
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = lib.mkDefault [ "x86_64-linux" ];
  debug = lib.mkDefault true;
}
