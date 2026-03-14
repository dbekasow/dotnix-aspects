{ inputs, lib, config, ... }: {
  config.flake.nixosConfigurations = lib.mapAttrs
    (hostname: opts:
      inputs.nixpkgs.lib.nixosSystem {
        inherit (opts) system;
        specialArgs = { inherit inputs; };
        modules = [
          { system.stateVersion = lib.mkDefault "26.05"; }
          { networking.hostName = hostname; }
          { imports = opts.modules; }
        ];
      }
    )
    config.dotnix.hosts;
}
