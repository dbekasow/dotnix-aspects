{ inputs, lib, config, ... }:
let inherit (config.flake) modules; in {
  config.flake.nixosConfigurations = lib.mapAttrs
    (hostname: host:
      inputs.nixpkgs.lib.nixosSystem {
        inherit (host) system;
        modules = host.modules ++ [
          { system.stateVersion = lib.mkDefault "26.05"; }
          { dotnix = { inherit hostname host; }; }
          { networking.hostName = hostname; }
          modules.nixos.core
        ];
      }
    )
    config.dotnix.hosts;
}
