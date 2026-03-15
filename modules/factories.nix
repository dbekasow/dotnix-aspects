{ inputs, lib, config, ... }:
let inherit (config.flake) modules; in {
  config.flake.nixosConfigurations = lib.mapAttrs
    (hostname: hostArgs:
      inputs.nixpkgs.lib.nixosSystem {
        inherit (hostArgs) system;
        modules = hostArgs.modules ++ [
          { system.stateVersion = lib.mkDefault "26.05"; }
          { networking.hostName = hostname; }
          { dotnix.host = hostArgs; }
          modules.nixos.core
        ];
      }
    )
    config.dotnix.hosts;
}
